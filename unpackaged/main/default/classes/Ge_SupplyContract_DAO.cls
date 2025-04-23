/**********************************************************************
Name:  Ge_SupplyContract_DAO
Copyright © 2023
======================================================
======================================================
Purpose:  DAO class for Supply Contract Object

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
1.0      Lynn Mejos          07/04/2023     
***********************************************************************/
public class Ge_SupplyContract_DAO {

    /*******************************************************************
    @description Method to retrieve Supply Contracts using Tender Ids
    @param Set<Id> parentIds - list of Tender Ids
    @return List<Supply_Contract__c> – list of Supply Contract
    @author Lynn Mejos
    @date 07/04/2023
    ********************************************************************/
    public static List<Supply_Contract__c> getSupplyContractByTenderId(Set<Id> parentIds){
        return [SELECT Id,tender__c,contract_Value__c FROM Supply_Contract__c
                WHERE Tender__c IN :parentIds];
    }
}