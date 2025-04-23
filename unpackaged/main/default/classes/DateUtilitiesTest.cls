/**
 * Test class for the DateUtilies Class
 */
@isTest
private class DateUtilitiesTest {

    static testMethod void testGetFutureHolidayDates() {
        Set<Date> dateSet = DateUtilities.getFutureHolidayDates();
        System.assert(!dateSet.isEmpty());      
    }
    
    
    static testMethod void testNonWorkingDaysBetween() {
        Integer daysBetween = DateUtilities.nonWorkingDaysBetween(system.today(),system.today()+10);
        System.assert(daysBetween >= 2);      
    }
    
    
    static testMethod void getNextFirstOfMonth() {
        Date start = Date.newInstance(2019, 1, 12);
        Date expected = Date.newInstance(2019, 2, 1);
        Date testDate = Dateutilities.getNextFirstOfMonth(start);   
        System.assert(testDate == expected);
        
        start = Date.newInstance(2019, 1, 1);
        expected = Date.newInstance(2019, 1, 1);
        testDate = Dateutilities.getNextFirstOfMonth(start);    
        System.assert(testDate == expected);     
    }
    
    static testMethod void getFirstOfMonthsBetween() {
        Date start = Date.newInstance(2019, 1, 1);
        Date endd = Date.newInstance(2019, 12, 30);
        List<Date> dates = Dateutilities.getFirstOfMonthsBetween(start,endd);
        System.assert(dates.size() == 12);

        start = Date.newInstance(2019, 1, 1);
        endd = Date.newInstance(2020, 1, 1);
        dates = Dateutilities.getFirstOfMonthsBetween(start,endd);
        System.assert(dates.size() == 13);    
    }
    
    static testMethod void getQuarterlysBetween() {
        Date start = Date.newInstance(2019, 1, 1);
        Date endd = Date.newInstance(2019, 12, 30);
        List<Date> dates = Dateutilities.getQuarterlysBetween(start,endd);
        System.assert(dates.size() == 4);    
        
        start = Date.newInstance(2019, 1, 1);
        endd = Date.newInstance(2019, 8, 30);
        dates = Dateutilities.getQuarterlysBetween(start,endd);
        System.assert(dates.size() == 3);  
    }
    
    static testMethod void getNextWorkingDay() {
        Date start = Date.newInstance(2019, 1, 1);
        Date dateVal = Dateutilities.getNextWorkingDay(start);
        System.assert(dateVal != null);  
    }
    
    static testMethod void getNextActionDate() {
        Date start = Date.newInstance(2019, 1, 1);
        Date dateVal = Dateutilities.getNextActionDate(start);
        System.assert(dateVal != null);  
    }
    
    
}