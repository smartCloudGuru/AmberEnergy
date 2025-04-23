/**********************************************************************
Name:  Ge_SupplyContractToTenderRollupFlow_I
Copyright © 2023
======================================================
======================================================
Purpose:  Invocable class for Supply Contract - Supply Contract to Tender Rollup Flow

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0      Lynn Mejos          17/05/2023     
***********************************************************************/
public class Ge_SupplyContractToTenderRollupFlow_I {

    
    /*******************************************************************
    @description Method to rollup commission value to Tender from Supply Contract
    @param List<List<Supply_Contract__c>> request - list of request variables
    @return void
    @author Lynn Mejos
    @date 17/05/2023
    ********************************************************************/
    @InvocableMethod(label='Rollup to Tender' description='Updates Tender with total Supply Contract value' category='Supply_Contract__c')
    public static void rollupToTender(List<List<Supply_Contract__c>> supConList) {
        Set<Id> parentIds = new Set<Id>();
        for(Supply_Contract__c sc : supConList[0]){
            if(sc.tender__c != null){
                parentIds.add(sc.tender__c);    
            }                   
        }
        Ge_SupplyContractToTenderRollup_TH.rollUp(parentIds);
    }
}