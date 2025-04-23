/**********************************************************************
Name:  Ge_CommunitySLA_I
Copyright © 2023
======================================================
======================================================
Purpose:  Invocable class for Email Message flow

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0      Lynn Mejos          28/03/2023     
***********************************************************************/
public class Ge_CommunitySLA_I {
    /*******************************************************************
    @description Method to create new Tender Products from existing Supply Contract
    @param List<Requests> request - list of request variables
    @return List<Results> – list of new tender products to create
    @author Lynn Mejos
    @date 13/03/2023
    ********************************************************************/
    @InvocableMethod(label='Get Case Community SLA' description='Returns the SLA' category='Case')
    public static List<Boolean> hitCommunitySLA(List<Requests> timeInputs) {
        List<Boolean> returnValue = new List<Boolean>();        
        final integer COMMUNITY_SLA_LIMIT = 1;
        
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault= true];
        Date dayReceived = timeInputs[0].timeRecieved.date();
        Date dayResponded;
        integer daysBetweenResponce;
        integer nonWorkingDaysBetweenResponce;
        integer workingDaysBetweenResponce;
        
        //Set the date of reply based on when business hours. If within business hours then return the date of the reply. else return the next working date
        if(BusinessHours.isWithin(bh.Id, timeInputs[0].timeResponded)){
            dayResponded = timeInputs[0].timeResponded.date();
        }else{
            dayResponded = BusinessHours.nextStartDate(bh.id, timeInputs[0].timeResponded).date();
        }
        
        //Calculate relative response dates relative to business hours and public holidays
        daysBetweenResponce = dayReceived.daysBetween(dayResponded);
        nonWorkingDaysBetweenResponce = DateUtilities.nonWorkingDaysBetween(dayReceived, dayResponded);
        workingDaysBetweenResponce = daysBetweenResponce - nonWorkingDaysBetweenResponce;
        
        //Check to see if the SLA was achieved and return result
        System.debug('Check SLA achieved');
        if(workingDaysBetweenResponce <= COMMUNITY_SLA_LIMIT){
            returnValue.add(true);
            return returnValue;
        }else{
            returnValue.add(false);
            return returnValue;
        }
    }
    
    /*******************************************************************
    @description wrapper class to hold parameters from the flow
    @author Lynn Mejos
    @date 28/03/2023
    ********************************************************************/
    public class Requests {
        @InvocableVariable(label='Time Received' description='Time the Email is received' required=true)
        public DateTime timeRecieved;
        @InvocableVariable(label='Time Responded' description='Time the Email is responded' required=true)
        public DateTime timeResponded;
    }
}