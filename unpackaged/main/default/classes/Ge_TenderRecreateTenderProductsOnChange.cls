/**********************************************************************
Name:  Ge_TenderRecreateTenderProductsOnChange
Copyright © 2023
======================================================
======================================================
Purpose:  Invocable class for Tender Flow

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0      Lynn Mejos          13/03/2023     
***********************************************************************/
public class Ge_TenderRecreateTenderProductsOnChange {
    
    /*******************************************************************
    @description Method to create new Tender Products from existing Supply Contract
    @param List<Requests> request - list of request variables
    @return List<Results> – list of new tender products to create
    @author Lynn Mejos
    @date 13/03/2023
    ********************************************************************/
    @InvocableMethod(label='Create Tender Products' description='Returns a list of Tender Product records to be created' category='Tender_Product__c')
    public static List<List<Tender_Product__c>> getNewTenderProducts(List<Requests> request) {
        List<List<Tender_Product__c>> returnTenderProducts = new List<List<Tender_Product__c>>();
        for(Requests req: request){
        List<Tender_Product__c> tenderProducts = processTenderProducts(request); 
            returnTenderProducts.add(tenderProducts);
		}
        return returnTenderProducts;
    }
    
    /*******************************************************************
    @description wrapper class to hold parameters from the flow
    @param List<Requests> request - list of request variables
    @return List of Tender Products to create
    @author Lynn Mejos
	@date 13/03/2023
********************************************************************/
    public static List<Tender_Product__c> processTenderProducts(List<Requests> request){
        Map<String,Decimal> dateMap = new Map<String,Decimal>();
        List<String> dateMapKeySet = new List<String>();
        if(request[0].TenderSupContracts!=null){
            for(Supply_Contract__c sc : request[0].TenderSupContracts){
                String tempKey = sc.contract_start_date__c.format() + '-'+ sc.contract_end_date__c.format();
                if(dateMap.containskey(tempKey)){
                    Decimal tempValue = dateMap.get(tempKey);
                    dateMap.put(tempKey, tempValue + sc.Contract_Value__c);		
                }else{
                    dateMap.put(tempKey,sc.Contract_Value__c);
                    dateMapKeySet.add(tempKey);
                }
            }
        }
        return createTenderProducts(dateMapKeySet, dateMap, request);
    }
    
    /*******************************************************************
    @description generate tender products to create
    @param List<String> dateMapKeySet - List of date keys of dateMap
    @param Map<String,Decimal> dateMap - Map of start date and end date as keys and contract value as value
    @param List<Requests> request - list of request variables
    @return List of Tender Products to create
    @author Lynn Mejos
    @date 13/03/2023
    ********************************************************************/
    public static List<Tender_Product__c> createTenderProducts(List<String> dateMapKeySet, Map<String,Decimal> dateMap, List<Requests> request){
        List<Tender_Product__c> tenderProducts = new List<Tender_Product__c>();
        List<OpportunityLineItem> products =request[0].oppLineItemList;
        for(OpportunityLineItem o : products){
            
            system.debug('Working this product: '+o);
            
            //if we have no supply contracts we'll just use opp product and estimated data to forecast
            if(request[0].TenderSupContracts==null){
                system.debug('using estimated');
                tenderProducts.add(
                    new Tender_Product__c(
                        value__c = request[0].tenderRecord.estimated_commission_value__c * o.of_total__c / 100,
                        tender__c = request[0].tenderRecord.Id,  
                        product__c = o.product2id,
                        Start_Date__c = o.serviceDate,
                        end_date__c = o.contract_end_date__c
                    )
                );
                //will get back to this part//
            }else{
                for(String key : dateMapKeySet){
                    //add a product
                    tenderProducts.add(
                        new Tender_Product__c(
                            value__c = dateMap.get(key) * o.of_total__c / 100,
                            tender__c = request[0].tenderRecord.Id,  
                            product__c = o.product2id,
                            Start_Date__c = date.parse(key.substringBefore('-')),
                            end_date__c = date.parse(key.substringAfter('-'))
                        )
                    );			    			
                }
            }
        }
        return tenderProducts;
    }
    
    /*******************************************************************
    @description wrapper class to hold parameters from the flow
    @author Lynn Mejos
    @date 13/03/2023
    ********************************************************************/
    public class Requests {
        @InvocableVariable(label='Supply Contracts' description='List of related Supply Contract' required=false)
        public List<Supply_Contract__c> tenderSupContracts;
        @InvocableVariable(label='Opportunity Line Items' description='current Opportunity Line Item in the loop' required=true)
        public List<OpportunityLineItem> oppLineItemList;
        @InvocableVariable(label='Tender Id' description='Id of Tender record' required=true)
        public Tender__c tenderRecord;
    }
    
    /*******************************************************************
    @description wrapper class to hold results to be returned to the flow
    @author Lynn Mejos
    @date 13/03/2023
    ********************************************************************/
    public class Results {
        @InvocableVariable(label='Records for Output' description='yourDescription' required=true)
        public List<Tender_Product__c> newTenderProducts;
    }
}