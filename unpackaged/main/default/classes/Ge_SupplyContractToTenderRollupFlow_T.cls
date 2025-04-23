/**********************************************************************
Name:  Ge_SupplyContractToTenderRollupFlow_T
Copyright © 2023
======================================================
======================================================
Purpose:  Test Class for the Ge_SupplyContractToTenderRollupFlow_I class

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
1.0      Lynn Mejos          17/05/2023     
***********************************************************************/
@isTest
public class Ge_SupplyContractToTenderRollupFlow_T {

    @testSetup static void setup() {
        
        TestData.setupProductsAndPriceBooks();
            
        //in this test we'll test a load of scenarios
        Supply_Contract__c checkContract;
        
        User testUser = TestData.createAdmin();
        insert testUser;

        //create an account
        Account testAccount = TestData.createClientAccount();
        insert testAccount;  
        
        //create an opportunity
        Opportunity testOpp = TestData.createNewBusinessOpportunity(testAccount.Id);
        insert testOpp;          
        
        //create meters
        RecordType gasType = [SELECT Id FROM RecordType WHERE sObjectType='Meter_Details__c' AND developerName='Gas'];
        Meter_Details__c testMeter1 = new Meter_Details__c(Account__c=testAccount.Id,Name='1',MPRN__c='1',Meter_Type__c='Gas',Meter_Status__c='Active',recordtypeid=gastype.Id);
        insert testMeter1;
        
        Tender__c testTender1 = TestData.createTender(testAccount.Id,testOpp.Id,testUser.Id);
        insert testTender1;
        
        Supply_Contract__c supCon1 = TestData.createSupplyContract(testMeter1.Id,testTender1.Id,testAccount.Id,system.today()+10);
        insert supCon1;
    }
    
    /**
     * @methodname - InvocableMethodTest
     * @description - To cover createNewOrderItems method
     */
    @isTest 
    private static void undeleteSupplyContractTest(){
        List<Supply_Contract__c> supplyContract = [SELECT ID,tender__c,contract_Value__c FROM Supply_Contract__c];
        List<List<Supply_Contract__c>> scList = new List<List<Supply_Contract__c>>();
        scList.add(supplyContract);
        Test.StartTest();
        Ge_SupplyContractToTenderRollupFlow_I.rollupToTender(scList);
        test.stopTest();
    }
}