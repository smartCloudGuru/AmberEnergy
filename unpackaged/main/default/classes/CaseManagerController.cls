/**
 * Created by ukaya01 on 9/20/2021.
 */

public without sharing class CaseManagerController {

    @AuraEnabled
    public static List<Case> retrieveCaseRecords(string filter, string orderBy){
        List<Case> cases = new List<Case>();
        cases = Database.query('SELECT Id, CaseNumber, Subject, Owner.Id, Owner.Name, CreatedDate,' +
                'Status, Contact.Id, Contact.Name, Reason, Priority, Landlord_Resident__c, ' +
                'Site__r.Id, Site__r.Name, SuppliedEmail,' +
                '(SELECT Id, Subject, ToAddress, FromAddress, FromName, CcAddress, BccAddress ,CreatedDate, HtmlBody FROM EmailMessages Order BY CreatedDate DESC) ' +
                'FROM Case WHERE ' + filter + ' ORDER BY ' + orderBy);
        return cases;
    }

    @AuraEnabled
    public static List<Case> updateCaseRecords(string records, string filter, string orderBy){

        try{
            List<Case> casesToUpdate = (List<Case>)JSON.deserialize(records, List<Case>.class);

            if(!casesToUpdate.isEmpty()){
                update casesToUpdate;
            }

            return retrieveCaseRecords(filter, orderBy);

        }catch(Exception e){
            string message = e.getMessage();
            if(message.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                message = message.split('FIELD_CUSTOM_VALIDATION_EXCEPTION,')[1];
            }
            if(message.contains('INVALID_EMAIL_ADDRESS')){
                message = message.split('INVALID_EMAIL_ADDRESS,')[1];
            }
            throw new AuraHandledException(message);
        }

    }

}