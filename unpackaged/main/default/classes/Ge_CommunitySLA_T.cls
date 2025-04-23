/**********************************************************************
Name:  Ge_CommunitySLA_T
Copyright © 2023
======================================================
======================================================
Purpose:  Test Class for the Ge_CommunitySLA_I class

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
1.0      Lynn Mejos          07/04/2023     
***********************************************************************/
@isTest
public class Ge_CommunitySLA_T {

    /**
     * @methodname - InvocableMethodTest
     * @description - To cover getNextActionDate method
     */
    @isTest 
    private static void InvocableMethodTest(){
        Date curDate = System.today();
        Ge_CommunitySLA_I.Requests req = new Ge_CommunitySLA_I.Requests();
        req.timeRecieved = curDate.addDays(-5);
        req.timeResponded = curDate.addDays(5);
        List<Ge_CommunitySLA_I.Requests> requests = new List<Ge_CommunitySLA_I.Requests>();
        requests.add(req);
        Test.StartTest();
        List<Boolean> res = Ge_CommunitySLA_I.hitCommunitySLA(requests);
        test.stopTest();
        System.assertEquals(false, res[0]);
    }
}