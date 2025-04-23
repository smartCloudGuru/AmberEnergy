global class EmailPublisherLoader implements QuickAction.QuickActionDefaultsHandler {
    // Empty constructor
    global EmailPublisherLoader() {
    }
    
    // The main interface method
    global void onInitDefaults(QuickAction.QuickActionDefaults[] defaults) {
        
        QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = (QuickAction.SendEmailQuickActionDefaults)defaults.get(0);
        EmailMessage emailMessage = (EmailMessage)sendEmailDefaults.getTargetSObject(); 
        
        Case c = [SELECT CaseNumber,Priority,RecordTypeId FROM Case WHERE Id=:sendEmailDefaults.getContextId()];
        RecordType rt = [SELECT Id FROM RecordType where DeveloperName = 'Cases_for_Cusomer_Queries_and_Complaints'];

        if (c.RecordTypeId == rt.Id ) {
            emailMessage.FromAddress = 'bureauqueries@amberenergy.net';        
        }        
    }   
}