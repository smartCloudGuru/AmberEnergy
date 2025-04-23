public class companyIndexController {
	@AuraEnabled
	public static List<indexEntry__c> getEntries() {
        List<indexEntry__c> entries = [SELECT Id, Description__c,Detail__c, Name FROM indexEntry__c];
        system.debug('apex entries:'+entries);
        return entries;    
	}
}