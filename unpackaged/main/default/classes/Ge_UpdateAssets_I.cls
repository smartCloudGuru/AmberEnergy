/**********************************************************************
Name:  Ge_UpdateAssets_I
Copyright © 2023
======================================================
======================================================
Purpose:  Invocable class for Email Message flow

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0      Lynn Mejos          04/04/2023     
***********************************************************************/
public class Ge_UpdateAssets_I {
    /*******************************************************************
    @description Method to create new OrderItem from existing OpportunityLineItem
    @param List<Requests> request - list of request variables
    @return List<Results> – list of new tender products to create
    @author Lynn Mejos
    @date 13/03/2023
    ********************************************************************/
    @InvocableMethod(label='Update Assets' description='Returns the Assets' category='Asset')
    public static List<List<Asset>> updateAssets(List<Requests> request) {
        List<List<Asset>> returnAsset = new List<List<Asset>>();
        Opportunity o = request[0].wonOpportunity;
        List<Asset> accountAssets = request[0].assetList;
        List<Asset> assets = request[0].assetList;
        List<OpportunityLineItem> oppProducts = request[0].oppProducts; 
        
        for(OpportunityLineItem op : oppProducts){
            Boolean assetMatched = false;
            if(!accountAssets.isEmpty()){
                for(Asset a : accountAssets){
                    if(op.product2Id == a.Product2Id){
                        assetMatched = true;
                        if(a.UsageEndDate <= op.Contract_End_Date__c){
                            a.UsageEndDate = op.Contract_End_Date__c;                              
                        }
                    } 
                }   
            }  
            if(!assetMatched){
                //create an asset
                assets.add(new Asset(
                    name=op.productcode,
                    accountId=o.accountId,
                    Product2Id=op.product2Id,
                    UsageEndDate=op.Contract_End_Date__c,
                    PurchaseDate=o.closeDate,
                    status='Purchased'
                ));
            }
        }
        upsert assets;
        return returnAsset;
    }
    
    /*******************************************************************
    @description wrapper class to hold parameters from the flow
    @author Lynn Mejos
    @date 28/03/2023
    ********************************************************************/
    public class Requests {
        @InvocableVariable(label='Opportunity Line Items' description='List of Opportunity Line Item' required=true)
        public List<OpportunityLineItem> oppProducts;
        @InvocableVariable(label='Assets' description='List of Assets under the Account' required=true)
        public List<Asset> assetList;
        @InvocableVariable(label='Opportunity' description='Won Opportunity' required=true)
        public Opportunity wonOpportunity;
    }

}