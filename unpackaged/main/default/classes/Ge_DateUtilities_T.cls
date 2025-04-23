/**********************************************************************
Name:  Ge_DateUtilities_T
Copyright © 2023
======================================================
======================================================
Purpose:  Test Class for the Ge_DateUtilities_I class

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
1.0      Lynn Mejos          07/04/2023     
***********************************************************************/
@isTest
public class Ge_DateUtilities_T {

    /**
     * @methodname - InvocableMethodTest
     * @description - To cover getNextActionDate method
     */
    @isTest 
    private static void InvocableMethodTest(){
        List<Date> curDate = new List<Date>();
        curDate.add(System.today());
        Test.StartTest();
        List<Date> res = Ge_DateUtilities_I.getNextActionDate(curDate);
        test.stopTest();
    }

    /**
     * @methodname - InvocableMethodTest
     * @description - To cover getNextActionDate method
     */
    @isTest 
    private static void InvocableMethodTest2(){
        List<Date> curDate = new List<Date>();
        curDate.add(System.today()+30);
        Test.StartTest();
        List<Date> res = Ge_DateUtilities_I.getNextActionDate(curDate);
        test.stopTest();
    }
}