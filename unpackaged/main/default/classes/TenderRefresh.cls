public without sharing class TenderRefresh {
    @AuraEnabled
    public static void apexRefresh(String recordId){
        
        system.debug('recordId:'+recordId);
        
        TestData testDataClass = new TestData();
        Id procTypeId = TestData.recordTypeMap.get('Task-Procurement');
        
        List<Task> tasks = [SELECT Id FROM Task WHERE whatId = :recordId 
                                    AND isClosed = false];
        if(!tasks.isEmpty()){ 
            delete tasks;
        }

        Tender__c t = [SELECT Id,stage__c,refreshes__c,ownerid
                            FROM Tender__c WHERE Id = :recordId LIMIT 1];
        system.debug('tender:'+t);
        
        //t.Stage__c = 'Awaiting Tender';
        t.Refreshes__c = t.Refreshes__c + 1;
        update t;
            
        insert new Task(ownerId=t.ownerId,whatId=t.Id,recordtypeid=procTypeId,
                          subject='Request Refresh',activityDate=system.today());
        
    }
}