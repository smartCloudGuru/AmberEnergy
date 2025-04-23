global class OpportunityReset implements Schedulable {
   global void execute(SchedulableContext SC) {
      system.debug('OpportunityReset!'); 
      
      
      //Select open Opportunities
      
      List<Opportunity> openOpps = [select Likelihood_of_Closure__c from Opportunity where isClosed=false and RecordTypeId!=NULL];
      
      //Reset the Liklihood of closeure field
      
      for(Opportunity o : openOpps){
          o.Likelihood_of_Closure__c = 'Requires Updating';
      }   
             
      try{
        system.debug('updating Opportunities: '+openOpps);
            update openOpps;
      }catch(Exception e){
      system.debug('***Problem reseting the Opportunity on batch***');
            system.debug(e.getMessage());
            Error__c err = new Error__c(Title__c = 'OpportunityReset',Object__c = 'Opportunity',Description__c = 
                'Problem encountered resetting the Opportunity Liklihood of Closure during batch',Sub_Description__c = e.getMessage()+' : '+e);
            insert err;
      }
    }
}