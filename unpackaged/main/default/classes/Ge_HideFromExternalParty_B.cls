/**********************************************************************
 Name:  Ge_HideFromExternalParty_B
 Copyright © 2024
 ======================================================
======================================================
Purpose: Batch and invocable class to hide or show records from external party
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0      Dave Liskevich       12/05/2024       Initial Creation    Initial Creation    
***********************************************************************/  
global with sharing class Ge_HideFromExternalParty_B implements  Database.Batchable<sObject> {

    global Ge_HideFromExternalParty_B() {}

    global List<String> recordIds;
    global boolean hideFromExternalParty;
    global Ge_HideFromExternalParty_B(List<String> recordIds, boolean hideFromExternalParty) {
        this.recordIds = recordIds;
        this.hideFromExternalParty = hideFromExternalParty;

    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id FROM Case WHERE Id IN :recordIds]);
    }

    global void execute(Database.BatchableContext BC, List<Case> scope) {
        for(Case c : scope) {
            c.Ge_HideFrom3rdPartyVisibility__c = hideFromExternalParty; 
        }
        update scope;
    }

    global void finish(Database.BatchableContext BC) {
    }

    @InvocableMethod(label='Set Visibility on records for external parties'  category='Case')
    global static void setVisibility(List<VisibilityRequest> requests) {
        List<String> trueIds = new List<String>();
        List<String> falseIds = new List<String>();
                


        for(VisibilityRequest request : requests) {
            if(request.hideFromExternalParty) {
                trueIds.addAll(request.recordIds);
            } else {
                falseIds.addAll(request.recordIds);
            }
        }

        if (!trueIds.isEmpty()) {
            Database.executeBatch(new Ge_HideFromExternalParty_B(trueIds, true),20);
        } 

        if (!falseIds.isEmpty()) {
            Database.executeBatch(new Ge_HideFromExternalParty_B(falseIds, false), 20);
        }
    }

    
    
    global class VisibilityRequest {
        global VisibilityRequest() {}
        @InvocableVariable(label='Record Ids' description='The record ids to update' required=true)
        global List<String> recordIds;
        @InvocableVariable(label='Hide from External Party' description='True to hide from external party, false to show' required=true)
        global boolean hideFromExternalParty;}

}