global with sharing class CRMA_WS {


public Static Final String QUEUED_STATUS = 'Queued';
global static integer pollInterval = Integer.valueof(System.Label.CRMA_PollTime);


private string baseurl = 'callout:Wave_API';
    private string waveURI = '/data/v58.0/wave';
    private string authURI = '/oauth2/token';
    private string authUrl = baseurl + authURI;
    @testVisible
    private HttpRequest request;
    private string uri = '';
    private HttpResponse response;
    private string clientId = '{!$Credential.SF_CRMA.clientId}';
    private string clientSecret = '{!$Credential.SF_CRMA.clientSecret}';
    @testVisible
    private string authToken;

    global string getAuthToken(){
       
        //peform client id and secret only auth
        HttpRequest request = buildAuthRequest();
        response = new Http().send(request);

        Map<String,Object> authResponse = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
        this.authToken = (string) authResponse.get('access_token');
        return this.authToken;
    }

    global httpRequest buildAuthRequest(){
        HttpRequest request = new HttpRequest();
        request.setEndpoint(authUrl);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('Accept', 'application/json');
        request.setBody('grant_type=client_credentials&client_id=' + clientId + '&client_secret=' + clientSecret);
        return request;
    }

    global void buildDataConnectorIngestRequest(String connectorId) {
        uri = '/dataConnectors/' + connectorId + '/ingest';
        buildRequestHeaders();
        request.setMethod('POST');
        // Empty body is required
        request.setBody('{}');
    }

    global httpResponse runDataConnectorSync(String connectorId) {
        buildDataConnectorIngestRequest(connectorId);
        response = new Http().send(request);
        return response;
    }

    global void setGenericHeaders(){
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        if (this.authToken != null) {
            request.setHeader('authorization', 'Bearer ' + this.authToken);

        } else {
            request.setHeader('authorization', 'Bearer ' + getAuthToken());

        }

    }   

    global void buildRequestHeaders(){
        request = new HttpRequest();
        request.setEndpoint(baseURL + waveURI +  uri);
        setGenericHeaders();

    }

    global void buildGetRecipesRequest(){
        uri = '/recipes';
        buildRequestHeaders();
        request.setMethod('GET');
    }

    global void buildGetDataFlowJobsRequest(){
        uri = '/dataflowjobs';
        buildRequestHeaders();
        request.setMethod('GET');
    }

    global httpResponse getRecipes(){
        buildGetRecipesRequest();
        response = new Http().send(request);
        return response;
    }

    global httpResponse getDataFlowJobs() {
        buildGetDataFlowJobsRequest();
        response = new Http().send(request);
        return response;
    }

    global getDataFlowJobsResponse getAndCastDataFlowJobsResponse() {
        HttpResponse response = getDataFlowJobs();
        return new getDataFlowJobsResponse(response);
    }

    global void buildGetDataFlowsRequest(){
        uri = '/dataflows';
        buildRequestHeaders();
        request.setMethod('GET');
    }

    global httpResponse getDataFlows(){
        buildGetDataFlowsRequest();
        response = new Http().send(request);
        return response;
    }

    global httpResponse getDataFlow(String id) {
        buildGetDataFlowJobsRequest();
        uri+= '/' + id;
        response = new Http().send(request);
        return response;
    }

    // Add after existing getDataFlows methods
    global void buildGetDataConnectorsRequest() {
        uri = '/dataConnectors';
        buildRequestHeaders();
        request.setMethod('GET');
    }

    global httpResponse getDataConnectors() {
        buildGetDataConnectorsRequest();
        response = new Http().send(request);
        return response;
    }

    global httpResponse getDataConnector(String id) {
        buildGetDataConnectorsRequest();
        uri += '/' + id;
        response = new Http().send(request);
        return response;
    }

    // Optional: Add a response wrapper class if needed
    global class DataConnectorResponse {
        public List<Object> dataConnectors { get; set; }
        
        public DataConnectorResponse(HttpResponse response) {
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            this.dataConnectors = (List<Object>)results.get('dataConnectors');
        }
    }

    global Map<String,Object> buildBody(string dataflowId) {
        Map<String,Object> body = new Map<String,Object>();
        body.put('dataflowId', dataflowId);
        body.put('command', 'start');

        return body;
    }

    global httpResponse runDataflowJob(string dataFlowId) {
        uri = '/dataflowjobs';
      
        buildRequestHeaders();
        request.setMethod('POST');
        request.setBody(JSON.serialize(buildBody(dataFlowId)));
        response = new Http().send(request);
        return response;

    }
    @testVisible
    private Map<String,Object> getResponseBody(HttpResponse response) {
        return (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
    }

    global string findMatchingId(String aName, object aList) {
       
       
        List<Object> records = (List<Object>) aList;
        for (Object record : records) {
            Map<String,Object> recordMap = (Map<String,Object>) record;
            if (recordMap.get('name') == aName) {
                return (string) recordMap.get('id');
            }
        }
        return null;
    }


    global String getDataFlowId(dataflowrequest request) {
        String id;
      
        if (request.dataFlowType == 'Recipe') {
            HttpResponse recipesResponse = getRecipes();
            Map<String, Object> recipesBody = getResponseBody(recipesResponse);
            List<Object> recipes = (List<Object>)recipesBody.get('recipes');
            id = findMatchingId(request.dataFlowName, recipes);
        } 
        else if (request.dataFlowType == 'Dataflow') {
            HttpResponse dataflowsResponse = getDataFlows();
            Map<String, Object> dataflowsBody = getResponseBody(dataflowsResponse);
            List<Object> dataflows = (List<Object>)dataflowsBody.get('dataflows');
            id = findMatchingId(request.dataFlowName, dataflows);
        }
        else if (request.dataFlowType == 'DataConnector') {
            HttpResponse dataConnectorsResponse = getDataConnectors();
            Map<String, Object> dataConnectorsBody = getResponseBody(dataConnectorsResponse);
            system.debug('response from dataConnectors');
            system.debug(dataConnectorsBody);
            List<Object> dataConnectors = (List<Object>)dataConnectorsBody.get('dataConnectors');
            id = findMatchingId(request.dataFlowName, dataConnectors);
        }
        
        return id;
    }

    // lwc for config is crma_Invocable_cpe

    @InvocableMethod(callout=true label='Run Dataflow Job'  description='Runs a dataflow job'  configurationEditor='c-crma_Invocable_cpe')
    global static void runDataflowJob(List<dataflowrequest> dataFlowRequests) {
        List<dataflowrequest> newdataFlowRequests = new List<dataflowrequest>();
        CRMA_WS ws = new CRMA_WS();
     
        for (dataflowrequest dataFlowRequest : dataFlowRequests) {
          
            if (dataFlowRequest.dataFlowId == null || dataFlowRequest.dataFlowId == '') {
             
                string dataFlowId = ws.getDataFlowId(dataFlowRequest);
                dataflowRequest newReq = new dataflowRequest();
                newReq.dataFlowId = dataFlowId;
                newReq.dataFlowName = dataFlowRequest.dataFlowName;
                newReq.dataFlowType = dataFlowRequest.dataFlowType;
                newReq.requestingUserId = dataFlowRequest.requestingUserId;
                newdataFlowRequests.add(newReq);
            } else {
             
                newdataFlowRequests.add(dataFlowRequest);
            }
        }

        ws.runQueueDataflowJob(newdataFlowRequests);

    }



    global boolean isRunning(string status) {
        return status == 'Preprocessing' || status == 'Running';
    }

    global boolean isFinished(string status) {
        return status == 'Completed' || status == 'Failure' || status == 'Canceled' || status == 'Success';
    }


    global void runQueueDataflowJob(List<dataflowrequest> reqs) {

   
    //List of jobs we may want to update after this next get
    List<CRM_CRMRecipeRun__c> notCompleteRuns = CRMA_RecipeRun_DAO.getNotCompleteRecipeRuns();
    Map<String, CRM_CRMRecipeRun__c> notCompleteRunsMap = new Map<String, CRM_CRMRecipeRun__c>();
    for (CRM_CRMRecipeRun__c run : notCompleteRuns) {
        notCompleteRunsMap.put(run.CRM_JobID__c, run);
    }

    Map<String, CRM_CRMRecipeRun__c> runsToUpdate = new Map<String, CRM_CRMRecipeRun__c>();
    Map<String, CRM_UserCRMRecipeRequest__c> userRequests = new Map<String, CRM_UserCRMRecipeRequest__c>();

    getDataFlowJobsResponse dataFlowJobs = getAndCastDataFlowJobsResponse();
    Map<String, getDataFlowJobResponse> dataFlowJobsMap = new Map<String, getDataFlowJobResponse>();
    for (getDataFlowJobResponse job : dataFlowJobs.dataFlowJobs) {
        dataFlowJobsMap.put(job.jobId, job);
    }

    boolean currentRecipeIsRunning = false;
    string currentlyRunningRecipeId = '';
 
    Map<String,List<dataflowrequest>> recipeRuns = new Map<String,List<dataflowrequest>>();
    Set<String> userIds = new Set<String>();
    Map<String,String> jobIdToNameMApe = new Map<String,String>();
    for (dataflowrequest aReq : reqs) {
        jobIdToNameMApe.put(aReq.dataFlowId, aReq.dataFlowName);

        if (recipeRuns.containsKey(aReq.dataFlowId)) {
            recipeRuns.get(aReq.dataFlowId).add(aReq);
        } else {
            recipeRuns.put(aReq.dataFlowId, new List<dataflowrequest>{aReq});
        }

        if (aReq.requestingUserId == null || aReq.requestingUserId == '') {
            aReq.requestingUserId = UserInfo.getUserId();
        }

        userIds.add(aReq.requestingUserId);
    }

    for (string dataFlowId : recipeRuns.keySet()) {
        List<dataflowrequest> requests = recipeRuns.get(dataFlowId);
        List<string> jobIds = new List<string>();

        List<CRM_CRMRecipeRun__c> notCompletes = CRMA_RecipeRun_DAO.getNotCompleteRecipeRunsByRecipeId(dataFlowId);
        for (CRM_CRMRecipeRun__c run : notCompletes) {
            jobIds.add(run.CRM_JobID__c);
        }

        for (String jobId : dataFlowJobsMap.keySet()) {
            getDataFlowJobResponse job = dataFlowJobsMap.get(jobId);
            string status = job.status;
            
            if (status == 'Queued' || isRunning(status) && jobIds.contains(job.jobId)) {
                currentRecipeIsRunning = true;
                currentlyRunningRecipeId = job.jobId;
            }  
        }

        if (currentRecipeIsRunning) {
        
            //Find a request to piggy back, otherwise create one
            Boolean foundSuitableRecord = false;
            for (CRM_CRMRecipeRun__c run : notCompleteRuns) {
                //TODO CHECK IF ALREADY HAS REQUEST HERE
                if (run.CRM_RecipeID__c == dataFlowId && run.CRM_JobID__c != currentlyRunningRecipeId) {
                    foundSuitableRecord = true;
                    if (run.User_CRM_Recipe_Request__r != null && run.User_CRM_Recipe_Request__r.size() > 0) {
                        for (CRM_UserCRMRecipeRequest__c userRequest : run.User_CRM_Recipe_Request__r) {
                            if (userIds.contains(userRequest.CRMA_RequestingUser__c)) {
                                userIds.remove(userRequest.CRMA_RequestingUser__c);
                            }
                        }
                    }

                    if (userIds.size() > 0) {
                        for (String usId : userIds) {
                            CRM_UserCRMRecipeRequest__c userRequest = new CRM_UserCRMRecipeRequest__c();
                            userRequest.CRMA_RequestingUser__c = usId;
                            userRequest.CRM_CRMRecipeRun__c = run.Id;
                            userRequests.put(usId, userRequest);
                        }
                    }
                }
            }

            if (!foundSuitableRecord) {
                CRM_CRMRecipeRun__c newRun = new CRM_CRMRecipeRun__c();
                newRun.CRM_Status__c = 'Waiting';
                newRun.CRM_RecipeID__c = dataFlowId;
                newRun.CRM_jobName__c = jobIdToNameMApe.get(dataFlowId);
                newRun.CRM_NextCheckTime__c = DateTime.now().addMinutes(CRMA_WS.pollInterval);
                insert newRun;

                for (String usId : userIds) {
                    CRM_UserCRMRecipeRequest__c userRequest = new CRM_UserCRMRecipeRequest__c();
                    userRequest.CRMA_RequestingUser__c = usId;
                    userRequest.CRM_CRMRecipeRun__c = newRun.Id;
                    userRequests.put(usId, userRequest);
                }
            }
        } else {
                      //Not running - We can request directly.
            CRM_CRMRecipeRun__c newRun = new CRM_CRMRecipeRun__c();
            HttpResponse runResp;
            
            // Handle different types of requests
            if (requests[0].dataFlowType == 'DataConnector') {
                runResp = runDataConnectorSync(dataFlowId);
            } else {
                runResp = runDataflowJob(dataFlowId);
            }
            
            
            Map<String,Object> responseBody = (Map<String,Object>) JSON.deserializeUntyped(runResp.getBody());
            if (requests[0].dataFlowType == 'DataConnector') {
                return;
            }
            newRun.CRM_JobID__c = getJobId(responseBody);
            newRun.CRM_JobName__c = jobIdToNameMApe.get(dataFlowId);

            newRun.CRM_Status__c = (string) responseBody.get('status');
            if (newRun.CRM_Status__c == 'Queued') {
                newRun.CRM_Status__c = 'Running';
            }

          
            newRun.CRM_Progress__c = (Decimal) (responseBody.get('progress')) * 100;
            string startDateString = (string) responseBody.get('startDate');
            if (startDateString != null) {
                string formattedDateStr = startDateString.replace('T', ' ').substring(0,19);
                newRun.CRM_StartTime__c = Datetime.valueOfGmt(formattedDateStr);
            }
            
            newRun.CRM_NextCheckTime__c = DateTime.now().addMinutes(pollInterval);
            newRun.CRM_RecipeID__c = dataFlowId;
            insert newRun;

            for (String usId : userIds) {
                //Create a user request for each user
                CRM_UserCRMRecipeRequest__c userRequest = new CRM_UserCRMRecipeRequest__c();
                userRequest.CRMA_RequestingUser__c = usId;
                userRequest.CRM_CRMRecipeRun__c = newRun.Id;
                userRequests.put(usId, userRequest);
            }
        }
    }

    upsert runsToUpdate.values();
    upsert userRequests.values();



    }

    global string getJobId(Map<String,Object> responseBody) {
        string tempId = (string) responseBody.get('id');
        HttpResponse resp = getDataFlow(tempId);
        Map<String,Object> respBody = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());
      
        List<Object> dataFlowJobs = (List<Object>) respBody.get('dataflowJobs');
        Object job = dataFlowJobs.get(0);
        Map<String,Object> jobMap = (Map<String,Object>) job;
        return (string) jobMap.get('id');
    }

    //aura enabled - get recipes, get dataflows 
    @auraEnabled (cacheable=true)
    global static string getRecipesAura() {
        CRMA_WS ws = new CRMA_WS();
        HttpResponse response = ws.getRecipes();
       

        return response.getBody();
    }

    @auraEnabled(cacheable=true)
    global static string getDataFlowsAura() {
        CRMA_WS ws = new CRMA_WS();
        HttpResponse response = ws.getDataFlows();
        return response.getBody();
    }


    // global httpResponse performRequest()

    global class dataflowrequest {
        @invocableVariable
        global string dataFlowId;
        @invocableVariable
        global string dataFlowType;
        @invocableVariable
        global string dataFlowName;
        @invocableVariable
        global string requestingUserId;
    }

    global class getDataFlowJobsResponse {
        global List<getDataFlowJobResponse> dataFlowJobs;


        global getDataFlowJobsResponse(httpResponse response) {
                       
            
            Map<String,Object> responseBody = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
            system.debug(responseBody);
            system.debug(responseBody.get('dataflowJobs'));
            List<Object> dataFlowJobs = (List<Object>) responseBody.get('dataflowJobs');
            
            this.dataFlowJobs = new List<getDataFlowJobResponse>();
            for (Object dJob : dataFlowJobs)  {
                this.dataFlowJobs.add(new getDataFlowJobResponse((Map<String,Object>) dJob));
            }
        }

    }

    global class getDataFlowJobResponse {
        global Integer duration;
        global DateTime endDate;
        global DateTime executedDate;
        global String jobId;
        global String jobType;
        global String message;
        global Decimal progress;
        global String status;
        global DateTime StartDate;
        global Integer retryCount;
        global Integer waitTime;
        
        private DateTime parseDateTime(String dateStr) {


            if (dateStr == null || !dateStr.contains('T')) {
                return null;
            }

            string formattedDateStr = dateStr.replace('T', ' ').substring(0,19);
            return DateTime.valueOfGMT(formattedDateStr);
        }


        global getDataFlowJobResponse(Map<String,Object> response) {
            this.duration = (Integer) response.get('duration');
            string dateStr;
            
            //end date is string like '2024-03-10T22:59:29.000Z'
            dateStr = (String) response.get('endDate');
           
            this.endDate = parseDateTime(dateStr);

            dateStr = (String) response.get('executedDate');
          
            this.executedDate = parseDateTime(dateStr);

            this.jobId = (String) response.get('id');
            this.jobType = (String) response.get('jobType');
            this.message = (String) response.get('message');
            this.progress = (Decimal) response.get('progress');
            this.status = (String) response.get('status');
            // this.StartDate = DateTime.parse((String) response.get('startDate'));
            dateStr = (String) response.get('startDate');
          
            this.StartDate = parseDateTime(dateStr);

            this.retryCount = (Integer) response.get('retryCount');
            this.waitTime = (Integer) response.get('waitTime');
        }

    }
    
}

 // for (String jobId : notCompleteRunsMap.keySet()) {
        //     if (dataFlowJobsMap.containsKey(jobId)) {
        //         getDataFlowJobResponse job = dataFlowJobsMap.get(jobId);
        //         CRM_CRMRecipeRun__c run = notCompleteRunsMap.get(jobId);
        //         run.CRM_Status__c = job.status;
        //         run.CRM_Progress__c = job.progress;
        //         run.CRM_Message__c = job.message;
        //         run.CRM_StartDate__c = job.StartDate;
        //         run.CRM_EndDate__c = job.endDate;
        //         run.CRM_ExecutedDate__c = job.executedDate;
        //         run.CRM_Duration__c = job.duration;
        //         run.CRM_RetryCount__c = job.retryCount;
        //         run.CRM_WaitTime__c = job.waitTime;


        //         if (isFinished(job.status)) {
        //             run.CRM_NextCheckTime__c = null;
        //         }


        //         runsToUpdate.put(run.Id, run);
        //     }
        // }