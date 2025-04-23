public with sharing class TrNote extends TriggerHandler {


    public TrNote() {}
    
    protected override void afterupdate() {     
        handleNewNoteUpdate();
    }

    public void handleNewNoteUpdate(){
        
        /*
        This method is designed to update a field on an object from the most
        recent note related to the object in order to give a clear summary
        */
        
        system.debug('Run handleNewNote');
        
        /*----------------
            Collections
        -----------------*/
        
        //Get Note from the trigger
        List<ContentVersion> newNotes = (List<ContentVersion>) Trigger.new;

        
        
        //Get a list of active users and place them into a map in order to get the Name of the user
        List<User> activeUsers = [SELECT Id, Name FROM User WHERE IsActive = true ];
        Map<Id,User> usermap = new Map<Id,User>(activeUsers);
        
        //noteIds
        Set<Id> newContentNoteIdSet = new Set<Id>();
        for(ContentVersion newNote : newNotes ){
            newContentNoteIdSet.add(newNote.ContentDocumentId);
        }
        
        //Find the related records
        List<ContentDocumentLink> contentLinks = [SELECT Id, LinkedEntityId, ContentDocumentId 
                                                    FROM ContentDocumentLink WHERE ContentDocumentId in :newContentNoteIdSet];
        
        Map<Id,String> relatedObjectMap = new Map<Id,String>();
        
        system.debug('List newNotes: ' +newNotes);
        
        /*-------------------
            Message build
        --------------------*/      
        
        for(ContentVersion newNote : newNotes ){
            
            system.debug('Working note: '+newNote);
            String userName;
            if (userMap.containsKey(newNote.CreatedById)) {
                userName = usermap.get(newNote.CreatedById).Name;
            } else {
                username = usermap.get(newNote.LastmodifiedbyId).Name;
            }
            //Create variables to construct the update
            
    
            system.debug('title: ' +newNote.Title);
            system.debug('description: ' +newNote.TextPreview);
            system.debug('createdDate: ' +newNote.CreatedDate.date());
            system.debug('createdBy: ' +userName);
            
            //Create field and store in variable for update     
            String latestNote = userName+': ' +  system.now() + '\n' +
                                    newNote.Title+ '\n' +
                                    newNote.TextPreview;        
            system.debug('latestNote: ' +latestNote);                   
            
    
            //Populate Map - RecordId to Object Name
            for(ContentDocumentLink c : contentLinks){
                relatedObjectMap.put(c.LinkedEntityId,c.LinkedEntityId.getSObjectType().getDescribe().getName());
            }       
            
            Map<Id,String> OpportunitiesToUpdate = new Map<Id,String>();
            Map<Id,String> AccountsToUpdate = new Map<Id,String>();
            Map<Id,String> IssuesToUpdate = new Map<Id,String>();
                    
            //Loop over the related records and send them for updates
            for(ContentDocumentLink c : contentLinks){      
                if(relatedObjectMap.get(c.LinkedEntityId) == 'Opportunity'){
                    system.debug('adding opp for update: '+newNote);
                    OpportunitiesToUpdate.put(c.LinkedEntityId,latestNote);
                }
                /*
                if(relatedObjectMap.get(c.LinkedEntityId) == 'Account' && newNote.Title.containsIgnoreCase('RISK')){
                    system.debug('adding acc for update: '+newNote);
                    AccountsToUpdate.put(c.LinkedEntityId,latestNote);
                }
                */
                if(relatedObjectMap.get(c.LinkedEntityId) == 'Issue__c'){
                    system.debug('adding issue for update: '+newNote);
                    IssuesToUpdate.put(c.LinkedEntityId,latestNote);
                }                            
            }
            
            if(OpportunitiesToUpdate.size() != 0){
                updateOpportunity(OpportunitiesToUpdate);
            }
            /*
            if(AccountsToUpdate.size() != 0){
                updateAccountRiskInfo(AccountsToUpdate);
            }
            */
            if(IssuesToUpdate.size() != 0){
                updateIssueLatestNote(IssuesToUpdate);
            }
        }
    }       
        
    public void updateOpportunity(Map<Id,String> IdsToMsgs){                  
        try{      
            Set<Id> keyset = IdsToMsgs.keyset();     
            List<Opportunity> oppsToUpdate = [SELECT Id,Progress_Update__c FROM Opportunity WHERE Id =: keyset];   
            for(Opportunity o : oppsToUpdate){
                o.Progress_Update__c = IdsToMsgs.get(o.Id); 
            }                    
            update oppsToUpdate ;             
        }catch(Exception e){            
            system.debug('***Problem encountered updating Opportunity from Note***');
            system.debug(e.getMessage());
            Error__c err = new Error__c(Title__c = 'TrNote',Object__c = 'ContentDocumentLink',Description__c = 
                    'Problem encountered setting Progress_Update__c field on Opportunity',
                    Sub_Description__c = e.getMessage()+' : '+e);
            insert err;
        }
    }
    
    /*
    public void updateAccountRiskInfo(Map<Id,String> IdsToMsgs){                  
        try{            
            Set<Id> keyset = IdsToMsgs.keyset();     
            List<Account> accsToUpdate = [SELECT Id,Account_Risk_Information__c FROM Account WHERE Id =: keyset];   
            for(Account a : accsToUpdate){
                a.Account_Risk_Information__c = IdsToMsgs.get(a.Id); 
            }                    
            update accsToUpdate;                       
        }catch(Exception e){            
            system.debug('***Problem encountered updating Account from Note***');
            system.debug(e.getMessage());
            Error__c err = new Error__c(Title__c = 'TrNote',Object__c = 'ContentDocumentLink',Description__c = 
                    'Problem encountered setting Progress_Update__c field on Account',
                    Sub_Description__c = e.getMessage()+' : '+e);
            insert err;
        }
    }
    */
    
    public void updateIssueLatestNote(Map<Id,String> IdsToMsgs){                  
        try{             
            Set<Id> keyset = IdsToMsgs.keyset();     
            List<Issue__c> issuesToUpdate = [SELECT Id,Latest_Note__c FROM Issue__c WHERE Id =: keyset];   
            for(Issue__c i : issuesToUpdate){
                i.Latest_Note__c = IdsToMsgs.get(i.Id); 
            }                    
            update issuesToUpdate;              
        }catch(Exception e){            
            system.debug('***Problem encountered updating Issue from Note***');
            system.debug(e.getMessage());
            Error__c err = new Error__c(Title__c = 'TrNote',Object__c = 'ContentDocumentLink',Description__c = 
                    'Problem encountered setting Latest_Note__c field on Issue',
                    Sub_Description__c = e.getMessage()+' : '+e);
            insert err;
        }
    }
     
    
}