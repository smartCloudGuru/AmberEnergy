/**********************************************************************
Name:  Ge_CalculateCertainMonthOccupancy_B
Copyright © 2023
======================================================
======================================================
Purpose:  Batch class to create Monthly Occupancy record to all Properties of a specific month

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
1.0     	Lynn Mejos          26/06/2024     
***********************************************************************/
global class Ge_CalculateCertainMonthOccupancy_B implements Database.Batchable<sObject> {
    private String strParamMonth;
    private String strParamYear;

    public Ge_CalculateCertainMonthOccupancy_B(String strMonth, String strYear) {
        strParamMonth = strMonth;
        strParamYear = strYear;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select ID, Name FROM Property__c';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Property__c> scope) { 
        List<Monthly_Occupancy__c> newSpecifiedMonthOccupancyList = new List<Monthly_Occupancy__c>();
        Map<Id, Property__c> propertyMap = new Map<Id, Property__c>(scope);
        Map<Id, Monthly_Occupancy__c> propertyMonthlyOccupancyMap = new Map<Id, Monthly_Occupancy__c>();
        Date monthBeginning = date.parse( ' 01/' + strParamMonth + '/' + strParamYear);

        List<Monthly_Occupancy__c> existingMonthlyOccupancyList = [SELECT ID, Property__c FROM Monthly_Occupancy__c 
                                                                   WHERE Property__c IN: propertyMap.keySet() AND Month_Beginning__c=:monthBeginning];
        for(Monthly_Occupancy__c m: existingMonthlyOccupancyList){
            propertyMonthlyOccupancyMap.put(m.Property__c, m);
        }
        for(Property__c p: scope){
            if(propertyMonthlyOccupancyMap.get(p.Id) == null){
                Monthly_Occupancy__c mo = new Monthly_Occupancy__c();
                mo.Property__c = p.Id;
                mo.Name = p.Name + ' 01/' + strParamMonth + '/' + strParamYear;
                mo.Month_Beginning__c = date.parse( ' 01/' + strParamMonth + '/' + strParamYear);
                mo.Calculate_Occupancy__c = TRUE;
                mo.Days_Unnoccupied__c = 0;
                newSpecifiedMonthOccupancyList.add(mo);
            }
        }
        insert newSpecifiedMonthOccupancyList;
        
        for(Monthly_Occupancy__c mo: newSpecifiedMonthOccupancyList){
            mo.Calculate_Occupancy__c = TRUE;
        }
        
        update newSpecifiedMonthOccupancyList;
    }   

    global void finish(Database.BatchableContext BC) {
    }
}