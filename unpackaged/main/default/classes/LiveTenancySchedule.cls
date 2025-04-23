global without sharing class LiveTenancySchedule implements Schedulable  {
    
    global void execute(SchedulableContext SC) {
        system.debug('run LiveTenancySchedule');
        
        LiveTenancyUpdate ltu = new LiveTenancyUpdate();
        
        Database.executeBatch(ltu,200);
        
    }  
}