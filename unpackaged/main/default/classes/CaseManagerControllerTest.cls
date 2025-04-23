/**
 * Created by ukaya01 on 9/29/2021.
 */

@isTest
public with sharing class CaseManagerControllerTest {

    @TestSetup
    static void setup(){
        Account acc = TestData.createClientAccount();
        insert acc;

        Site__c site = new Site__c(name = 'TestCaseSite', operator__c = acc.id, account__c = acc.id);
        insert site;

        Building__c building = new Building__c(name='TestCaseBuilding');
        insert building;

        Property__c property = new Property__c(building__c = building.Id, name = 'TestCaseProperty');
        insert property;

        Contact contact = new Contact(LastName = 'TestCaseLastName',Phone = '1');
        insert contact;

        Recordtype communityRecordType = [SELECT Id FROM Recordtype WHERE name = 'COMM:UNITY' AND sobjecttype='Case'];

        Case cs = new Case(recordTypeId = communityRecordType.Id, Status = 'Not Started', Reason = 'Multiple Live Residencies', Duration_of_Cae__c = 1, X1_Day_Case_Reason__c = 'N/A',
                Follow_up_Action_Date__c = system.today()+1, Subject = property.Name, Description = 'Test Case', Property__c = property.Id, contactId = contact.id ,Site__c = site.id, Landlord_Resident__c = 'Landlord', Tenancy_Unknown__c = TRUE);
        insert cs;

    }

    @IsTest
    static void retrieveCaseRecords(){
        Recordtype communityRecordType = [SELECT Id FROM Recordtype WHERE name = 'COMM:UNITY' AND sobjecttype='Case'];
        string filter = 'RecordTypeId = \'' + communityRecordType.Id + '\' AND IsClosed = false';
        Test.startTest();
        List<Case> cases = CaseManagerController.retrieveCaseRecords(filter,'CaseNumber ASC');
        system.assert(!cases.isEmpty());
        Test.stopTest();
    }

    @isTest
    static void updateCaseRecords(){
        Recordtype communityRecordType = [SELECT Id FROM Recordtype WHERE name = 'COMM:UNITY' AND sobjecttype='Case'];
        string filter = 'RecordTypeId = \'' + communityRecordType.Id + '\' AND IsClosed = false';
        Test.startTest();
        List<Case> cases = CaseManagerController.retrieveCaseRecords(filter ,'CaseNumber ASC');
        for(Case c : cases){
            c.Status = 'Closed';
        }
        cases = CaseManagerController.updateCaseRecords(JSON.serialize(cases),filter,'CaseNumber ASC');
        system.assert(cases.isEmpty());
        Test.stopTest();
    }

    @isTest
    static void updateCaseRecordsInvalidEmail(){
        Recordtype communityRecordType = [SELECT Id FROM Recordtype WHERE name = 'COMM:UNITY' AND sobjecttype='Case'];
        string filter = 'RecordTypeId = \'' + communityRecordType.Id + '\' AND IsClosed = false';
        Test.startTest();
        List<Case> cases = CaseManagerController.retrieveCaseRecords(filter ,'CaseNumber ASC');
        for(Case c : cases){
            c.SuppliedEmail = '1';
        }
        try{
            CaseManagerController.updateCaseRecords(JSON.serialize(cases),filter,'CaseNumber ASC');
        }catch(Exception e){
            system.assertEquals(e.getMessage(),'Script-thrown exception');
        }
        Test.stopTest();
    }

    @isTest
    static void updateCaseRecordsFieldCustomValidation(){
        Recordtype communityRecordType = [SELECT Id FROM Recordtype WHERE name = 'COMM:UNITY' AND sobjecttype='Case'];
        string filter = 'RecordTypeId = \'' + communityRecordType.Id + '\' AND IsClosed = false';
        Test.startTest();
        List<Case> cases = CaseManagerController.retrieveCaseRecords(filter ,'CaseNumber ASC');
        for(Case c : cases){
            c.Site__c = null;
        }
        try{
            CaseManagerController.updateCaseRecords(JSON.serialize(cases),filter,'CaseNumber ASC');
        }catch(Exception e){
            system.assertEquals(e.getMessage(),'Script-thrown exception');
        }
        Test.stopTest();
    }

}