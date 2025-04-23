/* Class for static methods that can be used by test classes to create data
*/
public without sharing class TestData {
    
    public static RecordType bureauType = [Select Id from RecordType where DeveloperName='Cases_for_Cusomer_Queries_and_Complaints' and SobjectType='Case'];
    public static RecordType clientAccountRecType = [Select Id from RecordType where SobjectType='Account' and DeveloperName='Client'];
    public static RecordType supplierAccountRecType = [Select Id from RecordType where SobjectType='Account' and DeveloperName='Supplier'];
    public static RecordType oppNormalRecType = [Select Id from RecordType where SobjectType='Opportunity' and DeveloperName='Normal'];
    public static RecordType oppNewBusRecType = [Select Id from RecordType where SobjectType='Opportunity' and DeveloperName='New_Business'];
    public static RecordType oppALTRecType = [Select Id from RecordType where SobjectType='Opportunity' and DeveloperName='ALT'];
    public static RecordType NormTaskRecType = [SELECT Id from RecordType where SobjectType='Task' and DeveloperName='General' LIMIT 1];
    public static RecordType ProcOrderRecType = [SELECT Id from RecordType where SobjectType='Order' and DeveloperName='Procurement' LIMIT 1];
    public static RecordType generalLeadRecType = [SELECT Id from RecordType where SobjectType='Lead' and DeveloperName='General' LIMIT 1];
    public static RecordType COT_ORDER_REC_TYPE = [SELECT Id from RecordType where SobjectType='Order' and DeveloperName='COT' LIMIT 1];
    public static RecordType DCDA_METERCONTRACT = [SELECT Id from RecordType where SobjectType='Meter_Contract__c' and DeveloperName='DCDA' LIMIT 1];

    //public static map that can be used to get record types
    public static Map<String,Id> recordTypeMap;
    
    /** CONSTRUCTOR */
    
    public TestData(){
        
        recordTypeMap = new Map<String,Id>();
        List<RecordType> allTypes = [Select Id,SobjectType,DeveloperName from RecordType];
        for(RecordType rt : allTypes){
            recordTypeMap.put(rt.SobjectType+'-'+rt.DeveloperName,rt.Id); 
        }
    }
    
    public static void setupCustomSettings(){
        
        E2C__c e2c = new E2C__c();
        e2c.Days_to_Reply_to_Case__c = 2;
        e2c.Days_to_Reply_to_Reply__c = 2;
        e2c.Days_to_Reply_to_Case_High_Priority__c = 1;
        e2c.Days_to_Reply_to_Reply_High_Priority__c = 1;
        insert e2c;  
        
        ALT__c alt = new ALT__c();
        alt.ALT_Rating_Price_Weighting__c = 95;
        alt.ALT_Rating_Supplier_Weighting__c = 5;
        alt.Elec_In_Contract_Factor__c = 0.13;
        alt.Elec_Out_Of_Contract_Factor__c = 0.18;
        alt.Gas_In_Contract_Factor__c = 0.3;
        alt.Gas_Out_Of_Contract_Factor__c = 0.5;
        alt.QUOTES_PER_UTIL__c = 5;
        insert alt;
    }
    
    public static Id setupProductsAndPriceBooks(){
        
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id=priceBookId,IsActive = true);
        // Run an update DML on the Pricebook2 record
        // This is the weird workaround that enables IsStandard to become true
        // on the PricebookEntry record
        update standardPricebook;
        
        List<Product2> productsToInsert = new List<Product2>();
        List<PricebookEntry> pricesToInsert = new List<PricebookEntry>();
        
        productsToInsert.add(new Product2(Name = 'P1',ProductCode='P1',Family='Procurement',isActive=true,Benefit__c='test',Summary__c='test'));
        productsToInsert.add(new Product2(Name = 'P2',ProductCode='P2',Family='Procurement',isActive=true,Benefit__c='test',Summary__c='test'));
        productsToInsert.add(new Product2(Name = 'P3',ProductCode='P3',Family='Procurement',isActive=true,Benefit__c='test',Summary__c='test'));
        productsToInsert.add(new Product2(Name = 'C1',ProductCode='C1',Family='Connections',isActive=true,Benefit__c='test',Summary__c='test'));
        productsToInsert.add(new Product2(Name = 'C2',ProductCode='C2',Family='Connections',isActive=true,Benefit__c='test',Summary__c='test'));
        productsToInsert.add(new Product2(Name = 'C3',ProductCode='C3',Family='Connections',isActive=true,Benefit__c='test',Summary__c='test'));
        productsToInsert.add(new Product2(Name = 'B1',ProductCode='B1',Family='Bureau',isActive=true,Benefit__c='test',Summary__c='test'));
        productsToInsert.add(new Product2(Name = 'B2',ProductCode='B2',Family='Bureau',isActive=true,Benefit__c='test',Summary__c='test'));
        productsToInsert.add(new Product2(Name = 'B3',ProductCode='B3',Family='Bureau',isActive=true,Benefit__c='test',Summary__c='test'));
        productsToInsert.add(new Product2(Name = 'W1',ProductCode='W1',Family='Water',isActive=true,Benefit__c='test',Summary__c='test'));
        productsToInsert.add(new Product2(Name = 'W2',ProductCode='W2',Family='Water',isActive=true,Benefit__c='test',Summary__c='test'));
        productsToInsert.add(new Product2(Name = 'W3',ProductCode='W3',Family='Water',isActive=true,Benefit__c='test',Summary__c='test'));
        productsToInsert.add(new Product2(Name = 'PR1',ProductCode='PR1',Family='Projects',isActive=true,Benefit__c='test',Summary__c='test'));
        productsToInsert.add(new Product2(Name = 'PR2',ProductCode='PR2',Family='Projects',isActive=true,Benefit__c='test',Summary__c='test'));
        productsToInsert.add(new Product2(Name = 'PR3',ProductCode='PR3',Family='Projects',isActive=true,Benefit__c='test',Summary__c='test'));
        productsToInsert.add(new Product2(Name = 'PR4',ProductCode='PR4',Family='Projects',isActive=true,Benefit__c='test',Summary__c='test'));
        productsToInsert.add(new Product2(Name = 'PR5',ProductCode='PR5',Family='Projects',isActive=true,Benefit__c='test',Summary__c='test'));
        productsToInsert.add(new Product2(Name = 'E1',ProductCode='E1',Family='Engineering',isActive=true,Benefit__c='test',Summary__c='test'));
        productsToInsert.add(new Product2(Name = 'E2',ProductCode='E2',Family='Engineering',isActive=true,Benefit__c='test',Summary__c='test'));
        productsToInsert.add(new Product2(Name = 'E3',ProductCode='E3',Family='Engineering',isActive=true,Benefit__c='test',Summary__c='test'));
        productsToInsert.add(new Product2(Name = 'ALT',ProductCode='ALT',Family='ALT',isActive=true,Benefit__c='test',Summary__c='test'));
        productsToInsert.add(new Product2(Name = 'PCOT',ProductCode='PCOT',Family='Procurement',isActive=true,Benefit__c='test',Summary__c='test'));        
        insert productsToInsert;
        system.debug('productsToInsert:'+productsToInsert);
        
        for(Product2 prod : productsToInsert){
            pricesToInsert.add(new PricebookEntry(Product2Id=prod.Id,Pricebook2Id=pricebookId,UnitPrice=0,IsActive=true));
        }   
        insert pricesToInsert;
        system.debug('pricesToInsert:'+pricesToInsert);
        
        //create bundles
        List<Bundle__c> bundles = new List<Bundle__c>();
        bundles.add(new Bundle__c(name='Lite'));
        bundles.add(new Bundle__c(name='Plus'));
        bundles.add(new Bundle__c(name='Premier'));
        insert bundles;
        
        //create bundle products
        List<Bundle_product__c> bundleProducts = new List<Bundle_product__c>();
        bundleProducts.add(new Bundle_product__c(bundle__c=bundles.get(0).Id,Product__c=productsToInsert.get(0).Id));
        bundleProducts.add(new Bundle_product__c(bundle__c=bundles.get(1).Id,Product__c=productsToInsert.get(1).Id));
        bundleProducts.add(new Bundle_product__c(bundle__c=bundles.get(2).Id,Product__c=productsToInsert.get(2).Id));
        insert bundleProducts;
                    
        return priceBookId;
    }
    
    public static void createBundlesFromProducts(){
        
        //create bundles
        List<Bundle__c> bundles = new List<Bundle__c>();
        bundles.add(new Bundle__c(name='Lite'));
        bundles.add(new Bundle__c(name='Plus'));
        bundles.add(new Bundle__c(name='Premier'));
        insert bundles;
        
        List<Product2> products = [SELECT Id FROM Product2 WHERE isActive = TRUE];
        
        //create bundle products
        List<Bundle_product__c> bundleProducts = new List<Bundle_product__c>();
        bundleProducts.add(new Bundle_product__c(bundle__c=bundles.get(0).Id,Product__c=products.get(0).Id));
        bundleProducts.add(new Bundle_product__c(bundle__c=bundles.get(1).Id,Product__c=products.get(1).Id));
        bundleProducts.add(new Bundle_product__c(bundle__c=bundles.get(2).Id,Product__c=products.get(2).Id));
        bundleProducts.add(new Bundle_product__c(bundle__c=bundles.get(0).Id,Product__c=products.get(3).Id));
        bundleProducts.add(new Bundle_product__c(bundle__c=bundles.get(1).Id,Product__c=products.get(4).Id));
        bundleProducts.add(new Bundle_product__c(bundle__c=bundles.get(2).Id,Product__c=products.get(5).Id));
        insert bundleProducts;
        
    }
    
    public static User createUser(){
        Integer randomInt = Math.mod(Math.round(Math.random()*1000),1000);
        String usrName = 'test'+randomInt+'@testamberenergy.net';
        Profile profile = [Select Id from Profile where name='amber energy user'];
        User u = new User(LastName='Tester',alias='TSTR',email=usrName,username=usrName,CommunityNickname='Tstr'+randomInt,profileId=profile.Id,
                        TimeZoneSidKey='GMT', LocaleSidKey='en_GB', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        system.debug('createUser:'+u);
        return u;
    }
        
    public static User createAdmin(){
        Integer randomInt = Math.mod(Math.round(Math.random()*1000),1000);
        String usrName = 'testadm'+randomInt+'@testamberenergy.net';
        Profile profile = [Select Id from Profile where Name='System Administrator'];
        User u = new User(LastName='Tester',alias='TSTR',email=usrName,username=usrName,CommunityNickname='Adm'+randomInt,profileId=profile.Id,
                        TimeZoneSidKey='GMT', LocaleSidKey='en_GB', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        system.debug('createUser:'+u);
        return u;
    }
    
    public static Account createClientAccount(){
        return new Account(Name = 'testAccount',recordTypeId=clientAccountRecType.Id,Service_Project__c='Other');       
    }
    
    public static List<Account> createClientAccounts(integer counter){  
        List<Account> accounts = new List<Account>();
        for(integer i = 0; i < counter ; i++){      
            accounts.add(new Account(Name='testAccount'+i,recordTypeId=clientAccountRecType.Id,Service_Project__c='Other'));
        }
        return accounts;
    }
    
    public static Opportunity createNormalOpportunity(Id acctId, Id oppManagerId){
        return new Opportunity(Name='TestNormalOpp',AccountId=acctId,recordTypeId=oppNormalRecType.Id,Opportunity_Co_ordinator__c=oppManagerId,Likelihood_of_Closure__c='High',
                    Amount=100,CloseDate=system.today(),StageName='Discovery',Opportunity_Type__c='New Business',payment_method__c='Commission',approval_exempt__c=true,Exemption_Reason__c='True');    
    }
    
    public static Opportunity createNewBusinessOpportunity(Id acctId){
        return new Opportunity(Name='TestNewBusinessOpp',AccountId=acctId,recordTypeId=oppNewBusRecType.Id,Likelihood_of_Closure__c='High',
                    Amount=100,CloseDate=system.today(),StageName='Discovery',payment_method__c='Commission',approval_exempt__c=true,Exemption_Reason__c='True');   
    }
    
    public static Opportunity createALTOpportunity(Id acctId){
        return new Opportunity(Name='TestALTOpp',recordtypeid=oppALTRecType.Id,CloseDate=system.today(),
                                    StageName='Solution',Opportunity_Type__c='New Business',accountId=acctId,approval_exempt__c=true,Exemption_Reason__c='True'); 
    }
    
    public static Case createCase(){
        return new case();
    }
    
    public static Case createCommunityCase(){
        RecordType rt = [SELECT Id from RecordType where SobjectType = 'Case' and developerName = 'COMM_UNITY'];
        
        Account a = TestData.createClientAccount();
        insert a;
        
        Site__c s = new Site__c(name='TestSite',operator__c=a.id,account__c=a.id);
        insert s;
        
        Case newCase = TestData.createCase();
        newCase.recordTypeId = rt.id;
        newCase.Follow_up_Action_Date__c = system.today();
        newCase.Landlord_Resident__c = 'Landlord';
        newCase.reason = 'Move In';
        newCase.site__c = s.Id;

        return newCase;
    }
    
    public static Case createBureauQueryCase(){
        Case newCase = new Case();
        newCase.status = 'Not Started';
        newCase.Follow_up_Action_Date__c = system.today();  
        newCase.recordTypeId = bureauType.Id;
        newCase.subject = 'Bureau Test Query';
        newCase.Department__c = 'Bureau';
        newCase.reason = 'Metering';
        return newCase;
    }
    
    public static OpportunityLineItem createOpportunityProduct(Id productId, Id priceId, Id OpportunityId, decimal price){  
        OpportunityLineItem oppProduct = new OpportunityLineItem();
        oppProduct.serviceDate = system.today();
        oppProduct.contract_end_date__c = system.today()+1;
        oppProduct.Product2Id = productId;
        oppProduct.opportunityId = OpportunityId;
        oppProduct.pricebookEntryId = priceId;
        oppProduct.quantity = 1;
        oppProduct.unitprice = price;       
        return oppProduct;
    }
    
    public static Task createNormalTask(Id parentId, Id assignedTo){    
        Task t = new Task();
        t.recordTypeId = NormTaskRecType.Id;
        t.ActivityDate = system.today();
        t.whatId = parentId;
        t.ownerId = assignedTo;
        t.priority = 'Normal';
        t.status = 'Not Started';
        t.subject = 'Test';     
        return t;
    }
    
    public static EmailMessage createIncomingEmail(Id emailParentId){
        EmailMessage newEmail = new EmailMessage(parentId = emailParentId);
        newEmail.incoming = true;
        newEmail.ToAddress = 'sometestaddress@test.com';
        newEmail.Subject = 'I am a test email';
        newEmail.MessageDate = system.today(); 
        newEmail.FromName = 'Williamso';
        newEmail.FromAddress = 'someemailaddress@test.com';
        newEmail.textBody = 'Here is my text body!';
        return newEmail;
    }
    
    public static Order createProcOrder(Id oppId, Id acctId){
        Order newOrder = new Order(OpportunityId = oppId);
        newOrder.recordTypeId = ProcOrderRecType.Id;
        newOrder.accountId = acctId;
        newOrder.status = 'In Progress';
        newOrder.EffectiveDate = system.today();
        return newOrder; 
    }
    
    public static Meter_Linking_Detail__c createMeterContract(Id oppId, Id meterId, Id supplierId){
            
        Meter_Linking_Detail__c newMC = new Meter_Linking_Detail__c();
        newMC.Opportunity__c = oppId;
        newMC.Meter_Detail__c = meterId;
        newMC.new_energy_supplier__c = supplierId;
        newMC.current_energy_supplier__c = supplierId;
        newMc.New_Energy_Contract_End_Date__c = system.today();
        newMc.New_Energy_Contract_Start_Date__c = system.today();
        newMc.Capacity__c = 1;
        newMc.New_Supplier_Fixed_Rate__c = 'RO';
        newMc.Product_Type__c = 'Fix Tracker';
        newMc.Payment_Method__c = 'Supplier Standing Charge';
        newMc.Standing_Charge__c = 1;
                
        return newMC; 
    }
    
    public static List<Account> insertSmeSuppliers(){   
            
        List<Account> smeSuppliers = new List<Account>();
        
        smeSuppliers.add(createSmeSupplier('AvantiGas SME','bristolLogo'));
        smeSuppliers.add(createSmeSupplier('Bristol Energy SME','bristolLogo'));
        smeSuppliers.add(createSmeSupplier('British Gas Lite SME','bristolGasLogo'));
        smeSuppliers.add(createSmeSupplier('British Gas SME','bristolGasLogo'));
        smeSuppliers.add(createSmeSupplier('CNG SME','cngLogo'));
        smeSuppliers.add(createSmeSupplier('Corona Energy SME','coronaLogo'));
        smeSuppliers.add(createSmeSupplier('Crown SME','cornwLogo'));
        smeSuppliers.add(createSmeSupplier('D-Energi SME','dongLogo'));
        smeSuppliers.add(createSmeSupplier('Dong SME','dongLogo'));
        smeSuppliers.add(createSmeSupplier('Dual Energy SME','dualEnergyLogo'));
        smeSuppliers.add(createSmeSupplier('E-ON SME','eonLogo'));
        smeSuppliers.add(createSmeSupplier('EDF SME','edfLogo'));
        smeSuppliers.add(createSmeSupplier('Engie SME','engieLogo'));
        smeSuppliers.add(createSmeSupplier('Gazprom SME','gazpromLogo'));
        smeSuppliers.add(createSmeSupplier('Green Network Energy SME','greenNetworkLogo'));
        smeSuppliers.add(createSmeSupplier('Gulf Gas and Power SME','gulfGasLogo'));
        smeSuppliers.add(createSmeSupplier('Haven SME','havenLogo'));
        smeSuppliers.add(createSmeSupplier('Hudson Energy SME','hudsonLogo'));
        smeSuppliers.add(createSmeSupplier('Npower SME','npowerLogo'));
        smeSuppliers.add(createSmeSupplier('Opus SME','opusLogo'));
        smeSuppliers.add(createSmeSupplier('Orsted SME','orstedLogo'));
        smeSuppliers.add(createSmeSupplier('Scottish And Southern SME','sseNewLogo'));
        smeSuppliers.add(createSmeSupplier('Scottish Power SME','scottishPowerLogo'));
        smeSuppliers.add(createSmeSupplier('Simple Gas SME','sqakyLogo'));
        smeSuppliers.add(createSmeSupplier('Squeaky Clean SME','sqakyLogo')); 
        smeSuppliers.add(createSmeSupplier('Total Gas And Power SME','tgpLogo'));
        smeSuppliers.add(createSmeSupplier('Utilita SME','utilitaLogo'));
        smeSuppliers.add(createSmeSupplier('Yorkshire Gas And Power SME','ygpLogo'));

        insert smeSuppliers;
        
        for(Account sup : smeSuppliers){
            sup.Supplier_ALT_Rating__c=9;
        }
        update smeSuppliers;
        
        return smeSuppliers;
        
    }
     
    public static Account createSmeSupplier(String nameForSupplier, String logoName){       
        return new Account(Name=nameForSupplier,recordTypeId=supplierAccountRecType.Id,Logo_Link__c=logoName ); 
    }
    
    public static Meter_Details__c createElectricMeter(Id accId){
        String randomNumber = String.valueof(Integer.valueof((Math.random() * 1000000)));
        RecordType elecType = [SELECT Id FROM RecordType WHERE sObjectType='Meter_Details__c' AND developerName='Electricity'];
        Meter_Details__c testMeter = new Meter_Details__c(name=randomNumber,Bottom_Line__c=randomNumber,Account__c=accId,
                                                        Meter_Status__c='Active',Top_Line_MPAN__c='03 801 200',recordtypeid=elecType.Id);
        return testMeter;  
    }
    
    public static Meter_Details__c createGasMeter(Id accId){
        String randomNumber = String.valueof(Integer.valueof((Math.random() * 1000000)));
        RecordType gasType = [SELECT Id FROM RecordType WHERE sObjectType='Meter_Details__c' AND developerName='Gas'];
        Meter_Details__c testMeter = new Meter_Details__c(name=randomNumber,MPRN__c=randomNumber,Account__c=accId,
                                                        Meter_Status__c='Active',recordTypeId=gasType.Id);
        return testMeter; 
        
    }
    
    public static Tender__c createTender(Id accId, Id oppId, Id userId){
        return new Tender__c(Account__c = accId, name='testTender',Stage__c='RFI',next_action_due__c=system.today(),
                                ownerId=userId,coordinator__c=userid,associated_Rm__c=userid,Opportunity__c=oppId,
                                is_new_business__c='Yes',Direct_Debit_Mandate__c='Yes');
    }
    
    
    public static Supply_Contract__c createSupplyContract(Id meterId, Id tenderId, decimal commission, Id supplierId){
        return new Supply_Contract__c(Meter__c = meterId,Tender__c=tenderId,contract_start_date__c=system.today(),Is_Unit_Test__c =true,
                                    contract_end_date__c=system.today()+99,standing_charge_commission_p_day__c=commission,
                                    commission_payment_method__c='Supplier Standing Charge',Energy_Supplier__c=supplierId,
                                    Product_Type__c='Fix Tracker',Tariff_Type__c='Single Rate',Non_Commodity_Type__c='Fixed');
    }
    
    public static Supply_Contract__c createSupplyContract(Id meterId, Id tenderId, Id supplierId, Date endDate){
        return new Supply_Contract__c(Meter__c = meterId,Tender__c=tenderId,contract_start_date__c=system.today(),Is_Unit_Test__c =true,
                                    contract_end_date__c=endDate,standing_charge_commission_p_day__c=100,
                                    commission_payment_method__c='Supplier Standing Charge',Energy_Supplier__c=supplierId,
                                    Product_Type__c='Fix Tracker',Tariff_Type__c='Single Rate',Non_Commodity_Type__c='Fixed');
    }
       
    public static Lead createLead(){
        return new Lead(RecordTypeId = generalLeadRecType.Id, Status = 'Targeting', LastName = 'testLeadName',Company = 'testCompany',
                        LeadSource = 'Offline', Campaign_Type__c = 'Award', Vertical_Sector__c = 'Property');
    }
    
    public static Contracting_Entity1__c createContractingEntity(Id accId){
        return new Contracting_Entity1__c(Name = 'Test Contracting Entity', Status__c = 'Active', Account__c = accId, 
                                            Company_Registration_Number__c = 'Test Reg Number', Address__c = 'Test Address');
    }
    
    public static Order createCOTOrder(Id accountId, Id contractingEntityId, Id opportunityId){
        return new Order(AccountId = accountId,OpportunityId = opportunityId,RecordTypeId = COT_ORDER_REC_TYPE.Id,
                                            Incoming_Contracting_Entity__c = contractingEntityId,Outgoing_Contracting_Entity__c = contractingEntityId,
                                            EffectiveDate = system.today(),Status = 'Not Started',COT_Type__c = 'COT In',Name__c = 'Test COT | Elec | DEC 19');
    }
    
    public static Meter_Contract__c createNewMeterContract(Id supplierId, Id meterId){
        return new Meter_Contract__c(Start_Date__c=system.today(), End_Date__c=system.today(), Meter__c = meterId, 
                                        Supplier__c = supplierId, RecordTypeId = DCDA_METERCONTRACT.Id);
    }
    
}