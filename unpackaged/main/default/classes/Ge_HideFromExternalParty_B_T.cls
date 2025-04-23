/**********************************************************************
 Name:  Ge_HideFromExternalParty_B_T
 Copyright © 2024
 ======================================================
======================================================
Purpose: Batch and invocable class to hide or show records from external party
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0      Dave Liskevich       12/05/2024       Initial Creation    Initial Creation    
***********************************************************************/  
@IsTest
public with sharing class Ge_HideFromExternalParty_B_T {
    @TestSetup
    static void setup(){
        Account acc = TestData.createClientAccount();
        acc.Ge_HideFrom3rdPartyVisibility__c = false;
        insert acc;

        Site__c site = new Site__c(name = 'TestCaseSite', operator__c = acc.id, account__c = acc.id);
        insert site;

        Building__c building = new Building__c(name='TestCaseBuilding');
        building.Ge_HideFrom3rdPartyVisibility__c = false;
        insert building;

        Property__c property = new Property__c(building__c = building.Id, name = 'TestCaseProperty');
        insert property;

        Contact contact = new Contact(LastName = 'TestCaseLastName',Phone = '1');
        insert contact;

        Recordtype communityRecordType = [SELECT Id FROM Recordtype WHERE name = 'COMM:UNITY' AND sobjecttype='Case'];

        Case cs = new Case(recordTypeId = communityRecordType.Id, Status = 'Not Started', Reason = 'Multiple Live Residencies', Duration_of_Cae__c = 1, X1_Day_Case_Reason__c = 'N/A',
                Follow_up_Action_Date__c = system.today()+1, Subject = property.Name, Description = 'Test Case', Property__c = property.Id, contactId = contact.id ,Site__c = site.id, Landlord_Resident__c = 'Landlord', Tenancy_Unknown__c = TRUE);
        cs.Ge_HideFrom3rdPartyVisibility__c = false;        
        insert cs;

    }

    @isTest
    public static void testHide() {
        Case cs = [SELECT Id, Ge_HideFrom3rdPartyVisibility__c FROM Case];
        Ge_HideFromExternalParty_B.VisibilityRequest request = new Ge_HideFromExternalParty_B.VisibilityRequest();
        request.recordIds = new List<String>{cs.Id};
        request.hideFromExternalParty = true;
        List<Ge_HideFromExternalParty_B.VisibilityRequest> requests = new List<Ge_HideFromExternalParty_B.VisibilityRequest>{request};
        Test.startTest();
        Ge_HideFromExternalParty_B.setVisibility(requests);
        Database.executeBatch(new Ge_HideFromExternalParty_B(request.recordIds, true));
        Test.stopTest();

    }

    @isTest
    public static void testShow() {
        Case cs = [SELECT Id, Ge_HideFrom3rdPartyVisibility__c FROM Case];
        Ge_HideFromExternalParty_B.VisibilityRequest request = new Ge_HideFromExternalParty_B.VisibilityRequest();
        request.recordIds = new List<String>{cs.Id};
        request.hideFromExternalParty = false;
        List<Ge_HideFromExternalParty_B.VisibilityRequest> requests = new List<Ge_HideFromExternalParty_B.VisibilityRequest>{request};
        Test.startTest();
        Ge_HideFromExternalParty_B.setVisibility(requests);
        Database.executeBatch(new Ge_HideFromExternalParty_B(request.recordIds, false));
        Test.stopTest();

    }
}