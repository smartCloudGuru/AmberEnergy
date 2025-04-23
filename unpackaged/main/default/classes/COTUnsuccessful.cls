public without sharing class COTUnsuccessful {
    @AuraEnabled
    public static void closeCOT(String recordId){
        
        system.debug('recordId:'+recordId);
        
        List<Task> tasks = [SELECT Id FROM Task WHERE whatId = :recordId 
                                AND isClosed = false];
        if(!tasks.isEmpty()){ 
            delete tasks;
        }

        Order o = [SELECT Id,Status FROM Order WHERE Id = :recordId LIMIT 1];
        
        system.debug('Order:'+o);
        
        o.Status = 'Cancelled';
        update o;
        
        system.debug('Order:'+o);
      
    }
}