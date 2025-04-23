global class MilestoneTimeCalculator implements Support.MilestoneTriggerTimeCalculator {
    
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
    
        //Case c = [SELECT Priority FROM Case WHERE Id=:caseId];
        
        //we'll need to provide minutes back for our 3 current milestones
        // Next Wording Day Response
        // Next Working Day Resolution
        // 5 Working Day Resolution
        
        //method will be to calc the time from now the case opened time til end of day in minutes
        //then add on need number of working days. Busniess hours have been set for midnight to midnight for week days
        
        Case c = [SELECT CreatedDate FROM Case WHERE Id=:caseId];
        
        Integer hoursLeftToday = 23 - c.CreatedDate.hour();
        Integer minutesLeftToday = 59 - c.CreatedDate.minute();
        
        MilestoneType mt = [SELECT Name FROM MilestoneType WHERE Id=:milestoneTypeId];
        if (mt.Name.equals('5 Working Day Resolution')) { 
            return (1440 * 5 ) + (hoursLeftToday * 60) + minutesLeftToday;
        }
        else{
            return 1440 + (hoursLeftToday * 60) + minutesLeftToday;
        }
          
   }

}