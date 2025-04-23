/**
* Class for holding Date utility methods and invocable methods that can be called from processes
*/

public without sharing class DateUtilities {
    
    public static List<Holiday> holidays = [Select Id,ActivityDate from Holiday /* where ActivityDate>= :System.today()*/];
    
    /**@Description Returns all the holiday dates currently in the system as a List
    @Author Richard Williams June 18
    */
    public static Set<Date> getFutureHolidayDates(){
        Set<Date> returnDate = new Set<Date>();
        for (Holiday h : holidays){
            returnDate.add(h.ActivityDate);
        }
        return returnDate;
    }
    
    /**@Description Returns the number of non working days between two dates 
    @Author Richard Williams June 18
    */
    public static integer nonWorkingDaysBetween(Date startDate, Date endDate){
        
        startDate = startDate.addDays(1);
        integer nonWorkingDays = 0;     
        while (startDate <= endDate){       
            // if its a non working day
            if(dayIsNonWorking(startDate)){
                nonWorkingDays++;
            }       
            startDate = startDate.addDays(1);   
        }                       
        system.debug('nonWorkingDaysBetween returning: '+nonWorkingDays);
        return nonWorkingDays;
    }
    
    /**@Description Returns if a given date is a non working day
    @Author Richard Williams June 18
    */
    public static Boolean dayIsNonWorking(Date checkDate){
        Set<Date> holidayDates = getFutureHolidayDates();
        Date monday = Date.newInstance(1900,1,1);
        Integer dayNum = Math.mod(monday.daysBetween(checkDate),7);
        // if its a non working day
        if( dayNum == 5 || dayNum == 6 || holidayDates.contains(checkDate) ){
            system.debug('Check dayIsNonWorking '+checkDate+' : true');
            return true;
        } 
        system.debug('Check dayIsNonWorking '+checkDate+' : false');
        return false;       
    }
    
    
    /**@Description Returns a corrected date after excluding non working days and bank holidays
    @Author Richard Williams June 18
    */
    public static Date getNextActionDate(Date proposedDate){
        integer nonWorkingDaysBetween = nonWorkingDaysBetween(system.today(), proposedDate);         
        proposedDate = proposedDate + nonWorkingDaysBetween;
        //if we land on a non working day then push date along until we are working
        while( dayIsNonWorking(proposedDate) ){
            proposedDate = proposedDate.addDays(1);
        }
        system.debug('getNextActionDate returning: '+proposedDate);
        return proposedDate;
    }
    
    /**@Description Gets the next first of the month after a given date, inclusive
    @Author Richard Williams Dec 18
    */
    public static Date getNextFirstOfMonth(Date inputDate){
        system.debug('getNextFirstOfMonth inputDate:'+inputDate);
        // if we were given a 1st of month then just retain the same date
        if(inputDate == inputDate.toStartOfMonth()){
            system.debug('getNextFirstOfMonth return:'+inputDate);
            return inputDate;
        }else{
            // else, add a month to the date and go back to the start of the new month
            inputDate = inputDate.addMonths(1);
            system.debug('getNextFirstOfMonth return:'+inputDate.toStartOfMonth());
            return inputDate.toStartOfMonth();
        }   
    }
    
    /**@Description Returns all the 1st of the month dates between two dates, inclusive
    @Author Richard Williams Dec 18
    */
    public static List<Date> getFirstOfMonthsBetween(Date startDate, Date endDate){
        system.debug('getFirstOfMonthsBetween: '+startDate+' '+endDate);
        List<Date> firstsOfMonth = new List<Date>();
        Date tempDate = startDate;
         
        //first check if the start date should go in the list
        system.debug('tempDate pre strt check:'+tempDate);
        if(startDate == startDate.toStartOfMonth()){
            firstsOfMonth.add(startDate);
            //we must pass the getNextFirstOfMonth method a non 1st or we'll infitely loop
            tempDate = tempDate+1; 
        }
             
        //keep finding the first of next month until its over the end date
        while(tempDate <= endDate){         
            tempDate = getNextFirstOfMonth(tempDate);
            if(tempDate <= endDate){
                firstsOfMonth.add(tempDate);
            }
            //we must pass the getNextFirstOfMonth method a non 1st or we'll infitely loop
            tempDate = tempDate+1;
        }  
        system.debug('firstsOfMonth: '+firstsOfMonth);
        system.debug('firstsOfMonth size: '+firstsOfMonth.size());
        return firstsOfMonth;
    }
    
    /**@Description Returns a list of Dates that represent quarterly payment dates between two dates, inclusive
    @Author Richard Williams Dec 18
    */
    public static List<Date> getQuarterlysBetween(Date startDate, Date endDate){
        system.debug('getQuarterlysBetween: '+startDate+' '+endDate);
        List<Date> quarterlys = new List<Date>();
        //first lets get all the 1st of the months
        List<Date> firsts = getFirstOfMonthsBetween(startDate,endDate);
        
        for(Integer i = 0; i < firsts.size(); i=i+3){
            quarterlys.add(firsts.get(i));
        }
        system.debug('quarterlys: '+quarterlys);
        return quarterlys;
    }
    
    /**
    */
    public static Date getNextWorkingDay(Date startDate){
        system.debug('getNextWorkingDay after: '+startDate);
        //Add a day to the date given
        startDate.addDays(1);
        //If the new date is not a working day keep adding one day until it is
        while(!dayIsNonWorking(startDate)){
            startDate.addDays(1);
        }
        return startDate;
    }
    
    
      
}