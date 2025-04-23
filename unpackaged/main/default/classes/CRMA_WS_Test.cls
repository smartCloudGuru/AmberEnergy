@isTest
global class CRMA_WS_Test {

    // global HttpRequest request {
    //     return this.request;
    // }

    // Mock HTTP response class
    global class MockHttpResponse implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token":"mock_access_token"}');
            res.setStatusCode(200);
            return res;
        }
    }


    global class RecipesMockHttpResponse implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token":"mock_token","nextPageUrl": "/services/data/v58.0/wave/recipes?page=eyJwYWdlU2l6ZSI6MjUsInNvcnRPcmRlciI6Ik1SVSIsImxhc3RJZCI6IjA1djZNMDAwMDAwb0xtNlFBRSIsImxhc3ROYW1lIjoiTSZUIFJlcG9ydCJ9", "recipes": [{"conversionDetails": [], "createdBy": {"id": "0056M000009ilnKQAQ", "name": "Russell Cross", "profilePhotoUrl": "/img/userprofile/default_profile_45_v2.png" }, "createdDate": "2023-06-26T08:06:20.000Z", "fileUrl": "/services/data/v58.0/wave/recipes/05v6M000000oLlmQAE/file", "format": "R3", "historiesUrl": "/services/data/v58.0/wave/recipes/05v6M000000oLlmQAE/histories", "id": "05v6M000000oLlmQAE", "label": "Alert_Case_account", "lastModifiedBy": {"id": "0056M00000AQCx8QAH", "name": "Thomas Wake", "profilePhotoUrl": "/img/userprofile/default_profile_45_v2.png" }, "lastModifiedDate": "2023-06-26T15:08:43.000Z", "licenseAttributes": {"type": "einsteinanalytics" }, "name": "mock_recipe", "publishingTarget": "Dataset", "scheduleAttributes": {"assetId": "05v6M000000oLlmQAE", "frequency": "none" }, "status": "Success", "targetDataflowId": "02K6M000000ogfzUAA", "type": "recipe", "url": "/services/data/v58.0/wave/recipes/05v6M000000oLlmQAE?format=R3", "validationDetails": [] } ], "totalSize": 33, "url": "/services/data/v58.0/wave/recipes"    }');
            res.setStatusCode(200);
            return res;
        }
    }

    global class DataFlowMockHttpResposne implements HttpCalloutMock {
        global HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"access_token":"mock_token", "progress" : 0.02, "status" : "Running" , "dataflowJobs" : [{"jobId":"123","progress" : 0.02,"startDate" : "2023-06-27T10:59:35.000Z"}] ,"dataflows": [{"createdBy": {"id": "0056M00000AQCx8QAH", "name": "Thomas Wake", "profilePhotoUrl": "/img/userprofile/default_profile_45_v2.png" }, "createdDate": "2023-06-27T10:59:35.000Z", "description": "Dataflow for the Analytics Adoption App", "emailNotificationLevel": "warnings", "historiesUrl": "/services/data/v58.0/wave/dataflows/02K6M000000ohKsUAI/histories", "id": "02K6M000000ohKsUAI","jobId" : "02K6M000000ohKsUAI" , "label": "CRMA Insights Dataflow", "lastModifiedBy": {"id": "0056M00000AQCx8QAH", "name": "Thomas Wake", "profilePhotoUrl": "/img/userprofile/default_profile_45_v2.png" }, "lastModifiedDate": "2023-12-11T07:00:12.000Z", "name": "CRMA_Insights_AnalyticsAdoptionAppDataflow", "type": "dataflow", "url": "/services/data/v58.0/wave/dataflows/02K6M000000ohKsUAI" } ]}');
            return res;
        }
    }
    
    global class DataConnectorMockHttpResposne implements HttpCalloutMock {
        global HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"access_token":"mock_token", "progress" : 0.02, "status" : "Running" , "dataConnectors" : [{"jobId":"123","progress" : 0.02,"startDate" : "2023-06-27T10:59:35.000Z"}] ,"dataflows": [{"createdBy": {"id": "0056M00000AQCx8QAH", "name": "Thomas Wake", "profilePhotoUrl": "/img/userprofile/default_profile_45_v2.png" }, "createdDate": "2023-06-27T10:59:35.000Z", "description": "Dataflow for the Analytics Adoption App", "emailNotificationLevel": "warnings", "historiesUrl": "/services/data/v58.0/wave/dataflows/02K6M000000ohKsUAI/histories", "id": "02K6M000000ohKsUAI","jobId" : "02K6M000000ohKsUAI" , "label": "CRMA Insights Dataflow", "lastModifiedBy": {"id": "0056M00000AQCx8QAH", "name": "Thomas Wake", "profilePhotoUrl": "/img/userprofile/default_profile_45_v2.png" }, "lastModifiedDate": "2023-12-11T07:00:12.000Z", "name": "CRMA_Insights_AnalyticsAdoptionAppDataflow", "type": "dataflow", "url": "/services/data/v58.0/wave/dataflows/02K6M000000ohKsUAI" } ]}');
            return res;
        }
    }
    
    @testSetup static void setup(){
          CRM_CRMRecipeRun__c newRun = new CRM_CRMRecipeRun__c();
        newRun.CRM_Status__c = 'Waiting';
        newRun.CRM_RecipeID__c = '123';
        insert newRun;
        
          CRM_CRMRecipeRun__c newRun2 = new CRM_CRMRecipeRun__c();
        newRun2.CRM_Status__c = 'Waiting';
        newRun2.CRM_RecipeID__c = '123';
        insert newRun2;
    }

    @isTest static void testGetAuthToken() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        CRMA_WS crma = new CRMA_WS();
         Test.startTest();
        String authToken = crma.getAuthToken();
		Test.StopTest();
        System.assertEquals('mock_access_token', authToken);
    }

    @isTest static void testBuildAuthRequest() {
        CRMA_WS crma = new CRMA_WS();
         Test.startTest();
        HttpRequest request = crma.buildAuthRequest();

        System.assertEquals('POST', request.getMethod());
        System.assertEquals('application/x-www-form-urlencoded', request.getHeader('Content-Type'));
        System.assertEquals('application/json', request.getHeader('Accept'));
        TEst.stopTest();
    }

    @isTest static void testSetGenericHeaders() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
 Test.startTest();
        CRMA_WS crma = new CRMA_WS();
        crma.buildRequestHeaders();
        crma.setGenericHeaders();

        HttpRequest request = crma.request; 

        System.assertEquals('application/json', request.getHeader('Content-Type'));
        System.assertEquals('application/json', request.getHeader('Accept'));
        System.assertEquals('Bearer mock_access_token', request.getHeader('authorization'));
        Test.stopTest();
    }

    @isTest static void testBuildRequestHeaders() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
 Test.startTest();
        CRMA_WS crma = new CRMA_WS();
        crma.buildRequestHeaders();

        HttpRequest request = crma.request; // You need to implement this getter in your CRMA_WS class

        System.assertEquals('callout:Wave_API/data/v58.0/wave', request.getEndpoint());
        TEst.stopTest();
    }
    
    @isTest static void testBuildConnectors() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
 Test.startTest();
        CRMA_WS crma = new CRMA_WS();
        crma.buildRequestHeaders();
        crma.buildGetDataConnectorsRequest();

        HttpRequest request = crma.request; // You need to implement this getter in your CRMA_WS class

        //System.assertEquals('callout:Wave_API/data/v58.0/wave', request.getEndpoint());
        TEst.stopTest();
    }


    @isTest static void testBuildGetRecipesRequest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
		 Test.startTest();
        CRMA_WS crma = new CRMA_WS();
        crma.buildGetRecipesRequest();

        HttpRequest request = crma.request; // You need to implement this getter in your CRMA_WS class

        System.assertEquals('GET', request.getMethod());
        Test.StopTest();
    }

    @isTest static void testGetRecipes() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
    	 Test.startTest();
        CRMA_WS crma = new CRMA_WS();
        HttpResponse response = crma.getRecipes();
    
        System.assertEquals(200, response.getStatusCode());
        Test.StopTest();
    }
    
    @isTest static void testGetConnectors() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
    	 Test.startTest();
        CRMA_WS crma = new CRMA_WS();
        HttpResponse response = crma.getDataConnectors();
    
        System.assertEquals(200, response.getStatusCode());
        Test.StopTest();
    }
    
    @isTest static void testGetDataFlows() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
    	 Test.startTest();
        CRMA_WS crma = new CRMA_WS();
        HttpResponse response = crma.getDataFlows();
    
        System.assertEquals(200, response.getStatusCode());
        Test.StopTest();
    }
    
    @isTest static void testRunDataflowJob() {
        Test.setMock(HttpCalloutMock.class, new DataFlowMockHttpResposne());
        CRMA_WS.dataflowrequest dataFlowRequest = new CRMA_WS.dataflowrequest();
        dataFlowRequest.dataFlowType = 'Recipe';
        dataFlowRequest.dataFlowName = 'mock_recipe';
        dataFlowRequest.dataFlowId = '05v6M000000oLlmQAE';
        CRMA_WS crma = new CRMA_WS();
        List<CRMA_WS.dataflowrequest> dataFlowRequests = new List<CRMA_WS.dataflowrequest>();
        dataFlowRequests.add(dataFlowRequest);
         Test.startTest();
        CRMA_WS.runDataflowJob(dataFlowRequests);
    	Test.stopTest();
    }
    
    @isTest static void testGetResponseBody() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
    
        CRMA_WS crma = new CRMA_WS();
         Test.startTest();
        HttpResponse response = crma.getRecipes();
        Map<String, Object> responseBody = crma.getResponseBody(response);
    
        System.assertEquals('mock_access_token', responseBody.get('access_token'));
        Test.stopTest();
    }
    
    @isTest static void testFindMatchingId() {
         Test.startTest();
        CRMA_WS crma = new CRMA_WS();
        List<Object> records = new List<Object>{
            new Map<String, Object>{'id' => '1', 'name' => 'Record 1'},
            new Map<String, Object>{'id' => '2', 'name' => 'Record 2'},
            new Map<String, Object>{'id' => '3', 'name' => 'Record 3'}
        };
    
        String id = crma.findMatchingId('Record 2', records);
    
        System.assertEquals('2', id);
        Test.stopTest();
    }
    
    @isTest static void testGetDataFlowId() {
        Test.setMock(HttpCalloutMock.class, new RecipesMockHttpResponse());
    	 Test.startTest();
        CRMA_WS crma = new CRMA_WS();
        CRMA_WS.dataflowrequest dataFlowRequest = new CRMA_WS.dataflowrequest();
        dataFlowRequest.dataFlowType = 'Recipe';
        dataFlowRequest.dataFlowName = 'mock_recipe';
    
        String id = crma.getDataFlowId(dataFlowRequest);
    
        System.assertEquals('05v6M000000oLlmQAE', id);
        Test.stopTest();
    }
    
    @isTest static void testGetDataFlowIdConnector() {
        Test.setMock(HttpCalloutMock.class, new DataConnectorMockHttpResposne());
    	 Test.startTest();
        CRMA_WS crma = new CRMA_WS();
        CRMA_WS.dataflowrequest dataFlowRequest = new CRMA_WS.dataflowrequest();
        dataFlowRequest.dataFlowType = 'DataConnector';
        dataFlowRequest.dataFlowName = 'mock_recipe';
    
        crma.getDataFlowId(dataFlowRequest);
    
        //System.assertEquals('05v6M000000oLlmQAE', id);
        Test.stopTest();
    }

    @isTest static void testGetDataFlowIdDataFlow() {
        Test.setMock(HttpCalloutMock.class, new DataFlowMockHttpResposne());
    	 Test.startTest();
        CRMA_WS crma = new CRMA_WS();
        crma.authToken = 'mock_token';

        CRMA_WS.dataflowrequest dataFlowRequest = new CRMA_WS.dataflowrequest();
        dataFlowRequest.dataFlowType = 'dataflow';
        dataFlowRequest.dataFlowName = 'CRMA_Insights_AnalyticsAdoptionAppDataflow';
    
        String id = crma.getDataFlowId(dataFlowRequest);
    
        System.assertEquals('02K6M000000ohKsUAI', id);
        Test.stopTest();
    }

    
    @isTest static void testGetRecipesAura() {
        Test.setMock(HttpCalloutMock.class, new CRMA_WS_Test.RecipesMockHttpResponse());
    	 Test.startTest();
        CRMA_WS crma = new CRMA_WS();
        String response = CRMA_WS.getRecipesAura();
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
    
        System.assertEquals('mock_token', responseBody.get('access_token'));
        System.assertNotEquals(null, responseBody.get('recipes'));
        Test.stopTest();
    }
    
    @isTest static void testGetDataFlowsAura() {
        Test.setMock(HttpCalloutMock.class, new CRMA_WS_Test.DataFlowMockHttpResposne());
         Test.startTest();
        CRMA_WS crma = new CRMA_WS();
        crma.authToken = 'mock_token';
        String response = CRMA_WS.getDataFlowsAura();
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response);
    
        System.assertEquals('mock_token', responseBody.get('access_token'));
        System.assertNotEquals(null, responseBody.get('dataflows'));
        test.stopTest();
    }
    
    @isTest static void testPollgetJobId() {
        Test.setMock(HttpCalloutMock.class, new DataFlowMockHttpResposne());
        Map<String,Object> buildResponse = new Map<String,Object>();
        buildResponse.put('id','123');
        Map<String,Object> responseBody = (Map<String,Object>) buildResponse;
        Test.startTest();
        CRMA_RequestPoll.getJobId(responseBody);
        Test.stopTest();
    }
    
    @isTest static void testPollKickOffOtherJobs() {
        Test.setMock(HttpCalloutMock.class, new DataFlowMockHttpResposne());
     
        Test.startTest();
        CRMA_RequestPoll.kickOffOtherJobs('001Pw000005TUBeIAO', '123', new List<CRM_CRMRecipeRun__c>());
        Test.stopTest();
    }

    @isTest static void testPollRequest() {
        // Setup
        Test.setMock(HttpCalloutMock.class, new DataFlowMockHttpResposne());
        List<CRMA_RequestPoll.pollRequest> requests = new List<CRMA_RequestPoll.pollRequest>();
        CRMA_RequestPoll.pollRequest request = new CRMA_RequestPoll.pollRequest();
        request.recordId = 'a4bPw000000CFcnIAG';
        request.jobId = '123';
        request.recipeId = '456';
        request.currentStatus = 'Created';
        requests.add(request);
    
        // Execute
        Test.startTest();
        CRMA_RequestPoll.pollRequest(requests);
        Test.stopTest();
    
       
    }
    
     @isTest static void testPollRequestQueued() {
        // Setup
        Test.setMock(HttpCalloutMock.class, new DataFlowMockHttpResposne());
        List<CRMA_RequestPoll.pollRequest> requests = new List<CRMA_RequestPoll.pollRequest>();
        CRMA_RequestPoll.pollRequest request = new CRMA_RequestPoll.pollRequest();
        request.recordId = 'a4bPw000000CFcnIAG';
        request.jobId = '02K6M000000ohKsUAI';
        request.recipeId = '456';
        request.currentStatus = 'Queued';
        requests.add(request);
    
        // Execute
        Test.startTest();
        CRMA_RequestPoll.pollRequest(requests);
        Test.stopTest();
    
       
    }
    
     @isTest static void testPollRequestPreprocessing() {
        // Setup
        Test.setMock(HttpCalloutMock.class, new DataFlowMockHttpResposne());
        List<CRMA_RequestPoll.pollRequest> requests = new List<CRMA_RequestPoll.pollRequest>();
        CRMA_RequestPoll.pollRequest request = new CRMA_RequestPoll.pollRequest();
        request.recordId = 'a4bPw000000CFcnIAG';
        request.jobId = '02K6M000000ohKsUAI';
        request.recipeId = '456';
        request.currentStatus = 'Preprocessing';
        requests.add(request);
    
        // Execute
        Test.startTest();
        CRMA_RequestPoll.pollRequest(requests);
        Test.stopTest();
    
       
    }
    
    @isTest static void testgetNotCompleteRecipeRuns() {
        CRMA_RecipeRun_DAO.getNotCompleteRecipeRuns();
    }

    // @InvocableMethod(label='Poll Request')
    // global static void pollRequest(List<pollRequest> requests) {
        
    //     try {
    //         List<CRM_CRMRecipeRun__c> toUpdate = new List<CRM_CRMRecipeRun__c>();

    //     CRMA_Ws ws = new CRMA_Ws();
    //     CRMA_Ws.getDataFlowJobsResponse resp = ws.getAndCastDataFlowJobsResponse();
    //     List<CRMA_Ws.getDataFlowJobResponse> dataFlows = resp.dataFlowJobs;
    //     boolean justChanged = false;
    //     for (pollRequest request : requests) {
    //         string currentStatus = request.currentStatus;
    //         if (currentStatus == 'Created' || currentStatus == 'Waiting') {
    //            List<CRM_CRMRecipeRun__c> possibleRuns = CRMA_RecipeRun_DAO.getRecipeRunsByRecipeId(request.recipeId);
    //            List<string> jobIds = new List<string>();
    //             for (CRM_CRMRecipeRun__c run : possibleRuns) {
    //                  jobIds.add(run.CRM_JobId__c);
    //             }

    //             boolean allJobsComplete = true;

    //             for (CRMA_Ws.getDataFlowJobResponse dataFlow : dataFlows) {
    //                 if (jobIds.contains(dataFlow.jobId)) {
    //                     if (dataFlow.status != 'Completed' && dataFlow.status != 'Failure' && dataFlow.status != 'Cancelled' && dataFlow.status != 'Success') {
    //                         allJobsComplete = false;
    //                     }
    //                 }
    //             }


    //             if (allJobsComplete)  {

    //                 httpResponse SendResponse = ws.runDataflowJob(request.recipeId);
    //                 system.debug('here!');
    //                 System.debug(SendResponse.getBody());
    //                 Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(SendResponse.getBody());
    //                 string jobId = getJobId(responseMap);
    //                 CRM_CRMRecipeRun__c run = new CRM_CRMRecipeRun__c();
    //                 run.Id = request.recordId;
    //                 run.CRM_JobId__c = jobId;
    //                 run.CRM_Status__c = 'Running';
    //                 justChanged = true;
    //                 run.CRM_NextCheckTime__c = System.now().addMinutes(CRMA_RequestPoll.pollInterval);
    //                 toUpdate.add(run);
    //             } else {
    //                 CRM_CRMRecipeRun__c run = new CRM_CRMRecipeRun__c();
    //                 run.Id = request.recordId;

    //                 DateTime nextCheck = run.CRM_NextCheckTime__c == null ? System.now() : run.CRM_NextCheckTime__c;

    //                 run.CRM_NextCheckTime__c = nextCheck.addMinutes(CRMA_RequestPoll.pollInterval);
    //             }

    //         } else if (currentStatus == 'Queued' && !justChanged) {
    //             for (CRMA_Ws.getDataFlowJobResponse dataFlow : dataFlows) {
    //                 if (dataFlow.jobId == request.jobId) {
    //                     CRM_CRMRecipeRun__c run = new CRM_CRMRecipeRun__c();
    //                     run.Id = request.recordId;
    //                     run.CRM_Status__c = dataFlow.status;
    //                     if (dataFlow.status == 'Completed' || dataFlow.status == 'Failure' || dataFlow.status == 'Cancelled' || dataFlow.status == 'Success') {
    //                         run.CRM_NextCheckTime__c = null;
    //                         run.CRM_EndTime__c = dataFlow.endDate;
    //                         toUpdate = kickOffOtherJobs(request.recordId, request.recipeId, toUpdate);
    //                     } else {
    //                         run.CRM_NextCheckTime__c = System.now().addMinutes(CRMA_RequestPoll.pollInterval);
    //                     }

    //                     run.CRM_StartTime__c = dataFlow.startDate;
    //                     run.CRM_WaitTime__c = dataFlow.waitTime;
    //                     run.CRM_RetryCount__c = dataFlow.retryCount;
    //                     run.CRM_Duration__c = dataFlow.duration;

    //                     run.CRM_Duration__c = dataFlow.duration;
    //                     run.CRM_Message__c = dataFlow.message;
    //                     run.CRM_RetryCount__c = dataFlow.retryCount;
    //                     run.CRM_WaitTime__c = dataFlow.waitTime;
    //                     run.CRM_Progress__c = dataFlow.progress * 100;
    //                     run.CRM_StartTime__c = dataFlow.startDate;
    //                     // run.CRM_EndTime__c = dataFlow.endDate;

    //                     toUpdate.add(run);

    //                 }
    //             }
    //         } else if (currentStatus == 'Preprocessing' || currentStatus == 'Running') {
    //             for (CRMA_Ws.getDataFlowJobResponse dataFlow : dataFlows) {
    //                 if (dataFlow.jobId == request.jobId) {
    //                     CRM_CRMRecipeRun__c run = new CRM_CRMRecipeRun__c();
    //                     run.Id = request.recordId;
    //                     run.CRM_Status__c = dataFlow.status;
    //                     run.CRM_Progress__c = dataFlow.progress * 100;
    //                     run.CRM_StartTime__c = dataFlow.startDate;
    //                     run.CRM_WaitTime__c = dataFlow.waitTime;
    //                     run.CRM_RetryCount__c = dataFlow.retryCount;
    //                     run.CRM_Duration__c = dataFlow.duration;
    //                     if (dataFlow.status == 'Completed' || dataFlow.status == 'Failure' || dataFlow.status == 'Cancelled' || dataFlow.status == 'Success') {
    //                         run.CRM_NextCheckTime__c = null;
    //                         run.CRM_EndTime__c = dataFlow.endDate;

    //                         toUpdate = kickOffOtherJobs(request.recordId, request.recipeId, toUpdate);

    //                     } else {
    //                         run.CRM_NextCheckTime__c = System.now().addMinutes(CRMA_RequestPoll.pollInterval);
    //                     }

    //                     // run.CRM_NextCheckTime__c = System.now().addMinutes(CRMA_RequestPoll.pollInterval);
    //                     toUpdate.add(run);
    //                 }
    //             }
    //         }
    //    }

    //    update toUpdate;
    //     } catch (Exception e) {
    //         System.debug(e);

    //     //    createExceptionNote(e);


    //     }

    // }

    // global class pollRequest {
    //     @InvocableVariable
    //     global string recordId;
    //     @InvocableVariable
    //     global string jobId;
    //     @InvocableVariable
    //     global string recipeId;
    //     @InvocableVariable
    //     global string currentStatus;
    // }
}