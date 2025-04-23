public with sharing class TrSfRequest extends TriggerHandler {
    
    public TrSfRequest() {}
    
    /*********************/
    /* Context Overrides */
    /*********************/

    protected override void afterInsert() {
        updateFollower();
    }
    
    /*******************/
    /* Private Methods */
    /*******************/
    
    /**@description Updates a chatter following record so the creator follows and gets case feed updates */
    private void updateFollower(){
        List<SF_Requests__c> newRequests = (List<SF_Requests__c>) Trigger.new;
        List<EntitySubscription> newSubscriptions = new List<EntitySubscription>();
        for(SF_Requests__c r : newRequests){
            newSubscriptions.add(new EntitySubscription(ParentId=r.Id,SubscriberId=userinfo.getUserId()));
        }
        insert newSubscriptions;
    }
    
}