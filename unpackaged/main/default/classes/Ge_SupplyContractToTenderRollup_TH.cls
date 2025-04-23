/**********************************************************************
Name:  Ge_SupplyContractToTenderRollup_TH
Copyright © 2023
======================================================
======================================================
Purpose:  Trigger Handler for the SupplyContractTrigger

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
1.0      Lynn Mejos          07/04/2023     
***********************************************************************/
public class Ge_SupplyContractToTenderRollup_TH {
    
    /*******************************************************************
    @description Method to execute on Undelete
    @param List<Supply_Contract__c> newTenders, List<Supply_Contract__c> oldTenders - list of new and old Supply_Contract__c
    @author Lynn Mejos
    @date 13/03/2023
    ********************************************************************/
    public static void afterUndelete(List<Supply_Contract__c> newContracts, List<Supply_Contract__c> oldContracts){
        Set<Id> parentIds = new Set<Id>();
        if(newContracts != null && !newContracts.isEmpty()){
            for(Supply_Contract__c sc : newContracts){
                if(sc.tender__c != null){
                    parentIds.add(sc.tender__c);	
                }					
            }
        }
        if(oldContracts != null && !oldContracts.isEmpty()){
            for(Supply_Contract__c sc : oldContracts){
                if(sc.tender__c != null){
                    parentIds.add(sc.tender__c);	
                }					
            }
        } 
        rollUp(parentIds);
    }
    public static void rollUp(Set<Id> parentIds){
        //map the contracts to the tenders
        Map<Id,List<Supply_Contract__c>> contractMap = new Map<Id,List<Supply_Contract__c>>();
        
        //get all the parent Tenders		
        List<Tender__c> parentTenders = Ge_Tender_DAO.getTenderById(parentIds);
        
        if(!parentTenders.isEmpty()){
            //get all the other children for each parent tender, keep the original supply contracts that triggered as they have new values that arent yet commited
            List<Supply_Contract__c> allContracts = Ge_SupplyContract_DAO.getSupplyContractByTenderId(parentIds);
            for(Tender__c t : parentTenders){
                contractMap.put(t.Id,new List<Supply_Contract__c>());
            }
            if(!allContracts.isEmpty()){
                for(Supply_Contract__c supCon : allContracts){
                    if(contractMap.containskey(supCon.tender__c)){
                        contractMap.get(supCon.tender__c).add(supCon);	
                    }			
                }	
            }
            
            update assignTenderCommission(parentTenders, contractMap);
        }
    }
    
    public static List<Tender__c> assignTenderCommission(List<Tender__c> parentTenders, Map<Id,List<Supply_Contract__c>> contractMap){
        //so now we can go through each tender, getting their list of child contracts, and sum them up
        for(Tender__c t : parentTenders){
            List<Supply_Contract__c> contractScope = contractMap.get(t.Id);
            decimal runningSum = 0;
            if(!contractScope.isEmpty()){				
                for(Supply_Contract__c sc : contractScope){
                    if(sc.contract_Value__c != null){
                        runningSum = runningSum + sc.contract_Value__c;	
                    }				
                }
            }
            //if the runningSum is not the same as the existing commission total it will need an update
            if(t.Total_tender_commission__c != runningSum){
                t.Total_tender_commission__c = runningSum;
            }
        }
        return parentTenders;
    }
}