/**********************************************************************
Name:  Ge_TenderToOpportunityRollup_T
Copyright © 2023
======================================================
======================================================
Purpose:  Test Class for the Ge_TenderToOpportunityRollup_TH class

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
1.0      Lynn Mejos          06/04/2023     
***********************************************************************/
@isTest
public class Ge_TenderToOpportunityRollup_T {
    
    @testSetup static void setup() {
        testData.setupProductsAndPriceBooks();
        
        User testUser = TestData.createAdmin();
        insert testUser;
        
        Tender__c checkTender;
        Opportunity checkOpp; 
        
        //create an account
        Account testAccount = TestData.createClientAccount();
        insert testAccount;            
        //create an opportunity
        Opportunity testOpp = TestData.createNewBusinessOpportunity(testAccount.Id);        
        insert testOpp;
        
        //get the standard pricebook and products
        Product2 productP1 = [SELECT id,productCode from Product2 where ProductCode='P1' LIMIT 1];
        PriceBookEntry priceP1 = [SELECT Id,ProductCode FROM PriceBookEntry where ProductCode =:productP1.ProductCode ];       
        
        //create 3 opportunity products, we'll just re use the same product type
        List<OpportunityLineItem> sampleProducts = new List<OpportunityLineItem>();
        
        sampleProducts.add(TestData.createOpportunityProduct(productP1.Id,priceP1.Id,testOpp.Id,60));
        sampleProducts.add(TestData.createOpportunityProduct(productP1.Id,priceP1.Id,testOpp.Id,25));
        sampleProducts.add(TestData.createOpportunityProduct(productP1.Id,priceP1.Id,testOpp.Id,15));
        insert sampleProducts;
        
        testOpp.stageName = 'Closed Won';
        update testOpp;
        
        //create a Tender
        Tender__c testTender = TestData.createTender(testAccount.Id,testOpp.Id,testUser.Id);
        insert testTender;
        
        //create a meter and supply contract
        Meter_Details__c testMeter = TestData.createGasMeter(testAccount.Id);
        insert testMeter;
        
        Supply_Contract__c testSupCon = TestData.createSupplyContract(testMeter.id,testTender.id,100,testAccount.Id);
        insert testSupCon;
        
        //normally total commission is set via roll ups from supply contracts
        //but we'll just make up a value and complete for now
        testTender.Opportunity__c = testOpp.Id;
        testTender.total_tender_commission__c = 100;
        testTender.Direct_Debit_Mandate__c = 'Yes';
        testTender.stage__c = 'Complete';
        update testTender;
    }
    
    /**
     * @methodname - InvocableMethodTest
     * @description - To cover createNewOrderItems method
     */
    @isTest 
    private static void undeleteTenderTest(){
        Tender__c tender = [SELECT ID FROM Tender__c LIMIT 1];
        delete tender;
        
        Test.StartTest();
        
        Tender__c deletedTender = [SELECT Id, Name FROM Tender__c WHERE isDeleted=true ALL ROWS];
        undelete deletedTender;
        test.stopTest();
    }
}