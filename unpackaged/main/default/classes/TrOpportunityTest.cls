/**
 * Class to test the Opportunity business logic
 */
 
@isTest
private class TrOpportunityTest {
    
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
    }
    
    @isTest static void testOpportunityClosure() {
        //create test user
        User testUser = TestData.createAdmin();
        insert testUser;
        
        System.runAs(testUser){
            
            test.startTest();
                      
            //convert to won
            Opportunity testOpp = [Select Id,stageName,name from Opportunity where name = 'TestNormalOpp'];
            testOpp.stageName = 'Closed Won';
            update testOpp;
            
            //check orders have been created
            List<Order> newOrders = [SELECT Id from Order where OpportunityId = :testOpp.Id ];
            system.assertequals(1,newOrders.size());
            Order newOrder = newOrders.get(0);
            
            //check order products have been created
            List<OrderItem> newOrderProducts = [SELECT Id,orderId from OrderItem where OrderId =:newOrder.Id ];
            system.assertequals(false,newOrderProducts.isempty());
            
            //create a test deliverable to give the TrDeliverable class some coverage
            Job__c deliverable = new Job__c();
            deliverable.order_product__c = newOrderProducts.get(0).id;
            deliverable.order__c = newOrderProducts.get(0).orderId;
            deliverable.name = 'TestDel';
            insert deliverable;
            
            test.stopTest();
        }            
    }
    

    @isTest static void testOpportunityClosureExistingAssetsDontExtend() {
        //create test user
        User testUser = TestData.createAdmin();
        insert testUser;
        
        //insert existing asset
        Product2 product = [SELECT id,productCode from Product2 where isActive = true and ProductCode='E1' LIMIT 1];
        
        Opportunity testOpp = [Select Id,stageName,name,accountid from Opportunity where name = 'TestNormalOpp'];    
        
        System.runAs(testUser){
             
            test.startTest();
            
            Asset a = new Asset(name='Test',Product2Id=product.Id,UsageEndDate=system.today()+2,accountid=testOpp.accountid);  
        	insert a; 
                       
            //convert to won       
            testOpp.stageName = 'Closed Won';
            update testOpp;
            
            //check assets have been created
            List<Asset> newAssets = [SELECT Id,usageEndDate from Asset where AccountId = :testOpp.accountid ];
            system.assertequals(1,newAssets.size());
            system.assertequals(system.today()+2,newAssets.get(0).usageEndDate);
            
            test.stopTest();
        }            
    }
    
    @isTest static void testOpportunityClosureExistingAssetsExtend() {
        //create test user
        User testUser = TestData.createAdmin();
        insert testUser;
        
        //insert existing asset
        Product2 product = [SELECT id,productCode from Product2 where isActive = true and ProductCode='E1' LIMIT 1];
        
        Opportunity testOpp = [Select Id,stageName,name,accountid from Opportunity where name = 'TestNormalOpp'];    
        
        System.runAs(testUser){
             
            test.startTest();
            
            Asset a = new Asset(name='Test',Product2Id=product.Id,UsageEndDate=system.today(),accountid=testOpp.accountid);  
        	insert a; 
                       
            //convert to won       
            testOpp.stageName = 'Closed Won';
            update testOpp;
            
            //check assets have been created
            List<Asset> newAssets = [SELECT Id,usageEndDate from Asset where AccountId = :testOpp.accountid ];
            system.assertequals(1,newAssets.size());
            system.assertequals(system.today()+1,newAssets.get(0).usageEndDate);
            
            test.stopTest();
        }            
    }
    
}