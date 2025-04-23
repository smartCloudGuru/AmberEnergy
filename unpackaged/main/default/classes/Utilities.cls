/**
 * @description       : 
 * @author            : Tom Jefford
 * @group             : 
 * @last modified on  : 12-08-2020
 * @last modified by  : Tom Jefford
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   12-08-2020   Tom Jefford   Initial Version
**/
public with sharing class Utilities {
    
    static integer tenderRunTimes = 0;
    public static integer getTenderRunTimes(){
        return tenderRunTimes;
    }   
    public static void setTenderRunTimes(){
        tenderRunTimes++;
    }
    public static void resetTenderRunTimes(){
        tenderRunTimes = 0;
    }
    
    static integer oppProdRunTimes = 0;
    public static integer getOppProdRunTimes(){
        return oppProdRunTimes;
    }   
    public static void setOppProdRunTimes(){
        oppProdRunTimes++;
    }
    public static void resetOppProdRunTimes(){
        oppProdRunTimes = 0;
    }

    public static Map<Id,RecordType> getRecordTypes(){
        List<RecordType> recordTypes = [SELECT Id, DeveloperName, Description, IsActive, Name, SobjectType 
                                        FROM RecordType];
        return new Map<Id,RecordType>(recordTypes);
    }
    
    
    public static List<Reporting_Product__c> checkAndSplitReportingProducts( List<Reporting_Product__c> newProducts ){
        
        //list to be returned if we have done some work
        List<Reporting_Product__c> replacementProducts = new List<Reporting_Product__c>();
        
        Set<Id> parentOpportunityIds = new Set<Id>();
        for(Reporting_Product__c rp : newProducts){
            parentOpportunityIds.add(rp.opportunity__c);
        }
        
        List<OpportunitySplit> oppSplits = [SELECT Id, OpportunityId, SplitOwnerId, SplitPercentage FROM OpportunitySplit WHERE OpportunityId in :parentOpportunityIds];
        
        system.debug('oppSplits : '+oppSplits );
        
        // if there are no splits then we can just stop now
        if(oppSplits.isEmpty()){
            return newProducts;
        }
        
        //first lets do some mapping so we can navigate between records in bulk
        
        Map<Id,List<OpportunitySplit>> opportunitySplitMap = new Map<Id,List<OpportunitySplit>>();         
        for(OpportunitySplit oppSplit : oppSplits ){          
            if(!opportunitySplitMap.containskey(oppSplit.OpportunityId)){              
                opportunitySplitMap.put(oppSplit.OpportunityId,new List<OpportunitySplit>());               
            }
            opportunitySplitMap.get(oppSplit.OpportunityId).add(oppSplit);             
        }         
        system.debug('opportunitySplitMap: '+opportunitySplitMap);
           
        //now that we've got things mapped, lets go over the products and see if we need to split them
           
        for(Reporting_Product__c rp : newProducts){
            
            // if the products parent opportunity has splits, lets pull them out into a temporary list
               
            if(opportunitySplitMap.containskey(rp.Opportunity__c)){                
                List<OpportunitySplit> tempSplitList = opportunitySplitMap.get(rp.Opportunity__c);                        
                        
                //for every split in the list, we need to clone the original and adjust the value and owner based on the split
                for(OpportunitySplit split : tempSplitList){
                    Reporting_Product__c tempProduct = rp.clone();
                    tempProduct.Value__c = tempProduct.Value__c * split.SplitPercentage / 100;
                    tempProduct.OwnerId = split.SplitOwnerId;
                    replacementProducts.add(tempProduct);
                }
            }else{
                // if there was no opportunity splits on the parent return the original, in bulk updates, may be mix of split and unsplit
                replacementProducts.add(rp);
            }   
          
        }      
        return replacementProducts ;
         
    }
    


}