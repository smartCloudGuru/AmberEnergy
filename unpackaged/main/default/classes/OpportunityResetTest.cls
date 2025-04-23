/**
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class OpportunityResetTest {

    static testMethod void testSchedule() {
        
        
        TestData.setupProductsAndPriceBooks();
        
        User u = TestData.createUser();
        insert u;
        
        Account a = TestData.createClientAccount();
        insert a;
        
        Opportunity o = TestData.createNormalOpportunity(a.Id,u.Id);
        insert o;
        
        OpportunityReset sh1 = new OpportunityReset();
        String sch = '0 0 23 * * ?';
        system.schedule('Test OpportunityReset Check', sch, sh1); 

    }
}