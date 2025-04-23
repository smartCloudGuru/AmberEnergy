public with sharing class CRMA_RecipeRun_DAO {
  

    public static List<CRM_CRMRecipeRun__c> getRecipeRunsByRecipeId(String recipeId) {
        return [SELECT ID,
                       Name,
                       CRM_Duration__c,
                       CRM_EndTime__c,
                       CRM_JobId__c,
                       CRM_Message__c,
                       CRM_NextCheckTime__c,
                       CRM_RecipeId__c,
                       CRM_RetryCount__c,
                       CRM_StartTime__c,
                       CRM_Status__c,
                       CRM_WaitTime__c
                FROM CRM_CRMRecipeRun__c
                WHERE CRM_RecipeId__c = :recipeId];
    }

    public static List<CRM_CRMRecipeRun__c> getNotCompleteRecipeRuns() {
        return [SELECT ID,
                       Name,
                       CRM_Duration__c,
                       CRM_EndTime__c,
                       CRM_JobId__c,
                       CRM_Message__c,
                       CRM_NextCheckTime__c,
                       CRM_RecipeId__c,
                       CRM_RetryCount__c,
                       CRM_StartTime__c,
                       CRM_Status__c,
                       CRM_WaitTime__c,
                       (SELECT id,CRMA_RequestingUser__c FROM User_CRM_Recipe_Request__r)
                FROM CRM_CRMRecipeRun__c
                WHERE CRM_Status__c != 'Complete'
                AND CRM_Status__c != 'Failure'
                AND CRM_Status__c != 'Success'];
    }

    public static List<CRM_CRMRecipeRun__c> getNotCompleteRecipeRunsByRecipeId(string recipeId) {
        return [SELECT ID,
                       Name,
                       CRM_Duration__c,
                       CRM_EndTime__c,
                       CRM_JobId__c,
                       CRM_Message__c,
                       CRM_NextCheckTime__c,
                       CRM_RecipeId__c,
                       CRM_RetryCount__c,
                       CRM_StartTime__c,
                       CRM_Status__c,
                       CRM_WaitTime__c
                FROM CRM_CRMRecipeRun__c
                WHERE CRM_Status__c != 'Complete'
                AND CRM_Status__c != 'Failure'
                AND CRM_Status__c != 'Success'
                AND CRM_RecipeId__c = :recipeId];
    }
}