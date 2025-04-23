/**
 * Created by ukaya01 on 9/29/2021.
 */

@IsTest
public with sharing class DynamicLookupControllerTest {

    @TestSetup
    static void setup(){
        Account acc = TestData.createClientAccount();
        insert acc;
    }

    @IsTest
    static void searchAccount(){
        DynamicLookupController.SearchParameter param = new DynamicLookupController.SearchParameter();
        param.icon = 'test';
        param.objectName = 'Account';
        param.filters = '';
        List<DynamicLookupController.SearchParameter> parameters = new List<DynamicLookupController.SearchParameter>{param};
        Test.startTest();
        List<Account> accounts = [SELECT Id, Name FROM Account];
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = accounts.get(0).Id;
        Test.setFixedSearchResults(fixedSearchResults);
        List<LookupSearchResult> result = DynamicLookupController.search('test', null, null, JSON.serialize(parameters));
        Test.stopTest();
        system.assert(!result.isEmpty());
    }

}