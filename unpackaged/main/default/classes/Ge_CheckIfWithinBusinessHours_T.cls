@isTest
public with sharing class Ge_CheckIfWithinBusinessHours_T {
    
    // @TestSetup
    // public static void setupData() {
    //     // Create Business Hours
    //     BusinessHours bh = new BusinessHours(
    //         Name = 'Test Business Hours',
    //         IsActive = true,
    //         MondayStartTime = Time.newInstance(9, 0, 0, 0),
    //         MondayEndTime = Time.newInstance(17, 0, 0, 0),
    //         TuesdayStartTime = Time.newInstance(9, 0, 0, 0),
    //         TuesdayEndTime = Time.newInstance(17, 0, 0, 0),
    //         WednesdayStartTime = Time.newInstance(9, 0, 0, 0),
    //         WednesdayEndTime = Time.newInstance(17, 0, 0, 0),
    //         ThursdayStartTime = Time.newInstance(9, 0, 0, 0),
    //         ThursdayEndTime = Time.newInstance(17, 0, 0, 0),
    //         FridayStartTime = Time.newInstance(9, 0, 0, 0),
    //         FridayEndTime = Time.newInstance(17, 0, 0, 0)
    //     );
        
    //     insert bh;
    // }

    public static testMethod void testAddBusinessHours() {
        // Name of the Business Hours got from Setup > Company Settings > Business Hours
        // Business Hours can't be created in test data setup
        Ge_CheckIfWithinBusinessHours_I.checkIfWithinBusinessHours(new List<String>{'Default'});
    }
}