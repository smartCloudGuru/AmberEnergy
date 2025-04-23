/**********************************************************************
Name:  Ge_TenderRecreateTenderProdsOnChange_T
Copyright © 2023
======================================================
======================================================
Purpose:  Test Class for the Ge_TenderRecreateTenderProductsOnChange class

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0      Lynn Mejos          13/03/2023     
***********************************************************************/
@isTest
public class Ge_TenderRecreateTenderProdsOnChange_T {

    @testSetup
    static void setup(){
		
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
        insert TestData.createOpportunityProduct(productP1.Id,priceP1.Id,testOpp.Id,60);
        insert TestData.createOpportunityProduct(productP1.Id,priceP1.Id,testOpp.Id,25);
        insert TestData.createOpportunityProduct(productP1.Id,priceP1.Id,testOpp.Id,15);
        
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
        
        Asset a = new Asset();
        a.name='Test';
        a.Product2Id=productP1.Id;
        a.UsageEndDate=system.today()+2;
        a.accountid=testOpp.accountid;  
        insert a;    
    }
    
    /**
     * @methodname - InvocableMethodTest
     * @description - To cover getNewTenderProducts method
     */
    @isTest 
    private static void InvocableMethodTest(){
        List<OPPORTUNITYLINEITEM> o = [SELECT ID, of_Total__c, product2id FROM OPPORTUNITYLINEITEM LIMIT 1];
        Tender__c t = [SELECT ID FROM Tender__c LIMIT 1];
        List<Supply_Contract__c> supContractList = [SELECT ID, contract_start_date__c, contract_end_date__c,Contract_Value__c FROM Supply_Contract__c];
        
        List<Ge_TenderRecreateTenderProductsOnChange.Requests> reqList = new List<Ge_TenderRecreateTenderProductsOnChange.Requests>();
        Ge_TenderRecreateTenderProductsOnChange.Requests req = new Ge_TenderRecreateTenderProductsOnChange.Requests();
        req.oppLineItemList = o;
        req.tenderRecord = t;
        req.tenderSupContracts = supContractList;
        reqList.add(req);
        
        Test.StartTest();
        List<List<Tender_Product__c>> res = Ge_TenderRecreateTenderProductsOnChange.getNewTenderProducts(reqList);
        
        test.stopTest();
    }

}