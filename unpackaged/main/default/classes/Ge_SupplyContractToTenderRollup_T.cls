/**********************************************************************
Name:  Ge_SupplyContractToTenderRollup_T
Copyright © 2023
======================================================
======================================================
Purpose:  Test Class for the Ge_SupplyContractToTenderRollup_TH class

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
1.0      Lynn Mejos          07/04/2023     
***********************************************************************/
@isTest
public class Ge_SupplyContractToTenderRollup_T {

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
		Supply_Contract__c supCon2 = TestData.createSupplyContract(testMeter1.Id,testTender1.Id,testAccount.Id,system.today()+10);
		insert supCon2;
    }
    
    /**
     * @methodname - undeleteSupplyContractTest
     * @description - To cover undelete method
     */
    @isTest 
    private static void undeleteSupplyContractTest(){
        Supply_Contract__c supplyContract = [SELECT ID FROM Supply_Contract__c LIMIT 1];
        delete supplyContract;
        
        Test.StartTest();
        
        Supply_Contract__c deletedSupplyContract = [SELECT Id, Name FROM Supply_Contract__c WHERE isDeleted=true ALL ROWS];
        undelete deletedSupplyContract;
        test.stopTest();
    }
}