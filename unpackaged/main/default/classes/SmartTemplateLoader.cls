global class SmartTemplateLoader implements Support.EmailTemplateSelector {

    public static final String DEFAULT_TEMPLATE = 'Generic_Amber_Response';
    
    // Empty constructor
    global SmartTemplateLoader() {
    }
    // The main interface method
    global ID getDefaultEmailTemplateId(ID caseId) {
    
        // get the template ID
        List<EmailTemplate> ets = [SELECT id,DeveloperName FROM EmailTemplate WHERE DeveloperName = :DEFAULT_TEMPLATE];
        //Return the ID of the template selected
        if (!ets.isEmpty()) {
            EmailTemplate et = ets[0];
            System.debug('template: ' + et.DeveloperName + ' -- id: ' + et.id);
            return et.id;
        }

        return null;
    }
}