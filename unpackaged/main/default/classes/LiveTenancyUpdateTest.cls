@isTest 

public class LiveTenancyUpdateTest {
    
    static testMethod void testLiveTenancyBatch() {
        
        TestData.setupCustomSettings();
        
        test.startTest();
        
        Account a = TestData.createClientAccount();
        insert a;
        
        Site__c s = new Site__c(name='TestSite',operator__c=a.id,account__c=a.id);
        insert s;
                
        Building__c b = new Building__c(name='TestBuilding');
        insert b;
        
        Property__c p = new Property__c(building__c=b.Id,name='TestProperty');
        insert p;
        
        Contact r = new Contact(LastName='TestName',Phone='1');
        insert r;
        
        Tenancy__c t1 = new Tenancy__c(name='TestTenancy',name_copy__c='TestTenancy',From_Date__c=system.today()-1,Property__c=p.Id,Resident__c=r.Id,Status__c='Live');
        insert t1;
        
        Tenancy__c t2 = new Tenancy__c(name='TestTenancy2',name_copy__c='TestTenancy2',From_Date__c=system.today()-1,To_Date__c=system.today()+1,Property__c=p.Id,Resident__c=r.Id,Status__c='Live');
        insert t2;
        
        Recordtype communityRecordType = [select Id from Recordtype where name = 'COMM:UNITY' and sobjecttype='Case'];
        
        Case c = new Case(recordtypeid=communityRecordType.Id,Status='Not Started',Reason='Multiple Live Residencies',Duration_of_Cae__c=1,X1_Day_Case_Reason__c='N/A',
                            Follow_up_Action_Date__c=system.today()+1,Subject=p.Name, Description='Test Case',Property__c=p.Id,contactid=r.id,Site__c=s.id,Landlord_Resident__c='Landlord',Tenancy_Unknown__c=TRUE);
        insert c;
        c.status='Closed';
        update c;
            
        LiveTenancyUpdate ltu = new LiveTenancyUpdate();     
        Database.executeBatch(ltu,200); 
        
        test.stopTest();
        
        Property__c testProp = [select Id,Has_Active_Tenancy__c from Property__c where id =:p.Id];  
        system.debug('testProp: '+testProp);
        system.assert(testProp.Has_Active_Tenancy__c);   
    }
    
    
}