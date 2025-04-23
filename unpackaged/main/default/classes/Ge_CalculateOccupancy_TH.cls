/**********************************************************************
Name:  Ge_CalculateOccupancy_TH
Copyright © 2023
======================================================
======================================================
Purpose:  Handler class for MonthlyOccupancyTrigger

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
1.0     	Lynn Mejos          18/12/2023     
***********************************************************************/
public class Ge_CalculateOccupancy_TH {
    /*******************************************************************
    @description Method to calculate occupancy dates from Tenants
    @param Monthly_Occupancy__c updatedMonthlyOccupancy - existing monthly occupancy record
    @author Lynn Mejos
    @date 18/12/2023
    ********************************************************************/
    public static void calculateOccupancy(List<Monthly_Occupancy__c> updatedMonthlyOccupancy){
        Set<Id> propertyIdSet = new Set<Id>();
        List<Monthly_Occupancy__c> moForUpdate = new List<Monthly_Occupancy__c>();
        Map<Id,List<Tenancy__c>> propertyTenancyMap = new Map<Id,List<Tenancy__c>>();
        
        for(Monthly_Occupancy__c mo: updatedMonthlyOccupancy){
            if(mo.Calculate_Occupancy__c == true){
                moForUpdate.add(mo);
                propertyIdSet.add(mo.Property__c);
            }
        }
        List<Tenancy__c> tenancyList = [SELECT ID, From_Date__c, To_Date__c, Property__c  FROM Tenancy__c WHERE Property__c IN:propertyIdSet];
        List<Monthly_Occupancy__c> moTOUpdate = new List<Monthly_Occupancy__c>();

        for(Tenancy__c t: tenancyList){
            if(!propertyTenancyMap.containsKey(t.Property__c)){
                propertyTenancyMap.put(t.Property__c, new List<Tenancy__c>());
            }
            propertyTenancyMap.get(t.Property__c).add(t);
        }        
        
        for(Monthly_Occupancy__c mofu: moForUpdate){
            
            Integer monthInt = mofu.Month_Beginning__c.month();
            Integer year = mofu.Month_Beginning__c.year();
            Integer daysInMonth = date.daysInMonth(year, monthInt);
            Integer counter = 0;
            String unnocDays = '';
            /** Property occupied on MOVE IN and MOVE OUT dates */
            for(integer i = 0; i < daysInMonth; i++ ){
                Boolean dayOccupied = false;
                Date checkingDate = mofu.Month_Beginning__c.addDays(i);
                if(propertyTenancyMap.get(mofu.Property__c)!=null){
                    for(Tenancy__c t: propertyTenancyMap.get(mofu.Property__c)){
                        System.debug('checkingDate = '+checkingDate);
                        if(checkingDate >= t.From_Date__c && t.To_Date__c == null){
                            system.debug(checkingDate+' is occupied based on tenancy '+t);
                            dayOccupied = true;
                        }else if (checkingDate >= t.From_Date__c && checkingDate <= t.To_Date__c ){
                            system.debug(checkingDate+' is occupied based on tenancy '+t);
                            dayOccupied = true;
                        }
                    }
                }
                //if we have found an unnoccupied day then increase the count and add to the list
                if(!dayOccupied){
                    counter++;
                    integer insertDay = i+1;
                    unnocDays = unnocDays + insertDay +', ';
                }
            }
            mofu.Days_Unnoccupied__c = counter;
            mofu.Dates_Unnoccuped__c = unnocDays;  
            mofu.Calculate_Occupancy__c = false;  
        }
    }
}