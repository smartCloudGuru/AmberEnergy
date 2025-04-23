/**
 * Created by ukaya01 on 2/26/2021.
 */

@isTest
public with sharing class IssueNotesImportControllerTest {

    @TestSetup
    static void setup(){
        Account acc = TestData.createClientAccount();
        insert acc;

        Meter_Details__c meter = TestData.createElectricMeter(acc.Id);
        insert meter;

        Issue__c issue = new Issue__c();
        issue.Meter__c = meter.Id;
        issue.Status__c = 'Reported';
        insert issue;
    }

    @IsTest
    static void saveCSVContent(){
        List<Issue__c> IssueList = [SELECT ID, Name, Meter__c, Meter__r.Name FROM Issue__c];
        string meterRef = IssueList.get(0).Meter__r.Name;
        string title = 'Update';
        string note = 'Test note';
        string csvColumnHeader = 'Meter Ref, Title, Notes\r\n';
        String rowStr = meterRef + ',' + title + ',' + note;
        String csvFile = csvColumnHeader + rowStr + '\r\n';
        Test.startTest();
        List<IssueNotesImportController.IssueNote> issueNotes = IssueNotesImportController.convertCSV(JSON.serialize(csvFile));
        IssueNotesImportController.processRecords(JSON.serialize(issueNotes));
        Test.stopTest();
    }

}