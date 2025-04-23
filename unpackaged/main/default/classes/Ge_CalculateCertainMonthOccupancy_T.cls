/**********************************************************************
Name:  Ge_CalculateCertainMonthOccupancy_T
Copyright © 2023
======================================================
======================================================
Purpose:  Test class for Ge_CalculateCertainMonthOccupancy_B

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
1.0     	Lynn Mejos          26/06/2024     
***********************************************************************/
@isTest
public class Ge_CalculateCertainMonthOccupancy_T {

    @testSetup static void setup() {
        // Create test data
        Account acc = TestData.createClientAccount();
        acc.Ge_HideFrom3rdPartyVisibility__c = false;
        insert acc;

        Site__c site = new Site__c(name = 'TestCaseSite', operator__c = acc.id, account__c = acc.id);
        insert site;
                
        Building__c b = new Building__c(name='TestBuilding', Site__c = site.Id,Ge_HideFrom3rdPartyVisibility__c = false);
        insert b;
        
        Property__c p = new Property__c(building__c=b.Id,name='TestProperty');
        insert p;
        
        Contact r = new Contact(LastName='TestName',Phone='1',Email='test@email.com');
        insert r;
        
        Tenancy__c t1 = new Tenancy__c(name='TestTenancy1',name_copy__c='TestTenancy1',From_Date__c=system.today()-1,Property__c=p.Id,Resident__c=r.Id,Status__c='Live');
        insert t1;
        
        Tenancy__c t2 = new Tenancy__c(name='TestTenancy2',name_copy__c='TestTenancy2',From_Date__c=system.today()-1,To_Date__c=system.today()+1,Property__c=p.Id,Resident__c=r.Id,Status__c='Live');
        insert t2;
        
        Monthly_Occupancy__c monthlyOccupancy = new Monthly_Occupancy__c(Property__c = p.Id, Days_Unnoccupied__c=0,Month_Beginning__c=system.today().toStartOfMonth());
        insert monthlyOccupancy;
        
    }
    @isTest 
    private static void calculateOccupancyTest(){
        Ge_CalculateCertainMonthOccupancy_B shn = new Ge_CalculateCertainMonthOccupancy_B('06','2023'); 
        database.executeBatch(shn);
    }
}