/**********************************************************************
Name:  Ge_GenerateNewOrderItems_T
Copyright © 2023
======================================================
======================================================
Purpose:  Test Class for the Ge_GenerateNewOrderItems_I class

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0      Lynn Mejos          06/04/2023     
***********************************************************************/
@isTest
public class Ge_GenerateNewOrderItems_T {

    @testSetup static void setup() {
        
        Id priceBookId = TestData.setupProductsAndPriceBooks();
        
        User testUser = TestData.createAdmin();
        insert testUser;
        
        //create an account
        Account testAccount = TestData.createClientAccount();
        insert testAccount;
            
        //create an opportunity
        Opportunity testOpp = TestData.createNormalOpportunity(testAccount.Id,testUser.Id);
        insert testOpp;
            
        //create meters
        RecordType gasType = [SELECT Id FROM RecordType WHERE sObjectType='Meter_Details__c' AND developerName='Gas'];
        Meter_Details__c testMeter1 = new Meter_Details__c(Account__c=testAccount.Id,Name='1',MPRN__c='1',Meter_Type__c='Gas',Meter_Status__c='Active',recordtypeid=gastype.Id);
        Meter_Details__c testMeter2 = new Meter_Details__c(Account__c=testAccount.Id,Name='2',MPRN__c='2',Meter_Type__c='Gas',Meter_Status__c='Active',recordtypeid=gastype.Id);
        Meter_Details__c testMeter3 = new Meter_Details__c(Account__c=testAccount.Id,Name='3',MPRN__c='3',Meter_Type__c='Gas',Meter_Status__c='Active',recordtypeid=gastype.Id);
        insert testMeter1;
        insert testMeter2;
        insert testMeter3;
        //add to a set for later user
        Set<Id> testMeterIds = new Set<Id>();
        testMeterIds.add(testMeter1.Id);
        testMeterIds.add(testMeter2.Id);
        testMeterIds.add(testMeter3.Id);    
                
        //get the standard pricebook and products
        Product2 product = [SELECT id,productCode from Product2 where isActive = true and ProductCode='E1' LIMIT 1];
        PriceBookEntry price = [SELECT Id FROM PriceBookEntry where ProductCode =:product.ProductCode ];
     
        //create meter contracts
        Meter_Linking_Detail__c testMeterContract1 = TestData.createMeterContract(testOpp.Id,testMeter1.Id,testAccount.Id);
        Meter_Linking_Detail__c testMeterContract2 = TestData.createMeterContract(testOpp.Id,testMeter2.Id,testAccount.Id);
        Meter_Linking_Detail__c testMeterContract3 = TestData.createMeterContract(testOpp.Id,testMeter3.Id,testAccount.Id);
        
        insert testMeterContract1;
        insert testMeterContract2;
        insert testMeterContract3; 
            
        //attach products
        OpportunityLineItem oppProduct = new OpportunityLineItem();
        oppProduct.serviceDate = system.today();
        oppProduct.contract_end_date__c = system.today()+1;
        oppProduct.Product2Id = product.Id;
        oppProduct.opportunityId = testOpp.Id;
        oppProduct.pricebookEntryId = price.Id;
        oppProduct.quantity = 1;
        oppProduct.unitprice = 1000;        
        insert oppProduct;
        
        Order newOrder = new Order();
        newOrder.AccountId = testAccount.Id;
        newOrder.OpportunityId = testOpp.Id;
        newOrder.Status = 'Not Started';
        newOrder.EffectiveDate = System.today();
        newOrder.Pricebook2Id = priceBookId;
        insert newOrder;
    }
    
    /**
     * @methodname - InvocableMethodTest
     * @description - To cover createNewOrderItems method
     */
    @isTest 
    private static void InvocableMethodTest(){
        List<OPPORTUNITYLINEITEM> oppLineItemList = [SELECT ID, unitPrice, product2id, quantity, productCode, description, Product_Family__c FROM OPPORTUNITYLINEITEM LIMIT 1];
        Order ordr = [SELECT ID FROM Order LIMIT 1];
        Opportunity opp = [SELECT ID FROM Opportunity LIMIT 1];
        
        List<Ge_GenerateNewOrderItems_I.Requests> reqList = new List<Ge_GenerateNewOrderItems_I.Requests>();
        Ge_GenerateNewOrderItems_I.Requests req = new Ge_GenerateNewOrderItems_I.Requests();
        req.oppProducts = oppLineItemList;
        req.newOrder = ordr;
        req.wonOpportunity = opp;
        reqList.add(req);
        
        Test.StartTest();
        List<Ge_GenerateNewOrderItems_I.Results> res = Ge_GenerateNewOrderItems_I.createNewOrderItems(reqList);
        
        test.stopTest();
    }
}