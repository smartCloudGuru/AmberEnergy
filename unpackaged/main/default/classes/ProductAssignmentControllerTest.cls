@isTest
public class ProductAssignmentControllerTest {
    
    @isTest(SeeAllData=true) 
    static void testOpportunitySuccess() {
        
        //create test user
        User testUser = TestData.createUser();
        insert testUser;
        
        System.runAs(testUser){
        
            //create an account
            Account testAccount = TestData.createClientAccount();
            insert testAccount;
            
            //create an opportunity
            Opportunity testOpp = TestData.createNormalOpportunity(testAccount.Id,testUser.Id);
            insert testOpp;
            system.debug('testOpp.Id = '+testOpp.Id);
            
            //create some initial Opportunity Products
            
            List<Product2> products = [SELECT id,productCode from Product2 where isActive = true and (ProductCode='PR5' OR ProductCode='PR4')]; 
            system.debug('products:'+products);
            
            Map<String,Id> priceEntrytIdMap = new Map<String,Id>();
            List<PriceBookEntry> priceEntries = [SELECT Id,ProductCode FROM PriceBookEntry where ProductCode != null ];
            for( PriceBookEntry entry : priceEntries){
                priceEntrytIdMap.put(entry.productCode,entry.Id);
            } 
             
            List<OpportunityLineItem> testOppProds = new List<OpportunityLineItem>();
       
            for (Product2 product : products){
                OpportunityLineItem tempOppProd = new OpportunityLineItem();
                tempOppProd.pricebookEntryId = priceEntrytIdMap.get(product.productCode);
                tempOppProd.UnitPrice = 100;
                tempOppProd.ServiceDate = system.today();
                tempOppProd.Quantity = 1;
                tempOppProd.Product2Id = product.Id;
                tempOppProd.OpportunityId = testOpp.Id;
                tempOppProd.Contract_End_Date__c = system.today(); 
                testOppProds.add(tempOppProd);
            }
            system.debug('attempt testOppProds insert:'+testOppProds);
            insert testOppProds;    
            system.debug('test testOppProds attached');
            
            ProductAssignmentController.ConfigWrapper config = ProductAssignmentController.getConfig(testOpp.Id, 'Opportunity');
            
            config.productList.get(0).percentage = 60;
            
            ProductAssignmentController.SaveResultWrapper result =  ProductAssignmentController.assignProducts(testOpp.Id, 'Opportunity', 
                                                                                                               config.productList, true, false, config.totalValue, 
                                                                                                               Date.today(), Date.today());
            
            result =  ProductAssignmentController.assignProducts(testOpp.Id, 'Opportunity', 
                                                                 config.productList, false, true, config.totalValue, 
                                                                 Date.today(), Date.today());
                
            /*
            PageReference pageRef = Page.ProductPercentages;
            test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('oppId',testOpp.Id);
            ProductPercentagesCtrl ctrl = new ProductPercentagesCtrl();
            
            String oppParamId = ApexPages.currentPage().getParameters().get('oppId');
            System.assertnotequals(oppParamId,null);
            
            //set some new values
            
            ctrl.usePerc = true;
            ctrl.useValue = false;
            ctrl.totalValue = 2000;
                
            ctrl.tempProdMap.get('P2').percentage = 20;
            ctrl.tempProdMap.get('C2').percentage = 20;
            ctrl.tempProdMap.get('PR1').percentage = 20;        
            ctrl.tempProdMap.get('P2').startdate = system.today();
            ctrl.tempProdMap.get('C2').startdate = system.today();
            ctrl.tempProdMap.get('PR1').startdate = system.today();
            ctrl.tempProdMap.get('P2').enddate = system.today();
            ctrl.tempProdMap.get('C2').enddate = system.today();
            ctrl.tempProdMap.get('PR1').enddate = system.today();
            
            //need to make sure to replace these 2 values as they already exist from pre create()
            ctrl.tempProdMap.get('PR4').percentage = 20;
            ctrl.tempProdMap.get('PR5').percentage = 20;
            ctrl.tempProdMap.get('PR4').startdate = system.today();
            ctrl.tempProdMap.get('PR5').startdate = system.today();
            ctrl.tempProdMap.get('PR4').enddate = system.today();
            ctrl.tempProdMap.get('PR5').enddate = system.today();
            
            ctrl.create();
            
            
            ctrl.usePerc = false;
            ctrl.useValue = true;
            
            ctrl.tempProdMap.get('P1').value = 100; 
            ctrl.tempProdMap.get('P2').value = 100;
            ctrl.tempProdMap.get('C2').value = 100;
            ctrl.tempProdMap.get('PR1').value = 100;
            ctrl.tempProdMap.get('P1').startdate = system.today();  
            ctrl.tempProdMap.get('P2').startdate = system.today();
            ctrl.tempProdMap.get('C2').startdate = system.today();
            ctrl.tempProdMap.get('PR1').startdate = system.today();
            ctrl.tempProdMap.get('P1').enddate = system.today();    
            ctrl.tempProdMap.get('P2').enddate = system.today();
            ctrl.tempProdMap.get('C2').enddate = system.today();
            ctrl.tempProdMap.get('PR1').enddate = system.today();
            //need to make sure to replace these 2 values as they already exist from pre create()
            ctrl.tempProdMap.get('PR4').value = 100;
            ctrl.tempProdMap.get('PR5').value = 100;
            ctrl.tempProdMap.get('PR4').startdate = system.today(); 
            ctrl.tempProdMap.get('PR5').startdate = system.today();
            ctrl.tempProdMap.get('PR4').enddate = system.today();
            ctrl.tempProdMap.get('PR5').enddate = system.today();
            
            ctrl.create();
            */
            
        }     
    }
    
    
    @isTest(SeeAllData=true) 
    static void testSLASuccess() {
        
        //create test user
        User testUser = TestData.createUser();
        insert testUser;
        
        System.runAs(testUser){
        
            //create an account
            Account testAccount = TestData.createClientAccount();
            insert testAccount;
            
            //create an opportunity
            SLA__c testSLA = new SLA__c(account__c = testAccount.Id,value_of_sla__c=1000);
            insert testSLA;
            
            //create some initial SLA Products  
            List<Product2> products = [SELECT id,productCode from Product2 where isActive = true and (ProductCode='PR5' OR ProductCode='PR4')]; 
            system.debug('products:'+products);
                 
            List<SLA_Product__c> testSlaProds = new List<SLA_Product__c>();
       
            for (Product2 product : products){
                SLA_Product__c tempSlaProd = new SLA_Product__c();
                tempSlaProd.value__c = 200;
                tempSlaProd.End_Date__c = system.today(); 
                tempSlaProd.start_date__c = system.today();
                tempSlaProd.Product__c = product.Id;
                tempSlaProd.SLA__c = testSLA.Id;        
                testSlaProds.add(tempSlaProd);
            }
            
            system.debug('attempt testSlaProds insert:'+testSlaProds);
            insert testSlaProds;    
            system.debug('test testSlaProds attached');
            
            ProductAssignmentController.ConfigWrapper config = ProductAssignmentController.getConfig(testSLA.Id, 'SLA__c');
            
            config.productList.get(0).percentage = 60;
            
            ProductAssignmentController.SaveResultWrapper result =  ProductAssignmentController.assignProducts(testSLA.Id, 'SLA__c', 
                                                                                                               config.productList, true, false, config.totalValue, 
                                                                                                               Date.today(), Date.today());
            
            result =  ProductAssignmentController.assignProducts(testSLA.Id, 'SLA__c', 
                                                                 config.productList, false, true, config.totalValue, 
                                                                 Date.today(), Date.today());
            
            /*
            PageReference pageRef = Page.ProductPercentages;
            test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('slaId',testSla.Id);
            ProductPercentagesCtrl ctrl = new ProductPercentagesCtrl();
            
            String slaParamId = ApexPages.currentPage().getParameters().get('slaId');
            System.assertnotequals(slaParamId,null);
            
            //set some new values
            
            ctrl.usePerc = true;
            ctrl.useValue = false;
            ctrl.totalValue = 2000;
                
            ctrl.tempProdMap.get('P2').percentage = 20;
            ctrl.tempProdMap.get('C2').percentage = 20;
            ctrl.tempProdMap.get('PR1').percentage = 20;        
            ctrl.tempProdMap.get('P2').startdate = system.today();
            ctrl.tempProdMap.get('C2').startdate = system.today();
            ctrl.tempProdMap.get('PR1').startdate = system.today();
            ctrl.tempProdMap.get('P2').enddate = system.today();
            ctrl.tempProdMap.get('C2').enddate = system.today();
            ctrl.tempProdMap.get('PR1').enddate = system.today();
            
            //need to make sure to replace these 2 values as they already exist from pre create()
            ctrl.tempProdMap.get('PR4').percentage = 20;
            ctrl.tempProdMap.get('PR5').percentage = 20;
            ctrl.tempProdMap.get('PR4').startdate = system.today();
            ctrl.tempProdMap.get('PR5').startdate = system.today();
            ctrl.tempProdMap.get('PR4').enddate = system.today();
            ctrl.tempProdMap.get('PR5').enddate = system.today();
            
            ctrl.create();
           
            ctrl.usePerc = false;
            ctrl.useValue = true;
            
            ctrl.tempProdMap.get('P1').value = 100; 
            ctrl.tempProdMap.get('P2').value = 100;
            ctrl.tempProdMap.get('C2').value = 100;
            ctrl.tempProdMap.get('PR1').value = 100;
            ctrl.tempProdMap.get('P1').startdate = system.today();  
            ctrl.tempProdMap.get('P2').startdate = system.today();
            ctrl.tempProdMap.get('C2').startdate = system.today();
            ctrl.tempProdMap.get('PR1').startdate = system.today();
            ctrl.tempProdMap.get('P1').enddate = system.today();    
            ctrl.tempProdMap.get('P2').enddate = system.today();
            ctrl.tempProdMap.get('C2').enddate = system.today();
            ctrl.tempProdMap.get('PR1').enddate = system.today();
            //need to make sure to replace these 2 values as they already exist from pre create()
            ctrl.tempProdMap.get('PR4').value = 100;
            ctrl.tempProdMap.get('PR5').value = 100;
            ctrl.tempProdMap.get('PR4').startdate = system.today(); 
            ctrl.tempProdMap.get('PR5').startdate = system.today();
            ctrl.tempProdMap.get('PR4').enddate = system.today();
            ctrl.tempProdMap.get('PR5').enddate = system.today();
            
            ctrl.create();
            */
        }     
    }
    /*
    static testMethod void testOpportunityError() {
        
        ProductPercentagesCtrl ctrl = new ProductPercentagesCtrl();
        
        //do something total wrong to generate an exception
        Opportunity o = new Opportunity();
        try{
            insert o;
        }catch(Exception e){
            ctrl.reportFatalError(e);   
        }   
    }
    */
    @isTest 
    static void testBundleAndContractAssignment() {
        
        TestData.setupProductsAndPriceBooks();
        
        //create test user
        User testUser = TestData.createUser();
        insert testUser;
        
        System.runAs(testUser){
        
            //create an account
            Account testAccount = TestData.createClientAccount();
            insert testAccount; 
            
            //create an Opportunity with Products linked to a contract
            
            
            Contract testContract = new Contract();
            testContract.name = 'TestContract';
            testContract.startDate = system.today();
            testContract.endDate = system.today()+365;
            testContract.AccountId = testAccount.Id;
            insert testContract;
            
            
            Opportunity initTestOpp = TestData.createNormalOpportunity(testAccount.Id,testUser.Id);
            initTestOpp.ContractId = testContract.Id;
            insert initTestOpp;
            system.debug('initTestOpp.Id = '+initTestOpp.Id);
            
            //create some initial Opportunity Products
            
            List<Product2> products = [SELECT id,productCode from Product2 where isActive = true and (ProductCode='PR5' OR ProductCode='PR4')]; 
            system.debug('products:'+products);
            
            Map<String,Id> priceEntrytIdMap = new Map<String,Id>();
            List<PriceBookEntry> priceEntries = [SELECT Id,ProductCode FROM PriceBookEntry where ProductCode != null ];
            for( PriceBookEntry entry : priceEntries){
                priceEntrytIdMap.put(entry.productCode,entry.Id);
            } 
             
            List<OpportunityLineItem> testOppProds = new List<OpportunityLineItem>();
       
            for (Product2 product : products){
                OpportunityLineItem tempOppProd = new OpportunityLineItem();
                tempOppProd.pricebookEntryId = priceEntrytIdMap.get(product.productCode);
                tempOppProd.UnitPrice = 100;
                tempOppProd.ServiceDate = system.today();
                tempOppProd.Quantity = 1;
                tempOppProd.Product2Id = product.Id;
                tempOppProd.OpportunityId = initTestOpp.Id;
                tempOppProd.Contract_End_Date__c = system.today(); 
                testOppProds.add(tempOppProd);
            }
            system.debug('attempt testOppProds insert:'+testOppProds);
            insert testOppProds;    
            system.debug('test testOppProds attached');
            
            
            
            
                
            /*
            //create an SLA
            SLA__c testSLA = new SLA__c(account__c = testAccount.Id,value_of_sla__c=1000);
            insert testSLA;
            
            //create some initial SLA Products  
            List<Product2> slaproducts = [SELECT id,productCode from Product2 where isActive = true and (ProductCode='PR5' OR ProductCode='PR4')]; 
            system.debug('slaproducts:'+slaproducts);
                 
            List<SLA_Product__c> testSlaProds = new List<SLA_Product__c>();
       
            for (Product2 product : slaproducts){
                SLA_Product__c tempSlaProd = new SLA_Product__c();
                tempSlaProd.value__c = 200;
                tempSlaProd.End_Date__c = system.today(); 
                tempSlaProd.start_date__c = system.today();
                tempSlaProd.Product__c = product.Id;
                tempSlaProd.SLA__c = testSLA.Id;        
                testSlaProds.add(tempSlaProd);
            }
            insert testSlaProds;
            */
                                
            //create an opportunity
            Opportunity testOpp = TestData.createNormalOpportunity(testAccount.Id,testUser.Id);
            testOpp.ContractId = testContract.Id;
            insert testOpp;
            system.debug('testOpp.Id = '+testOpp.Id);
                        
            PageReference pageRef = Page.ProductPercentages;
            test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('oppId',testOpp.Id);
            ProductPercentagesCtrl ctrl = new ProductPercentagesCtrl();
            
            String oppParamId = ApexPages.currentPage().getParameters().get('oppId');
            System.assertnotequals(oppParamId,null);
            
            ProductAssignmentController.SaveResultWrapper result = ProductAssignmentController.assignLite(testOpp.Id, 'Opportunity');
            result = ProductAssignmentController.assignPremier(testOpp.Id, 'Premier');
            result = ProductAssignmentController.assignPlus(testOpp.Id, 'Plus');
            result = ProductAssignmentController.assignSLAProducts(testOpp.Id, 'Opportunity', false, true);
                
            DmlException e = new DmlException();
            e.setMessage('test');
            ProductAssignmentController.reportFatalError(e);
            ProductAssignmentController.reportFatalError('desription', 'sub');
                
            /*
            //set some new values
            
            ctrl.usePerc = true;
            ctrl.useValue = false;
            ctrl.totalValue = 2000;
            
            ctrl.assignLite();
            ctrl.assignPlus();
            ctrl.assignPremier();
            ctrl.assignSLAProducts();
            */

        }     
    }
    
    
}