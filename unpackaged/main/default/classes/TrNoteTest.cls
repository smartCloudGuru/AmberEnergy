@isTest
private class TrNoteTest {

    static testMethod void testOpportunityNote() {
       
       
       //create an account
        //Account testAccount = TestData.createClientAccount();
        //insert testAccount;  
                  
        //create an opportunity
        //Opportunity testOpp = TestData.createNewBusinessOpportunity(testAccount.Id);
        //insert testOpp;
        
        ContentVersion cv = new Contentversion(); 
        cv.Title = 'CZDSTOU'; 
        cv.PathOnClient = 'test'; 
        cv.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'); 
        insert cv;
        
        cv.title = 'test2';
        update cv;
       
    }
}