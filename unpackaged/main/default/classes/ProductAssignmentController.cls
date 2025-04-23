public class ProductAssignmentController {
    
    public static List<TempProduct> tempProdList = new List<TempProduct>();
    public static Map<String,Id> productIdMap = new Map<String,Id>();
    public static Map<String,TempProduct> tempProdMap = new Map<String,TempProduct>();
    public static decimal totalValue {get;set;}
    public static Map<String,Id> priceEntrytIdMap = new Map<String,Id>();
    public static Date startForAll {get;set;}
    public static Date endForAll {get;set;}
    
    public class ConfigWrapper{
        @AuraEnabled
        public List<TempProduct> productList{get;set;}
        @AuraEnabled
        public decimal totalValue {get;set;}
    }
    
    public class TempProduct{
        @AuraEnabled
        public Boolean isActive {get;set;}
        @AuraEnabled
        public Boolean selected {get;set;}
        @AuraEnabled
        public String productName {get;set;}
        @AuraEnabled
        public String productCode {get;set;}
        @AuraEnabled
        public decimal percentage {get;set;}
        @AuraEnabled
        public decimal value {get;set;}
        @AuraEnabled
        public date startDate {get;set;}
        @AuraEnabled
        public date endDate {get;set;}
        @AuraEnabled
        public Boolean bespoke {get;set;}
        @AuraEnabled
        public String bespokeBenefit {get;set;}
        @AuraEnabled
        public String bespokeSummary {get;set;}
    }
    
    public class SaveResultWrapper{
        @AuraEnabled
        public boolean isSuccess{get;set;}
        @AuraEnabled
        public string message{get;set;}
        @AuraEnabled
        public List<TempProduct> productList{get;set;}
    }
    
    @AuraEnabled
    public static ConfigWrapper getConfig(Id recordId, string sObjectName){
        
        ConfigWrapper config = new ConfigWrapper();
        
        system.debug('recordId: ' + recordId);
        system.debug('sObjectName: ' + sObjectName);
        
        //GET TOTAL VALUE
        if(sObjectName == 'Quote'){
            // check that the quote has the standard price book assigned
            Quote q = [SELECT Id, Pricebook2Id, TotalPrice FROM Quote WHERE Id =: recordId ];
            if(q.Pricebook2Id == NULL){
                Pricebook2 book = [SELECT Name, Id FROM Pricebook2 WHERE isStandard=TRUE];
                q.Pricebook2Id = book.Id;
                update q;
            }
        }
        
        getProducts(recordId, sObjectName);
        
        config.totalValue = totalValue;
        config.productList = tempProdList;
        return config;
    }
    
    @AuraEnabled
    public static void getProducts(Id recordId, string sObjectName){
        
        //setup the inner class and mapping to handle the active products   
        List<Product2> products = [SELECT id, productCode, name, bespoke__c, isactive 
                                   FROM Product2 
                                   WHERE ProductCode != NULL 
                                   ORDER BY Name ASC]; 
        
        system.debug('products:'+products);
        
        for( Product2 product : products){
            productIdMap.put(product.productCode, product.Id);
        }      
        
        tempProdMap = new Map<String,TempProduct>();
        tempProdList = new List<TempProduct>();
        
        for(Product2 p : products){
            TempProduct temp = new TempProduct();
            temp.isActive = p.isactive;
            temp.selected = false;
            temp.productName = p.name;
            temp.productCode = p.productCode;
            temp.bespoke = p.bespoke__c;
            tempProdMap.put(p.productCode, temp);
            system.debug('Adding to tempProdMap: ' + p.productCode);
            tempProdList.add(temp);               
        }
        
        system.debug('tempProdMap: '+tempProdMap);
        system.debug('tempProdList: '+tempProdList);
        
        if(sObjectName == 'Quote'){
            //setDefaultsQuote(recordId);
        }else if(sObjectName == 'Opportunity'){
            setDefaultsOpportunity(recordId);
        }else if(sObjectName == 'SLA__c'){
            setDefaultsSLA(recordId);
        }
        
    }
    
    static void setDefaultsOpportunity(Id oppId){
        //pull in Opp info
        List<Opportunity> opps = [SELECT Id,amount from Opportunity where id=:oppId LIMIT 1];   
        if(!opps.isEmpty()){
            Opportunity opp = opps.get(0);    
            //populate the total value field
            if(opp.amount!=null){
                totalValue = opp.amount;  
                //get its products
                List<OpportunityLineItem> assignedProds = [SELECT Id,totalprice,ProductCode,of_Total__c,bespoke_summary__c,
                                                           ServiceDate,Contract_End_Date__c,bespoke_benefit__c from OpportunityLineItem where opportunityId =:oppId];
                
                //calculate the current percntage for each product
                if(!assignedProds.isEmpty()){
                    for(OpportunityLineItem prod : assignedProds){
                        system.debug('set defaults prod: '+prod); 
                        decimal tempPerc = prod.of_Total__c;
                        system.debug('set defaults tempPerc: '+tempPerc);
                        system.debug('set defaults tempProdMap.get: '+tempProdMap.get(prod.ProductCode));
                        TempProduct tempProd = tempProdMap.get(prod.ProductCode);
                        tempProd.selected = true;
                        tempProd.percentage = tempPerc;
                        tempProd.value = prod.totalPrice;
                        tempProd.startDate = prod.ServiceDate;
                        tempProd.endDate = prod.Contract_End_Date__c;    
                        tempProd.bespokeBenefit = prod.bespoke_benefit__c;
                        tempProd.bespokeSummary = prod.bespoke_summary__c; 
                        //tempProd.bespokeRender=false;    
                        //if(tempProd.selected && tempProd.bespoke){
                        //  tempProd.bespokeRender = true;
                        //}          
                    }        
                }
                //remove any products that arent active or are not selected from the list and map
                removeInactiveNonSelected();   
            }
        } 
    }
    
    static void setDefaultsSLA(Id slaId){
        //pull in Opp info
        List<SLA__c> slas = [SELECT Id,value_of_sla__c from SLA__c where id=:slaId LIMIT 1];     
        if(!slas.isEmpty()){
            SLA__c sla = slas.get(0);    
            //populate the total value field
            if(sla.value_of_sla__c!=null){   
                totalValue = sla.value_of_sla__c;    
                //get its products
                List<SLA_Product__c> assignedProds = [SELECT Id,value__c,product_code__c,start_date__c,bespoke_summary__c,
                                                      of_SLA_Total__c,End_Date__c,bespoke_benefit__c from SLA_Product__c where SLA__c =:slaId];
                
                //calculate the current percntage for each product
                if(!assignedProds.isEmpty()){
                    for(SLA_Product__c prod : assignedProds){
                        system.debug('set defaults prod: '+prod); 
                        decimal tempPerc = prod.of_SLA_Total__c;
                        system.debug('set defaults tempPerc: '+tempPerc);
                        system.debug('set defaults tempProdMap.get: '+tempProdMap.get(prod.product_code__c));
                        TempProduct tempProd = tempProdMap.get(prod.product_code__c);
                        tempProd.selected = true;
                        tempProd.percentage = tempPerc;
                        tempProd.value = prod.value__c;
                        tempProd.startDate = prod.start_date__c;
                        tempProd.endDate = prod.End_Date__c; 
                        tempProd.bespokeBenefit = prod.bespoke_benefit__c;
                        tempProd.bespokeSummary = prod.bespoke_summary__c; 
                        // tempProd.bespokeRender=false;    
                        //if(tempProd.selected && tempProd.bespoke){
                        //      tempProd.bespokeRender = true;
                        //}                       
                    }        
                } 
                //remove any products that arent active or are not selected from the list and map
                removeInactiveNonSelected();  
            }
        } 
    }
    /*    
    static void setDefaultsQuote(Id quoteId){
        //pull in Opp info
        List<Quote> quotes = [SELECT Id,TotalPrice from Quote where id=:quoteId LIMIT 1];     
        if(!quotes.isEmpty()){
            Quote theQuote = quotes.get(0);    
            //populate the total value field
            if(theQuote.TotalPrice!=null){  
                totalValue = theQuote.TotalPrice;    
                //get its products
                List<QuoteLineItem> assignedProds = [SELECT Id,TotalPrice,Product2.ProductCode,start_date__c,bespoke_summary__c,
                                                     of_Total__c,End_Date__c,bespoke_benefit__c from QuoteLineItem where QuoteId =:quoteId];
                
                //calculate the current percntage for each product
                if(!assignedProds.isEmpty()){
                    
                    for(QuoteLineItem prod : assignedProds){
                        system.debug('set defaults prod: '+prod); 
                        decimal tempPerc = prod.of_Total__c;
                        system.debug('set defaults tempPerc: '+tempPerc);
                        system.debug('set defaults tempProdMap.get: '+tempProdMap.get(prod.Product2.ProductCode));
                        TempProduct tempProd = tempProdMap.get(prod.Product2.ProductCode);
                        tempProd.selected = true;
                        tempProd.percentage = tempPerc; 
                        tempProd.value = prod.TotalPrice;
                        tempProd.startDate = prod.start_date__c;
                        tempProd.endDate = prod.End_Date__c; 
                        
                        tempProd.bespokeBenefit = prod.bespoke_benefit__c;
                        tempProd.bespokeSummary = prod.bespoke_summary__c; 
                        // tempProd.bespokeRender=false;    
                        //if(tempProd.selected && tempProd.bespoke){
                        //  tempProd.bespokeRender = true;
                        //}                       
                    }        
                } 
                //remove any products that arent active or are not selected from the list and map
                removeInactiveNonSelected();  
            }
        } 
    }
    */
    static void removeInactiveNonSelected(){
        List<TempProduct> toBeRemoved = new List<TempProduct>();
        for (TempProduct tp : tempProdList){
            if( !tp.isActive && !tp.selected){
                toBeRemoved.add(tp);
            }
        }
        for (TempProduct tp : toBeRemoved){
            Integer indexToRemove = tempProdList.indexOf(tp);
            TempProduct removed = tempProdList.remove(indexToRemove);
        }       
    }
    
    @AuraEnabled
    public static SaveResultWrapper assignProducts(Id recordId, string sObjectName, List<TempProduct> productList, boolean usePerc, boolean useValue, decimal totalVal, Date startDate, Date endDate){
        
        SaveResultWrapper result = new SaveResultWrapper();
        priceEntrytIdMap = new Map<String,Id>();
        startForAll = startDate;
        endForAll = endDate;
        tempProdList = productList;
        
        system.debug('productList: ' + productList);
        
        //do not allow non admin to change closed won Opps
        if(sObjectName == 'Opportunity'){
            List<Opportunity> oppList = [SELECT id,amount,isWon from Opportunity where id =:recordId LIMIT 1];
            List<Profile> userProfileList = [SELECT id,Name from Profile where id =:UserInfo.getProfileId()];
            system.debug('oppList:'+oppList);
            system.debug('userProfileList:'+userProfileList);
            if(oppList.get(0).isWon && userProfileList.get(0).name != 'System Administrator'){
                result.isSuccess = false;
                result.message = 'Only a System Administrator can change values for Closed Won Opportunities';
                return result; 
            }
        }
        
        //validate that a choice has been made between % and Value
        if( (!usePerc && !useValue) || (usePerc && useValue) ){
            result.isSuccess = false;
            result.message = 'Please select to create Products with either % or Value';
            return result;
        }         
        //first check that the total is compelted
        if((totalVal == null || totalVal <= 0 ) && usePerc){
            result.isSuccess = false;
            result.message = 'Please select to create Products with either % or Value';
            return result;
        }     
        //get Pricebook entries and map from product code Pricebook entry id
        List<PriceBookEntry> priceEntries = [SELECT Id,ProductCode FROM PriceBookEntry where ProductCode != null ];
        for( PriceBookEntry entry : priceEntries){
            system.debug('Adding to priceEntrytIdMap: '+entry.productCode);
            priceEntrytIdMap.put(entry.productCode,entry.Id);
        }
        
        //if the value field is compelted, add the Product code and percentage to lists
        List<TempProduct> productsChosen = new List<TempProduct>();
        
        //if the user has chosen to use % to create then go through the tempOppPrducts and see whats been filled in
        if(usePerc){      
            //we'll need to check that the %'s total 100 so create a counter
            Decimal counter = 0;
            productsChosen.clear();
            for(TempProduct tempOppProd : tempProdList){
                system.debug('tempOppProd: ' + tempOppProd);
                if(tempOppProd.selected && tempOppProd.percentage != null && tempOppProd.percentage > 0){
                    //record the Opp Products that need creation and its value
                    productsChosen.add(tempOppProd);
                    tempOppProd.value = totalVal * (tempOppProd.percentage / 100);
                    //increase the counter
                    counter = counter + tempOppProd.percentage;       
                }      
            }
            //validate we have 100
            if(counter != 100){
                system.debug('counter: ' + counter);
                result.isSuccess = false;
                result.message = 'Percentages of chosen products must total 100, current total is: '+counter;
                return result;
            } 
        }     
        
        //if the user has chosen to use values to create then go through the tempOPrducts and see whats been filled in
        if(useValue){  
            productsChosen.clear();
            for(TempProduct tempProd : tempProdList){
                if(tempProd.selected && tempProd.value != null && tempProd.value > 0){
                    productsChosen.add(tempProd);
                }     
            }
        }
        
        system.debug('productsChosen:'+productsChosen);
        
        //validate that at least one product has been chosen
        if(productsChosen.isEmpty()){
            result.isSuccess = false;
            result.message = 'Please choose select a Product';
            return result;
        }    
        
        //validate that all products have start and end dates
        if (startForAll == null){
            for (TempProduct prod : productsChosen){
                if(prod.startDate == null){
                    result.isSuccess = false;
                    result.message = 'Please ensure all Products have start dates. These are editable until the Opportunity closes.';
                    return result;
                }
            }
        }
        
        //validate that all products have start and end dates
        if (endForAll == null){
            for (TempProduct prod : productsChosen){
                if(prod.endDate == null){
                    result.isSuccess = false;
                    result.message = 'Please ensure all Products have end dates. These are editable until the Opportunity closes.';
                    return result;
                }
            }
        }
        
        //validate that all bespoke products have been given a benefit and summary
        for (TempProduct prod : productsChosen){
            if(prod.bespoke && (prod.bespokeBenefit == null || prod.bespokeSummary == null)){
                result.isSuccess = false;
                result.message = 'Please ensure all bespoke products have a summary and benefit.';
                return result;
            }
        }
        
        List<SObject> newProducts = new List<SObject>();
        List<SObject> existingProducts = new List<SObject>();
        
        //create the selected Opportunity products
        if(sObjectName == 'Opportunity'){
            for(TempProduct op : productsChosen){
                newProducts.add(createOppLineItem(op, recordId));
            }
            //get all the existing opp products before we create new ones, we will delete the old ones if
            //we are succesful in creating the new ones
            existingProducts = [Select Id FROM OpportunityLineItem WHERE opportunityId=:recordId];
            system.debug('Existing Products Found '+existingProducts);
        }
        
        
        
        //create the selected SLA products
        List<SLA__c> sla = new List<SLA__c>();
        if(sObjectName == 'SLA__c'){
            sla = [SELECT id,value_of_Sla__c FROM SLA__c WHERE id=:recordId];
            
            for(TempProduct op : productsChosen){
                newProducts.add(createSlaProduct(op, recordId));
            }
            //get all the existing slas products before we create new ones, we will delete the old ones if
            //we are succesful in creating the new ones
            existingProducts = [Select Id from SLA_Product__c where SLA__c=:recordId];
            sla.get(0).value_of_sla__c = totalVal;      
        }
        
        //create the selected Quote products
        /*
if(sObjectName == 'Quote'){
for(TempProduct op : productsChosen){
newProducts.add(createQuoteLineItem(op, recordId));
}
//get all the existing opp products before we create new ones, we will delete the old ones if
//we are succesful in creating the new ones
existingProducts = [Select Id from QuoteLineItem where quoteId=:recordId];
}
*/
        
        try{
            insert newProducts;
            if(!sla.isempty()){
                update sla.get(0);
            }      
        }catch(Exception e){
            reportFatalError(e); return null;
        }
        
        try{ 
            system.debug('EXISTING PRODUCTS TO BE DELETED: '+existingProducts);
            if(!existingProducts.isEmpty()){
                system.debug('DELETE');
                delete existingProducts;  
            }
        }catch(Exception e){
            system.debug('Problem deleting: '+e.getmessage());
            reportFatalError(e);
            result.isSuccess = false;
            result.message = e.getMessage();
            return result;
        }
        
        //return back to the original Opportunity screen with success message      
        result.isSuccess = true;
        result.message = 'Products succesfully assigned';
        return result;
        
    }
    
    static OpportunityLineItem createOppLineItem (TempProduct op, Id oppId){  
        system.debug('createOppLineItem: '+op.productCode+' '+op.value);
        OpportunityLineItem oppProduct = new OpportunityLineItem();
        oppProduct.Product2Id = productIdMap.get(op.productCode);
        oppProduct.opportunityId = oppId;
        oppProduct.pricebookEntryId = priceEntrytIdMap.get(op.productCode);
        oppProduct.quantity = 1;
        oppProduct.unitprice = op.value;   
        oppProduct.ServiceDate = op.startDate;
        oppProduct.Contract_End_Date__c = op.endDate;
        oppProduct.bespoke_benefit__c = op.bespokeBenefit;
        oppProduct.bespoke_summary__c = op.bespokeSummary;
        //if we are using the start/end for all dates then overide
        if(startForAll != null){oppProduct.ServiceDate = startForAll;}
        if(endForAll != null){oppProduct.Contract_End_Date__c = endForAll;}
        return oppProduct;
    }
    
    static SLA_Product__c createSlaProduct (TempProduct op, Id slaId){  
        system.debug('createSlaProduct: '+op.productCode+' '+op.value);
        SLA_Product__c slaProduct = new SLA_Product__c();
        slaProduct.Product__c = productIdMap.get(op.productCode);
        slaProduct.SLA__c = slaId;
        slaProduct.value__c = op.value;   
        slaProduct.Start_Date__c = op.startDate;
        slaProduct.End_Date__c = op.endDate;
        slaProduct.bespoke_benefit__c = op.bespokeBenefit;
        slaProduct.bespoke_summary__c = op.bespokeSummary;
        //if we are using the start/end for all dates then overide
        if(startForAll != null){slaProduct.Start_Date__c = startForAll;}
        if(endForAll != null){slaProduct.End_Date__c = endForAll;}
        return slaProduct;
    }
    
    /*
    static QuoteLineItem createQuoteLineItem (TempProduct op, Id quoteId){  
        system.debug('createQuoteLineItem: '+op.productCode+' £'+op.value);
        QuoteLineItem quoteProduct = new QuoteLineItem();
        quoteProduct.Product2Id = productIdMap.get(op.productCode);
        quoteProduct.quoteId = quoteId;
        system.debug('createQuoteLineItem: op.productCode: '+op.productCode);
        system.debug('createQuoteLineItem: priceEntrytIdMap: '+priceEntrytIdMap.get(op.productCode));
        system.debug('priceEntrytIdMap: '+priceEntrytIdMap);
        quoteProduct.pricebookEntryId = priceEntrytIdMap.get(op.productCode);
        quoteProduct.quantity = 1;
        quoteProduct.unitprice = op.value;   
        quoteProduct.ServiceDate = op.startDate;
        quoteProduct.End_Date__c = op.endDate;
        quoteProduct.bespoke_benefit__c = op.bespokeBenefit;
        quoteProduct.bespoke_summary__c = op.bespokeSummary;
        //if we are using the start/end for all dates then overide
        if(startForAll != null){quoteProduct.ServiceDate = startForAll;}
        if(endForAll != null){quoteProduct.End_Date__c = endForAll;}
        return quoteProduct;
    }
    */
    public static void reportFatalError(Exception e){
        system.debug('***Problem inserting Opportunity/SLA/Qupte Products***');
        system.debug(e.getMessage());
        system.debug(e.getStackTraceString());
        Error__c err = new Error__c(Title__c = 'ProductPercentages',Object__c = 'Opportunity/SLA/Quote',Description__c = 
                                    'Problem encountered updating Products from ProductPercentages page - '+e.getMessage(), Sub_Description__c = e.getStackTraceString());
        insert err;
    }
    
    public static void reportFatalError(String desription, String sub){
        system.debug('***Problem on ProductPercentagesPage***');
        Error__c err = new Error__c(Title__c = 'ProductPercentages',Object__c = 'Opportunity/SLA/Quote',Description__c=desription,Sub_Description__c=sub);
        insert err;
    }
    
    @AuraEnabled
    public static SaveResultWrapper assignLite(Id recordId, string sObjectName){
        
         SaveResultWrapper result = new SaveResultWrapper();
        
        getProducts(recordId, sObjectName);
        
        if(sObjectName == 'Opportunity'){
            result = getProductsForBundle('Lite');  
        }
        
        result.productList = tempProdList;
        return result;
        
    }
    
    @AuraEnabled
    public static SaveResultWrapper assignPlus(Id recordId, string sObjectName){
        
         SaveResultWrapper result = new SaveResultWrapper();
        
        getProducts(recordId, sObjectName);
        
        if(sObjectName == 'Opportunity'){
            result = getProductsForBundle('Plus');  
        }
        
        result.productList = tempProdList;
        return result;
        
    }
    
    @AuraEnabled
    public static SaveResultWrapper assignPremier(Id recordId, string sObjectName){
        
        SaveResultWrapper result = new SaveResultWrapper();
        
        getProducts(recordId, sObjectName);
        
        if(sObjectName == 'Opportunity'){
            result = getProductsForBundle('Premier');   
        }
        
        result.productList = tempProdList;
        return result;
        
    }
    
    static SaveResultWrapper getProductsForBundle (String bundleName){
        
        SaveResultWrapper result = new SaveResultWrapper();
        
        try{
            // find the bundle
            List<Bundle__c> foundBundles = [SELECT Id FROM Bundle__c WHERE name LIKE :bundleName LIMIT 1];
            
            if(foundBundles.isEmpty()){
                reportFatalError('Bundle was not found','');
            }
            
            //get the bundle products
            List<Bundle_Product__c> foundBundleProducts = [SELECT Id,product__r.productCode FROM Bundle_Product__c WHERE Bundle__c = :foundBundles.get(0).Id];
            
            if(foundBundles.isEmpty()){
                reportFatalError('No bundle products were found','');
            }
            
            for(Bundle_Product__c bp : foundBundleProducts) {
                tempProdMap.get(bp.product__r.productCode).selected = true;
            }
        }catch(Exception e){
            
            reportFatalError(e);
            result.isSuccess = false;
            result.message = e.getMessage();
            return result;
            
        }
        
        result.isSuccess = true;
        result.productList = tempProdList;
        return result;
        
    } 
    
    @AuraEnabled
    public static SaveResultWrapper assignSLAProducts(Id recordId, string sObjectName, boolean usePerc, boolean useValue){
        
        SaveResultWrapper result = new SaveResultWrapper();
        
        getProducts(recordId, sObjectName);
        
        if(sObjectName == 'Opportunity'){
            try{
                Opportunity opp = [SELECT Id,ContractId FROM Opportunity WHERE id =: recordId];
                
                if(opp.ContractId == null){
                    result.isSuccess = false;
                    result.message = 'You cannot assign Products from a Contract as the Opportunity is not linked to an Contract';
                    return result;
                }
                                 
                //get the opps connected to the contract, order by amount as we'll use the most valuable
                List<Opportunity> contractOpportunities = [SELECT Id FROM Opportunity WHERE ContractId =: opp.ContractId AND HasOpportunityLineItem = TRUE
                                                            ORDER BY Amount DESC];
                
                if(contractOpportunities.isEmpty()){
                    result.isSuccess = false;
                    result.message = 'Cannot assign products as none of the Contracts Opportunities have Products assigned';
                    return result;
                }             
                
                //get its products products
                List<OpportunityLineItem> foundProducts = [SELECT Id,productCode,Contract_End_Date__c,of_Total__c FROM OpportunityLineItem WHERE OpportunityId =: contractOpportunities.get(0).Id];
                for(OpportunityLineItem p : foundProducts) {
                    tempProdMap.get(p.productCode).selected = true;
                    tempProdMap.get(p.productCode).endDate = p.Contract_End_Date__c;
                         
                    if(usePerc){
                        tempProdMap.get(p.productCode).percentage = p.of_Total__c;
                    }   
                    if(useValue){
                        tempProdMap.get(p.productCode).value = totalValue * p.of_Total__c;
                    }                   
                } 
                 
            }catch(Exception e){
                reportFatalError(e);
                result.isSuccess = false;
                result.message = e.getMessage();
                return result;
            }    
        }       
        result.isSuccess = true;
        result.productList = tempProdList;
        return result;
    }
    
}