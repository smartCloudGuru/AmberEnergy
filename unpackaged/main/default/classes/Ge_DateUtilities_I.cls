/**********************************************************************
Name:  Ge_TenderRecreateTenderProductsOnChange
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
   1.0      Lynn Mejos          27/03/2023     
***********************************************************************/
public class Ge_DateUtilities_I {
    
    /*******************************************************************
    @description Method to create new Tender Products from existing Supply Contract
    @param List<Requests> request - list of request variables
    @return List<Results> – list of new tender products to create
    @author Lynn Mejos
    @date 13/03/2023
    ********************************************************************/
    @InvocableMethod(label='Get Next Action Date' description='Returns the next working day' category='Case')
    public static List<Date> getNextActionDate(List<Date> proposedDate) {
    	integer nonWorkingDaysBetween = DateUtilities.nonWorkingDaysBetween(system.today(), proposedDate[0]);         
		proposedDate[0] = proposedDate[0] + nonWorkingDaysBetween;
    	//if we land on a non working day then push date along until we are working
        while(nonWorkingDaysBetween > 2){
            nonWorkingDaysBetween = DateUtilities.nonWorkingDaysBetween(proposedDate[0] - nonWorkingDaysBetween, proposedDate[0]);    
            proposedDate[0] = proposedDate[0] + nonWorkingDaysBetween;
        }
 		while(DateUtilities.dayIsNonWorking(proposedDate[0]) ){
 			proposedDate[0] = proposedDate[0].addDays(1);
 		}
	    return proposedDate;
    }
}