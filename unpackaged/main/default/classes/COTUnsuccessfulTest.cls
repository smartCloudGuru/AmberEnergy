/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class COTUnsuccessfulTest {
    
    static testMethod void statusIsCancelled() {
        
        TestData.setupProductsAndPriceBooks();
        
        Account acc = TestData.createClientAccount();
        insert acc;
        Opportunity opp = TestData.createNewBusinessOpportunity(acc.Id);
        insert opp;
        Contracting_Entity1__c ce = TestData.createContractingEntity(acc.Id);
        insert ce;
        Order ord = TestData.createCOTOrder(acc.Id, ce.Id, opp.Id);
        insert ord;
        
        system.debug('ord:'+ord);
        
        Test.startTest();
        
        COTUnsuccessful.closeCOT(ord.Id);
        
        system.debug('ord:'+ord);
        
        Order testOrd = [SELECT Id,status FROM Order WHERE Id =: ord.Id];
        
        system.assertEquals('Cancelled',testOrd.Status);//Check the status was set to Cancelled
        
        Test.stopTest();
    }
    
    static testMethod void noAssociatedTasks(){
        
        TestData.setupProductsAndPriceBooks();
        
        User u = TestData.createUser();
        insert u;
        
        Account acc = TestData.createClientAccount();
        insert acc;
        Opportunity opp = TestData.createNewBusinessOpportunity(acc.Id);
        insert opp;
        Contracting_Entity1__c ce = TestData.createContractingEntity(acc.Id);
        insert ce;
        Order ord = TestData.createCOTOrder(acc.Id, ce.Id, opp.Id);
        insert ord;
        
        Test.startTest();
        
        Task t = TestData.createNormalTask(ord.Id,u.Id);
        insert t;
        
        COTUnsuccessful.closeCOT(ord.Id);
        
        List<Task> associatedTaskList = [SELECT Id,whatId FROM Task WHERE whatId =:ord.Id];
        
        system.assertEquals(0,associatedTaskList.size());//Check there are no Tasks associated to the Order
        
        Test.stopTest();
    }
}