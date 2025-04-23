/**********************************************************************
Name:  Ge_UnlockOpportunity_I
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
public class Ge_UnlockOpportunity_I {

    /*******************************************************************
    @description Method to create new OrderItem from existing OpportunityLineItem
    @param List<Requests> request - list of request variables
    @return List<Results> – list of new tender products to create
    @author Lynn Mejos
    @date 13/03/2023
    ********************************************************************/
    @InvocableMethod(label='Unlock Opportunity Record' description='Returns the Opportunities' category='Opportunity')
    public static List<Id> unlockOpportunity(List<Id> oppId) {
        unlockOpportunityFuture(oppId[0]);
        return oppId;
    }
    @future private static void unlockOpportunityFuture(Id oppId){
        List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE Id =:oppId];
        if(!opps.isEmpty()){
            Approval.UnlockResult unlockedResult = Approval.unlock(opps.get(0).Id);
            // Iterate through each returned result
            if (unlockedResult.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('TrOppportunity: Successfully unlocked opportunity with ID: ' + unlockedResult.getId());
            }
            else { 
                for(Database.Error err : unlockedResult.getErrors()) {
                    System.debug('TrOppportunity: The following error has occurred.');      
                }
            }
        }
    }
    
}