/**********************************************************************
Name:  Ge_Tender_DAO
Copyright © 2023
======================================================
======================================================
Purpose:  DAO class for Tender Object

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
1.0      Lynn Mejos          07/04/2023     
***********************************************************************/
public class Ge_Tender_DAO {

    /*******************************************************************
    @description Method to retrieve Tender using Opportunity Ids
    @param Set<Id> parentIds - list of Opportunity Ids
    @return List<Opportunity> – list of Opportunities
    @author Lynn Mejos
    @date 07/04/2023
    ********************************************************************/
    public static List<Tender__c> getTenderByOpportunityId(Set<Id> parentIds){
        return [SELECT Id,opportunity__c,Total_tender_commission__c,stage__c,IsUnsuccessful__c,
                associated_RM__c FROM Tender__c WHERE Opportunity__c IN :parentIds];
    }

    /*******************************************************************
    @description Method to retrieve Tender using Tender Ids
    @param Set<Id> parentIds - list of Opportunity Ids
    @return List<Opportunity> – list of Opportunities
    @author Lynn Mejos
    @date 07/04/2023
    ********************************************************************/
    public static List<Tender__c> getTenderById(Set<Id> parentIds){
        return [SELECT Id,Total_tender_commission__c FROM Tender__c WHERE Id IN :parentIds];
    }
}