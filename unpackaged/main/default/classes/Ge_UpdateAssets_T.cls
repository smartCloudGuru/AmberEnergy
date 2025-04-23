/**********************************************************************
Name:  Ge_UpdateAssets_T
Copyright © 2023
======================================================
======================================================
Purpose:  Test Class for the Ge_UpdateAssets_I class

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
1.0      Lynn Mejos          14/04/2023     
***********************************************************************/
@isTest
public class Ge_UpdateAssets_T {

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
        Product2 p2 = [SELECT id,productCode from Product2 where isActive = true and ProductCode!='E1' LIMIT 1];
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
        
        Asset a = new Asset();
        a.name='Test';
        a.Product2Id=product.Id;
        a.UsageEndDate=system.today()+2;
        a.accountid=testOpp.accountid;  
        insert a;    
        
        Asset a2 = new Asset();
        a2.name='Test 2';
        a2.Product2Id=p2.Id;
        a2.UsageEndDate=system.today()+2;
        a2.accountid=testOpp.accountid;  
        insert a2; 
    }
    
    /**
     * @methodname - InvocableMethodTest
     * @description - To cover updateAssets method
     */
    @isTest 
    private static void InvocableMethodTest(){
        List<OPPORTUNITYLINEITEM> oppLineItemList = [SELECT ID, Contract_End_Date__c, product2id, quantity, productCode, description, Product_Family__c FROM OPPORTUNITYLINEITEM LIMIT 1];
        List<Asset> a = [SELECT ID, UsageEndDate, Product2Id FROM Asset];
        Opportunity opp = [SELECT ID FROM Opportunity LIMIT 1];
        
        List<Ge_UpdateAssets_I.Requests> reqList = new List<Ge_UpdateAssets_I.Requests>();
        Ge_UpdateAssets_I.Requests req = new Ge_UpdateAssets_I.Requests();
        req.oppProducts = oppLineItemList;
        req.assetList = a;
        req.wonOpportunity = opp;
        reqList.add(req);
        
        Test.StartTest();
        List<List<Asset>> res = Ge_UpdateAssets_I.updateAssets(reqList);
        
        test.stopTest();
    }
    
    /**
     * @methodname - InvocableMethodTestNotAssetMatched
     * @description - To cover updateAssets Not AssetMatched method
     */
    @isTest 
    private static void InvocableMethodTestNotAssetMatched(){
        List<OPPORTUNITYLINEITEM> oppLineItemList = [SELECT ID, Contract_End_Date__c, product2id, quantity, productCode, description, Product_Family__c FROM OPPORTUNITYLINEITEM LIMIT 1];
        List<Asset> a = [SELECT ID, UsageEndDate, Product2Id FROM Asset WHERE Name ='Test 2'];
        Opportunity opp = [SELECT ID,accountId,closeDate FROM Opportunity LIMIT 1];
        
        List<Ge_UpdateAssets_I.Requests> reqList = new List<Ge_UpdateAssets_I.Requests>();
        Ge_UpdateAssets_I.Requests req = new Ge_UpdateAssets_I.Requests();
        req.oppProducts = oppLineItemList;
        req.assetList = a;
        req.wonOpportunity = opp;
        reqList.add(req);
        
        Test.StartTest();
        List<List<Asset>> res = Ge_UpdateAssets_I.updateAssets(reqList);
        
        test.stopTest();
    }

}