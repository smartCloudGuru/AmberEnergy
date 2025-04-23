/**
 * @description       : 
 * @author            : Tom Jefford
 * @group             : 
 * @last modified on  : 12-17-2020
 * @last modified by  : Tom Jefford
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   12-17-2020   Tom Jefford   Initial Version
**/
global class LiveTenancyUpdate implements  Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'select Id,Has_Active_Tenancy__c,Name from Property__c';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){

        system.debug('LiveTenancyUpdate!');
        if(!scope.isEmpty()){
            system.debug('Our scope is ' +scope.size());            
            List<Property__c> props = (List<Property__c>)scope;
             
            //make a set for selection
            Set<Id> propIdSet = new Set<Id>();
            for(Property__c p : props){
                propIdSet.add(p.Id);
            }
             
          //Get data required for the update
          List<Tenancy__c> tnts = [select name,Property__c,From_Date__c,To_Date__c,Property__r.Name from Tenancy__c where Property__c in :propIdSet];
          
          if(!tnts.isEmpty()){
            system.debug('Mapping Props to Tenancies');
              //Create maps for the method     
              Map<Id,List<Tenancy__c>> mapPropToTnts = new Map<Id,List<Tenancy__c>>();
              
              for (Property__c p : props){      
                //Temporary Tenancy list per Property
                List<Tenancy__c> tempTenancies = new List<Tenancy__c>();        
                for (Tenancy__c t : tnts){
                    if (t.Property__c == p.Id){
                        tempTenancies.add(t);
                    }               
                }
                mapPropToTnts.put(p.Id,tempTenancies);      
             }
             system.debug('mapPropToTnts: '+mapPropToTnts);
                   
              //Lists for update
              List<Property__c> propsToUpdate = new List<Property__c>();
              
              //map for later reference from property to its active tenancies
              Map<Property__c,List<Tenancy__c>> mapProptoActiveTnts = new Map<Property__c,List<Tenancy__c>>();
              
              system.debug('Lets now work out whats active');
              for (Property__c p : props){
                system.debug('Checking prop: '+p);
                List<Tenancy__c> activeTenancies = new List<Tenancy__c>();
                //capture the old value so we can see whats changed and needs updating
                Boolean oldValue = p.Has_Active_Tenancy__c;
                //get the tenancies that belong to this property
                List<Tenancy__c> tempTens = mapPropToTnts.get(p.Id);
                if(!tempTens.isEmpty()){
                    //reset all props to false
                    p.Has_Active_Tenancy__c = false;
                    // loop over the tenancies and change field where we field a true scenario
                    for (Tenancy__c tnt : tempTens){            
                        if(tnt.To_Date__c != null){
                            if(tnt.From_Date__c <= system.today() && tnt.To_Date__c >= system.today()){
                                p.Has_Active_Tenancy__c = true;
                                activeTenancies.add(tnt);
                                system.debug('Tenance is active: '+tnt);
                            }
                        }else{
                            if(tnt.From_Date__c <= system.today()){
                                p.Has_Active_Tenancy__c = true;
                                activeTenancies.add(tnt);
                                system.debug('Tenance is active: '+tnt);
                            }
                        }
                    }
                    //check whats changed and add to update list 
                    if(oldValue != p.Has_Active_Tenancy__c){
                        propsToUpdate.add(p);
                    }
                }
                mapProptoActiveTnts.put(p,activeTenancies);
                system.debug('mapProptoActiveTnts: '+mapProptoActiveTnts);
              }
              
              /*
                    Below section handles the creation of Cases for Properties that have multiple active Tenancies
                    prompting the user to investigate.
                    --------------------------------------------------------------------------------------------------
                        User should have a Case created the morning following the batch running if there are multiple
                        live Tenancies/Residencies. Case to be assigned to C:U queue.
                        
                        Code should prevent duplicate Cases being created for the Property if there is already an open
                        Case of the same type.
                    --------------------------------------------------------------------------------------------------
              */
              
              //Get C:U record type for use in the select query
              Recordtype communityRecordType = [select Id from Recordtype where name = 'COMM:UNITY' and sobjecttype='Case'];
              //Get C:U Case Queue ID for Case Owner when creating Case
              Group cuQueue = [select Id from Group where Type = 'Queue' and Name = 'Community Cases'];
              //Get all C:U (Multiple Live Tenancy) Cases
              List<Case> openCases = [select Id,Property__c from Case where recordtypeid = :communityRecordType.Id 
                                        and Reason ='Multiple Live Residencies' and isClosed = false];
              //List to add new Cases created within the try catch                          
              List<Case> newCases = new List<Case>();
              
              
              Map<Property__c,List<Case>> mapPropToOpenCases = new Map<Property__c,List<Case>>();
              //create a map of property to its open commuity live resident cases 
              system.debug('Mapping Props to cases');
              for(Property__c p : props){               
                    List<Case> tempPropCases = new List<Case>();
                    for(Case c : openCases){
                        system.debug('Check Case ' +c);
                        if(c.Property__c == p.Id){
                            system.debug('Adding to temp tenancy');
                            tempPropCases.add(c); //Previously - tempTenancies.add(t);
                        }
                    }
                    mapPropToOpenCases.put(p,tempPropCases);
              }
              system.debug('mapPropToOpenCases:'+mapPropToOpenCases);
                
              
              //Loop over all Properties within batch and any related Tenancies and Cases
                  //if there is a Case - do nothing 
                  //if there isnt a Case, create one and link it to the Property
              for(Property__c p : props){
                
                system.debug('Busniess logic check on prop: '+p);
                system.debug('mapProptoActiveTnts.get(p).size(): '+mapProptoActiveTnts.get(p).size());
                system.debug('mapPropToOpenCases.get(p).isEmpty(): '+mapPropToOpenCases.get(p).isEmpty());
                
                if(mapProptoActiveTnts.get(p).size() > 1 && mapPropToOpenCases.get(p).isEmpty()){
                    system.debug('Create case');
                    integer liveCount = mapProptoActiveTnts.get(p).size();
                    
                //Create Multiple Tenancy Case for the property and assign to the Property
                    Case newCase = new Case (RecordTypeId=communityRecordType.Id,Status='Not Started',
                                                    Reason='Multiple Live Residencies',
                                                    Follow_up_Action_Date__c=system.today()+1,Subject='Multiple live tenancies at ' +p.Name,
                                                    Description='The property has the following multiple live Residents: '+liveCount+';\n',
                                                    Property__c=p.Id,OwnerId=cuQueue.Id);
                //Add the names of the Tenancies to the Case description for the user to identify the records to investigate
                   for(Tenancy__c t : mapProptoActiveTnts.get(p)) {             
                       newCase.Description = newCase.Description + t.name + '\n';
                   }
                //Add Case to list for inset within try-catch
                   newCases.add(newCase);
                }
              }                     
                  try{
                    if(!propsToUpdate.isEmpty()){
                    system.debug('updating Properties: '+propsToUpdate);
                        update propsToUpdate; 
                    }
                    if(!newCases.isEmpty()){
                    system.debug('inserting newCases: '+newCases);
                        insert newCases;
                    }
                        
                  }catch(Exception e){
                  system.debug('***Problem setting the active tenancy field on Properties***');
                        system.debug(e.getMessage());
                        Error__c err = new Error__c(Title__c = 'LiveTenancyUpdate',Object__c = 'LiveTenancyUpdate!',Description__c = 
                            'Problem encountered updating the Active Tenancy field on the Property object',Sub_Description__c = e.getMessage()+' : '+e);
                        insert err;
                  }
          }
        }
    }
    global void finish(Database.BatchableContext BC){}
 }