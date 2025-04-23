/**********************************************************************
Name:  Ge_Opportunity_DAO
Copyright © 2023
======================================================
======================================================
Purpose:  DAO class for Opportunity Object

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
1.0      Lynn Mejos          07/04/2023     
***********************************************************************/
public class Ge_Opportunity_DAO {

    /*******************************************************************
    @description Method to retrieve Opportunities
    @param Set<Id> parentIds - list of Opportunity Ids
    @return List<Opportunity> – list of Opportunities
    @author Lynn Mejos
    @date 07/04/2023
    ********************************************************************/
    public static List<Opportunity> getOpportunitiesById(Set<Id> parentIds){
        return [SELECT Id,Total_Tender_Value__c,Completed_Tender_Value__c FROM Opportunity WHERE Id IN :parentIds];
    }
}