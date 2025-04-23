/**
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TrSfRequestTest {

    static testMethod void basicRequestTest() {
        
        insert new SF_Requests__c(Overview_of_your_problem__c='test',What_should_happen__c='test',Who_does_it_affect__c='Sales');
    }

}