/**
 */
@isTest(SeeAllData=true)
private class SmartTemplateLoaderTest {

    static testMethod void testSmartTemplateLoader() {
    
        //make a case
        Case c = TestData.createCase();
        insert c;
    
        //get the id of the default template for comparison
        EmailTemplate et = [SELECT id FROM EmailTemplate WHERE DeveloperName =:SmartTemplateLoader.DEFAULT_TEMPLATE];
        
        SmartTemplateLoader stl = new SmartTemplateLoader();
        Id defaultTemplateId = stl.getDefaultEmailTemplateId(c.id);
        
        system.assertequals(defaultTemplateId,et.Id);  
      
    }
}