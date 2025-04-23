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
private class TrMeterTest {

    static testMethod void testEmailCreation() {
        
        List<Meter_Details__c> meters = new List<Meter_Details__c>();
        
        //Create test data
        Account a = TestData.createClientAccount();
        insert a;
        
//        Contracting_Entity1__c c = TestData.createContractingEntity(a.Id);
//        insert c;
        
        Meter_Details__c m = TestData.createElectricMeter(a.Id);
        m.Meter_Identifier__c = '00000000';
        insert m;
        meters.add(m);
        
        Supply_Contract__c s = new Supply_Contract__c(Meter__c = m.Id, Contract_End_Date__c = system.today(),
                                                        Product_Type__c = 'Flex Solo',Is_Unit_Test__c =true);
        insert s;
        
        system.debug('a: ' +a);
 //       system.debug('c: ' +c);
        system.debug('m: ' +m);
        system.debug('s: ' +s);
        
        List<Meter_Details__c> meter = [SELECT Id, Name, Meter_Status__c FROM Meter_Details__c];
        system.debug('meter: ' +meter);
        
        Test.startTest();
        //m.Meter_Status__c = 'Inactive';
        //update m;
        system.debug('m: ' +m);
        
        
        //Check that only one email was sent
        integer invoications = Limits.getEmailInvocations();
        //system.assertEquals(1,invoications);
        Test.stopTest();
        
        
        
    }
}