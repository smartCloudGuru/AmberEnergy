/**********************************************************************
Name:  MIMO_CreateRequest_WS_Test
Copyright © 2022
======================================================
======================================================
Purpose:  Used to test the exposed web service that creates MIMO Requests

As part of this work we were only undertaking 1 class change. We would
normally recommend a centralised test data creation and a framework for 
all test classes

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0      Mark Cook         19/04/2022
***********************************************************************/
@isTest
public with sharing class MIMO_CreateRequest_WS_Test {

	//Variables used by teseing classes
    private static List<mimoServiceRequest__c> newServiceRequests;
    private static Property__c p;
    private static Final String PROPERTY_REF = 'FLAT101';
    private static User testUser;

    /*******************************************************************
    * @description Sets up the test data, in this example this includes : 
                   Building
                   Property
                   Account
                   MIMO Token
                   MIMO Requests   
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    public static void testDataSetup(){

    	//Create the test user
        Profile profile = [SELECT Id FROM Profile WHERE Name='MiMo Integration Profile Platform User']; 
        testUser = new User(Alias = 'standt'
        					, Email='standarduserTesting@amber.org'
        					, EmailEncodingKey='UTF-8'
        					, LastName='Testing'
        					, LanguageLocaleKey='en_US'
        					, LocaleSidKey='en_US'
        					, ProfileId = profile.Id
        					, TimeZoneSidKey='America/Los_Angeles'
        					, UserName='standarduserTesting@amber.org');
        insert testUser;


        //
    	newServiceRequests = new List<mimoServiceRequest__c>();
        Building__c b = new Building__c(name='TestBuilding');
        insert b;
        
        p = new Property__c(building__c=b.Id,name='TestProperty',client_reference__c=PROPERTY_REF, reference__c=PROPERTY_REF);
        insert p;
        
        Account testAccount = TestData.createClientAccount();
        insert testAccount;       
        insert new MIMO_API_Token__c(User__c=testUser.id, token__c='abcdefghij0123456789',active__c=true,account__c=testAccount.Id,Meters_and_Status_Checked__c=true,
                                        Client_Property_Ids_Mapped__c=true,Staging_Data_Updated__c=true,validate_meter_reads__c=true);

        newServiceRequests.add(createMIMORecords('PPL1'));
        newServiceRequests.add(createMIMORecords('PPL2'));
        newServiceRequests.add(createMIMORecords('PPL3'));
    }


	/*******************************************************************
	* @description Constructor for a failed creation
	* @param String lastName - Last name to use on new Request
	* @returns MimoServiceRequest__c newly created request
	* @Throws [Exceptions]: None                                                
	********************************************************************/ 
    public static MimoServiceRequest__c createMIMORecords(String lastName){
		return new MimoServiceRequest__c(MIMO_FirstName__c = 'TestPerson' 
										, MIMO_LastName__c = 'TestPerson' 
										, MIMO_StartDate__c = Date.Today()
										, MIMO_Email__c = 'TMcTest@test.com'
										, MIMO_MoveInGasReading__c = 432423.324
										, MIMO_MoveInGasReadingDate__c = Date.Today()
										, MIMO_ExternalReference__c = lastName
										, Service__c = 'Move In'
										, MIMO_Property__c = p.Id
										);
     	 
     }

	/*******************************************************************
	* @description tests the exposed API by creating Move In Requests
	* @Throws [Exceptions]: None                                                
	********************************************************************/
	@isTest static void createRecordsSuccess() {
		//create Test Data
		testDataSetup();

		//Execute Test
		Test.startTest();
			System.runAs(testUser) {

				String resultString = MIMO_CreateRequest_WS.createMIMORequest(newServiceRequests);
				//deserialse the response
				List<MIMO_CreateRequest_WS.MIMOResponse> responses = new List<MIMO_CreateRequest_WS.MIMOResponse>();
				responses = (List<MIMO_CreateRequest_WS.MIMOResponse>)JSON.deserialize(resultString, List<MIMO_CreateRequest_WS.MIMOResponse>.class);


				//assert the test classes
				//has correct number of records
				System.assertEquals(3, responses.size());

				//has populated the relevant fields
				for(MIMO_CreateRequest_WS.MIMOResponse aResponse : responses){
					System.assert(aResponse.success);
					//System.assert(aResponse.amberReference.contains(PROPERTY_REF));
				}
			}

		Test.stopTest();


	}

	/*******************************************************************
	* @description tests the exposed API by creating Move In Requests
	* @Throws [Exceptions]: None                                                
	********************************************************************/
	@isTest static void createRecordsMixed() {

		//create Test Data
		testDataSetup();
		newServiceRequests.add(new MimoServiceRequest__c(
										  MIMO_StartDate__c = Date.Today()
										, MIMO_Email__c = 'TMcTest@test.com'
										, MIMO_ExternalReference__c = 'FailedTest'
										, Service__c = 'Move In'
										, MIMO_Property__c = p.Id
										)
		);


		//Execute Test
		Test.startTest();
		 	System.runAs(testUser) {
		 		String resultString = MIMO_CreateRequest_WS.createMIMORequest(newServiceRequests);



				//deserialse the response
				List<MIMO_CreateRequest_WS.MIMOResponse> responses = new List<MIMO_CreateRequest_WS.MIMOResponse>();
				responses = (List<MIMO_CreateRequest_WS.MIMOResponse>)JSON.deserialize(resultString, List<MIMO_CreateRequest_WS.MIMOResponse>.class);

System.debug(resultString);
				//assert the test classes
				//has correct number of records
				System.assertEquals(4, responses.size());

				//has populated the relevant fields
				for(MIMO_CreateRequest_WS.MIMOResponse aResponse : responses){
					if(!aResponse.success){
						System.assertEquals('FailedTest', aResponse.externalReference);
					}
				}
		 	}
		Test.stopTest();
	}
}