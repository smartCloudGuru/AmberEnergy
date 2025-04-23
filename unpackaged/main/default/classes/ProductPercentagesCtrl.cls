public without sharing class ProductPercentagesCtrl {
    
    public Boolean oppContext = false;
    public Boolean slaContext = false;
    public Boolean quoteContext = false;
    
    public Map<String,Id> productIdMap = new Map<String,Id>();
    public Map<String,Id> priceEntrytIdMap = new Map<String,Id>();
    
    public class TempProduct{
      public Boolean isActive {get;set;}
      public Boolean selected {get;set;}
      public String productName {get;set;}
      public String productCode {get;set;}
      public decimal percentage {get;set;}
      public decimal value {get;set;}
      public date startDate {get;set;}
      public date endDate {get;set;}
      public Boolean bespoke {get;set;}
      public String bespokeBenefit {get;set;}
      public String bespokeSummary {get;set;}
      public Boolean bespokeRender {get{        
        if(bespoke && selected){return true;}
        return false;}set;}
    }
    
    public Map<String,TempProduct> tempProdMap {get;set;}
    public List<TempProduct> tempProdList {get;set;}
    
    public Id oppId {get;set;}
    public Id slaId {get;set;}
    public Id quoteId {get;set;}
    public decimal totalValue {get;set;}  
    public Boolean usePerc {get;set;} 
    public Boolean useValue {get;set;} 
    public Boolean useOptionSelected {get;set;} 
    public Date startForAll {get;set;}
    public Date endForAll {get;set;}
    
    
       
    /*********************************
          Constructor
    *********************************/
    public ProductPercentagesCtrl(){
      //get URL parameters and set the context of where the page is called from
      oppId = apexpages.currentpage().getparameters().get('oppId');
      system.debug('oppId: '+oppId);
      if(oppId != null){
        system.debug('CONTEXT IS OPPORTUNITY');
        oppContext = true;
      }
      slaId = apexpages.currentpage().getparameters().get('SLAId');
      system.debug('slaId: '+slaId);
      if(slaId != null){
        system.debug('CONTEXT IS SLA');
        slaContext = true;
      }
      quoteId = apexpages.currentpage().getparameters().get('quoteId');
      system.debug('quoteId: '+quoteId);
      if(quoteId != null){
        system.debug('CONTEXT IS QUOTE');
        quoteContext = true;
        
        // check that the quote has the standard price book assigned
        Quote q = [SELECT Id,Pricebook2Id FROM Quote WHERE Id =: quoteId ];
        if(q.Pricebook2Id == null){
            Pricebook2 book = [SELECT Name,Id FROM Pricebook2 WHERE isStandard=TRUE];
            q.Pricebook2Id = book.Id;
            update q;
        }
        
      }
    
      //setup the inner class and mapping to handle the active products   
      List<Product2> products = [SELECT id,productCode,name,bespoke__c,isactive FROM Product2 WHERE 
                    ProductCode != null ORDER BY Name ASC]; 
      system.debug('products:'+products);
      
      for( Product2 product : products){
        productIdMap.put(product.productCode,product.Id);
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
        tempProdMap.put(p.productCode,temp);
        system.debug('Adding to tempProdMap: '+p.productCode);
        tempProdList.add(temp);               
      }
      
      system.debug('tempProdMap: '+tempProdMap);
      system.debug('tempProdList: '+tempProdList);
      
      if(oppContext){
        setDefaultsOpportunity();
      }
      if(slaContext){
        setDefaultsSLA();
      }
      if(quoteContext){
        /*setDefaultsQuote();*/
      }
    }   
    
    
    public void setDefaultsOpportunity(){
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
              //    tempProd.bespokeRender = true;
              //}          
            }        
          }
          //remove any products that arent active or are not selected from the list and map
          removeInactiveNonSelected();   
        }
      } 
    }  
    
    public void setDefaultsSLA(){
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
              //    tempProd.bespokeRender = true;
              //}                       
            }        
          } 
          //remove any products that arent active or are not selected from the list and map
          removeInactiveNonSelected();  
        }
      } 
    }
    
    /*    
    public void setDefaultsQuote(){
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
              //    tempProd.bespokeRender = true;
              //}                       
            }        
          } 
          //remove any products that arent active or are not selected from the list and map
          removeInactiveNonSelected();  
        }
      } 
    }
    */
    
    /** Does a pass over the tempProd list to remove any products that are both not selected and inactive
    */
    public void removeInactiveNonSelected(){
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
    
    public pageReference Create(){
           
      //do not allow non admin to change closed won Opps
      if(oppContext){
        List<Opportunity> oppList = [SELECT id,amount,isWon from Opportunity where id =:oppId LIMIT 1];
        List<Profile> userProfileList = [SELECT id,Name from Profile where id =:UserInfo.getProfileId()];
        system.debug('oppList:'+oppList);
        system.debug('userProfileList:'+userProfileList);
        if(oppList.get(0).isWon && userProfileList.get(0).name != 'System Administrator'){
          ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Only a System Administrator can change values for Closed Won Opportunities'));
            return null; 
        }
      }
      
      //validate that a choice has been made between % and Value
      if( (!usePerc && !useValue) || (usePerc && useValue) ){
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Please select to create Products with either % or Value'));
          return null; 
      }         
      //first check that the total is compelted
      if((totalValue == null || totalValue <= 0 ) && usePerc){
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Please provide a total value of the Opportunity'));
          return null; 
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
          if(tempOppProd.selected && tempOppProd.percentage != null && tempOppProd.percentage > 0){
            //record the Opp Products that need creation and its value
            productsChosen.add(tempOppProd);
            tempOppProd.value = totalValue * (tempOppProd.percentage / 100);
            //increase the counter
            counter = counter + tempOppProd.percentage;       
          }      
        }
        //validate we have 100
        if(counter != 100){
          ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Percentages of chosen products must total 100, current total is: '+counter));
            return null; 
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
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Please choose select a Product'));
        return null; 
      }    
      //validate that all products have start and end dates
      if (startForAll == null){
        for (TempProduct prod : productsChosen){
          if(prod.startDate == null){
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Please ensure all Products have start dates. These are editable until the Opportunity closes.'));
              return null; 
          }
        }
      }
      
      //validate that all products have start and end dates
      if (endForAll == null){
        for (TempProduct prod : productsChosen){
          if(prod.endDate == null){
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Please ensure all Products have end dates. These are editable until the Opportunity closes.'));
              return null; 
          }
        }
      }
      
      //validate that all bespoke products have been given a benefit and summary
      for (TempProduct prod : productsChosen){
        if(prod.bespoke && (prod.bespokeBenefit == null || prod.bespokeSummary == null)){
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Please ensure all bespoke products have a summary and benefit.'));
              return null;
        }
      }
        
      List<SObject> newProducts = new List<SObject>();
      List<SObject> existingProducts = new List<SObject>();
      
      //create the selected Opportunity products
      if(oppContext){
        for(TempProduct op : productsChosen){
          newProducts.add(createOppLineItem(op));
        }
        //get all the existing opp products before we create new ones, we will delete the old ones if
        //we are succesful in creating the new ones
        existingProducts = [Select Id from OpportunityLineItem where opportunityId=:oppId];
      }
      system.debug('Existing Products Found '+existingProducts);
      
      List<SLA__c> sla = [SELECT id,value_of_Sla__c FROM SLA__c where id=:slaId];
      //create the selected SLA products
      if(slaContext){
        for(TempProduct op : productsChosen){
          newProducts.add(createSlaProduct(op));
        }
        //get all the existing slas products before we create new ones, we will delete the old ones if
        //we are succesful in creating the new ones
        existingProducts = [Select Id from SLA_Product__c where SLA__c=:slaId];
        sla.get(0).value_of_sla__c = totalValue;      
      }
      
      //create the selected Quote products
      /*
      if(quoteContext){
        for(TempProduct op : productsChosen){
          newProducts.add(createQuoteLineItem(op));
        }
        //get all the existing opp products before we create new ones, we will delete the old ones if
        //we are succesful in creating the new ones
        existingProducts = [Select Id from QuoteLineItem where quoteId=:quoteId];
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
        reportFatalError(e); return null;
      }
      
      //return back to the original Opportunity screen with success message        
         ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Poducts succesfully assigned'));
        PageReference pg = null;
        if(oppContext){
          pg = new PageReference('/'+oppId);
        }
        if(slaContext){
          pg = new PageReference('/'+slaId);
        } 
        if(quoteContext){
          pg = new PageReference('/'+quoteId);
        } 
        pg.setRedirect(true);
        return pg; 
    }
    
    public OpportunityLineItem createOppLineItem (TempProduct op){  
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
  
  public SLA_Product__c createSlaProduct (TempProduct op){  
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
  public QuoteLineItem createQuoteLineItem (TempProduct op){  
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
  
  public void reportFatalError(Exception e){
    system.debug('***Problem inserting Opportunity/SLA/Qupte Products***');
        system.debug(e.getMessage());
        system.debug(e.getStackTraceString());
        Error__c err = new Error__c(Title__c = 'ProductPercentages',Object__c = 'Opportunity/SLA/Quote',Description__c = 
           'Problem encountered updating Products from ProductPercentages page - '+e.getMessage(), Sub_Description__c = e.getStackTraceString());
        insert err;
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Unexpected Error Occured, Please contact an administrator '+e.getMessage()));
  }
  
  public void reportFatalError(String desription, String sub){
    system.debug('***Problem on ProductPercentagesPage***');
        Error__c err = new Error__c(Title__c = 'ProductPercentages',Object__c = 'Opportunity/SLA/Quote',Description__c=desription,Sub_Description__c=sub);
        insert err;
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Unexpected Error Occured, Please contact an administrator'));
  }
  
  public PageReference choosePerc(){
    useValue = false;
    useOptionSelected = true;
    return null;
  } 
  
  public PageReference chooseVal(){
    usePerc = false;
    useOptionSelected = true;
    return null;
  }
  
  public PageReference refreshPage(){
    return null;
  }
  
  public pageReference assignLite(){
        getProductsForBundle('Lite');       
    return null;
    
  }
  
  public pageReference assignPlus(){
        getProductsForBundle('Plus');   
    return null;
  }
  
  public pageReference assignPremier(){
        getProductsForBundle('Premier');
    return null;
  }
   
  
  public void getProductsForBundle (String bundleName){
    
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
    }
         
  } 
  
  public pageReference assignSLAProducts(){
    if(oppContext){
        try{
            Opportunity opp = [SELECT Id,SLA__c FROM Opportunity WHERE id =: oppId];
            
            if(opp.SLA__c == null){
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'You cannot assign Products from an SLA as the Opportunity is not linked to an SLA'));
                return null;
            }
            
            List<SLA_Product__c> slaProducts = [SELECT Id,of_SLA_Total__c,End_Date__c,Product_Code__c FROM SLA_Product__c WHERE SLA__c =: opp.SLA__c];
            
            if(slaProducts.isEmpty()){
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'The SLA has no Products assigned'));
                return null;
            }else{                          
                for(SLA_Product__c sp : slaProducts) {
                    tempProdMap.get(sp.Product_Code__c).selected = true;
                    tempProdMap.get(sp.Product_Code__c).endDate = sp.End_Date__c;
                    
                    if(usePerc){
                        tempProdMap.get(sp.Product_Code__c).percentage = sp.of_SLA_Total__c;
                    }   
                    if(useValue){
                        tempProdMap.get(sp.Product_Code__c).value = opp.amount * sp.of_SLA_Total__c;
                    }                   
                } 
            }
        }catch(Exception e){
            reportFatalError(e);
        }    
    }       
    return null;
  }
  
    
    
}