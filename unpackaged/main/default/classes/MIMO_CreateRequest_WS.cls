/**********************************************************************
Name:  MIMO_CreateRequest_WS
Copyright © 2022
======================================================
======================================================
Purpose:  Used to expose a Web Service to allow the Creation of MIMO 
          (Move In Move Out) requests into the system.
          This class exposes a Web Servcice to allow the Amber Ref
          to be returned to the calling system.

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0      Mark Cook         19/04/2022
***********************************************************************/
@RestResource(urlMapping='/mimo1/v2/*')

global without sharing class MIMO_CreateRequest_WS {

    /*******************************************************************
    * @description exposes a Web Service to create a list of Mimo requests and return the Amber Ref
	* @returns String - JSON version of the Response
    * @Throws [Exceptions]: None                                                
    ********************************************************************/ 
	@HttpPost
    global static String createMIMORequest (List<mimoServiceRequest__c> newMIMORequests) {
    	Set<Id> successfullyCreatedRecords = new Set<Id>();
    	List<MIMOResponse> responses = new List<MIMOResponse>();

    	//Attempt to insert the records that have been passed into the appliction
		Database.SaveResult[] insertResults = Database.insert(newMIMORequests, false);

		//Loop through the results
		for(Integer i=0;i<insertResults.size();i++){

			//if success add to a list to query later, else create a response and add to response list
			if (insertResults.get(i).isSuccess()){
		
				successfullyCreatedRecords.add(insertResults.get(i).getId());

			} else if (!insertResults.get(i).isSuccess()){
				// DML operation failed
				Database.Error error = insertResults.get(i).getErrors().get(0);
				String failedDML = error.getMessage();
				newMIMORequests.get(i);//failed record from the list

				responses.add(new MIMOResponse(failedDML
												, newMIMORequests.get(i).MIMIO_AmberReference__c
												, newMIMORequests.get(i).MIMO_ExternalReference__c
												)
				);
			}
		}

		//Query the success records
		for(mimoServiceRequest__c aSuccess : [Select MIMIO_AmberReference__c
													, MIMO_ExternalReference__c 
													, MIMO_Guid__c
											  FROM mimoServiceRequest__c 
											  WHERE ID IN :successfullyCreatedRecords ]){
			responses.add(new MIMOResponse(aSuccess));
		}

		//create a JSON version of the response
    	return JSON.serialize(responses, true);
    }



    /*******************************************************************
    * @description A response class used to encapsulate the respoinses                                             
    ********************************************************************/ 
    public class MIMOResponse{
    	public boolean success;
    	public String error;
    	public String amberReference;
    	public String externalReference;
    	public String GUID;


		/*******************************************************************
		* @description Constructor for a failed creation
		* @param String theError- The Error message to return to the user
		* @param String theAmberRef - The Amber Reference that should be returned to the user
		* @param String theExternalRef - The external reference used by the calling system
		* @Throws [Exceptions]: None                                                
		********************************************************************/ 
    	public MIMOResponse(String theError, String theAmberRef, String theExternalRef){
    		this.success = FALSE;
    		this.amberReference = theAmberRef;
    		this.error = theError;
    		this.externalReference = theExternalRef;
    	}

		/*******************************************************************
		* @description Constructor for a successful creation
		* @param MimoServiceRequest__c - newly created record
		* @Throws [Exceptions]: None                                                
		********************************************************************/ 
    	public MIMOResponse(MimoServiceRequest__c aRecord){
    		this.success = TRUE;
    		this.amberReference = aRecord.MIMIO_AmberReference__c;
    		this.externalReference = aRecord.MIMO_ExternalReference__c;
    		this.GUID = aRecord.MIMO_Guid__c;
    	}
    }
}