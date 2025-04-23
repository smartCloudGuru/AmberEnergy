public with sharing class Ge_CheckIfWithinBusinessHours_I {

    @InvocableMethod(label = 'Check If Within Business Hours')
    public static List<Boolean> checkIfWithinBusinessHours(List<String> Name) {
        String bhName = String.valueOf(Name[0]);

        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE name= :bhName];
        Datetime targetTime = Datetime.now();
        Boolean isWithin= BusinessHours.isWithin(bh.id, targetTime);

        return new List<Boolean>{isWithin};
    }

}