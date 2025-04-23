/**
 * A TestData class has been implemented to house static methods can be called to create testing data.
 * This class will still need to be tested to improve the system code coverage.
 */
@isTest(SeeAllData=true)
private class TestDataTest {

    static testMethod void testCreateUser(){
        User testUser = TestData.createUser();
        system.assertnotequals(null,testUser); 
        insert testUser;
    }
    
    static testMethod void testCreateClientAccount() {
        Account testAccount = TestData.createClientAccount();
        system.assertnotequals(null,testAccount);   
        insert testAccount;     
    }
    
    static testMethod void testCreateClientAccounts() {
        List<Account> testAccounts = TestData.createClientAccounts(3);  
        system.assertequals(3,testAccounts.size());   
        insert testAccounts;     
    }
    
    static testMethod void testCreateNormalOpportunity() {
        User testUser = TestData.createUser();
        insert testUser;
        
        System.runAs(testUser){
            Account testAccount = TestData.createClientAccount(); 
            insert testAccount;
            
            Opportunity testOpp = TestData.createNormalOpportunity(testAccount.Id,testUser.Id);
            system.assertnotequals(null,testOpp);        
            insert testOpp;
        }    
    }

}