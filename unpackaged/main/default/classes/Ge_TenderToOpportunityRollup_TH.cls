/**********************************************************************
Name:  Ge_TenderToOpportunityRollup_TH
Copyright © 2023
======================================================
======================================================
Purpose:  Trigger Handler for the TenderTrigger

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
1.0      Lynn Mejos          06/04/2023     
***********************************************************************/
public class Ge_TenderToOpportunityRollup_TH {
    
    /*******************************************************************
    @description Method to execute on Undelete
    @param List<Tender__c> newTenders, List<Tender__c> oldTenders - list of new and old Tender
    @author Lynn Mejos
    @date 13/03/2023
    ********************************************************************/
    public static void afterUndelete(List<Tender__c> newTenders, List<Tender__c> oldTenders){
        Set<Id> parentIds = new Set<Id>();
        if(newTenders != null && !newTenders.isEmpty()){
            for(Tender__c t : newTenders){
                if(t.opportunity__c != null){
                    parentIds.add(t.opportunity__c);	
                }					
            }
        }
        if(oldTenders != null && !oldTenders.isEmpty()){
            for(Tender__c t : oldTenders){
                if(t.opportunity__c != null){
                    parentIds.add(t.opportunity__c);	
                }					
            }
        } 
        rollUp(parentIds);
    }

    /*******************************************************************
    @description Starts from the Tender level and rolls up commission value into the Tenders parent Opportunities
    @param Set<Id> parentIds - Set of Opportunity Ids
    @author Lynn Mejos
    @date 13/03/2023
    ********************************************************************/
    public static void rollUp(Set<Id> parentIds){ 
        Map<Id,List<Tender__c>> tenderMap = new Map<Id,List<Tender__c>>(); //map the opps to their tenders 
        List<Opportunity> parentOpps = Ge_Opportunity_DAO.getOpportunitiesById(parentIds); //get all the parent Opportunities
        
        if(!parentOpps.isEmpty()){
            //get all the other children for each parent opportunity, keep the original tenders that triggered as they have new values that arent yet commited
            List<Tender__c> allTenders = Ge_Tender_DAO.getTenderByOpportunityId(parentIds);
            
            //put an entry in for each opp						 
            for(Opportunity o : parentOpps){
                tenderMap.put(o.Id,new List<Tender__c>());  			 
            }
            //put in the extra tenders we found
            if(!allTenders.isEmpty()){  
                for(Tender__c t : allTenders){ 
                    if(tenderMap.containskey(t.opportunity__c)){
                        tenderMap.get(t.opportunity__c).add(t);	
                    }					
                } 
            } 
            
            //so now we can go through each tender, getting their list of child tenders, and sum them up
            for(Opportunity o : parentOpps){
                List<Tender__c> tenderscope = tenderMap.get(o.Id);
                if(!tenderscope.isEmpty()){ 
                    o = getUpdatedOpportunity(tenderscope, o);
                }else{
                    //set values for where opp has not tenders
                    o.hasOpenTender__c = false;
                    o.hasTender__c = false;	
                    o.Total_Tender_Value__c = null;
                    o.Completed_Tender_Value__c = null;				
                }
            }   
            update parentOpps; 
        }
    } 
    

    /*******************************************************************
    @description Starts from the Tender level and rolls up commission value into the Tenders parent Opportunities
    @param List<Tender__c> tenderscope, Opportunity o - List of Tender and Opportunity
    @return Updated Opportunity
    @author Lynn Mejos
    @date 13/03/2023
    ********************************************************************/
    public static Opportunity getUpdatedOpportunity(List<Tender__c> tenderscope, Opportunity o){
        decimal runningSum = 0; 
        decimal completedRunningSum = 0; 
        Boolean opHasOpenTender = false;
        for(Tender__c t : tenderscope){ 						
            if(t.stage__c == 'Complete' && !t.IsUnsuccessful__c && t.Total_tender_commission__c != null){
                completedRunningSum = completedRunningSum + t.Total_tender_commission__c;
            }						
            if(t.Total_tender_commission__c != null){
                runningSum = runningSum + t.Total_tender_commission__c;
            }	
            if(t.stage__c != 'Complete'){
                opHasOpenTender = true;
                o.latestTenderRM__c = t.associated_RM__c;
            }				 
        }
        //set values where opp has tenders
        o.hasTender__c = true;
        o.hasOpenTender__c = opHasOpenTender;
        o.Total_Tender_Value__c = runningSum; 
        o.Completed_Tender_Value__c = completedRunningSum;
        return o;
    }
    
}