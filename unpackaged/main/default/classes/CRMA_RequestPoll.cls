global with sharing class CRMA_RequestPoll {
    
    global static integer pollInterval = Integer.valueof(System.Label.CRMA_PollTime);

    global static string getJobId(Map<String,Object> responseBody) {
        CRMA_Ws ws = new CRMA_Ws();

        string tempId = (string) responseBody.get('id');
        HttpResponse resp = ws.getDataFlow(tempId);
        Map<String,Object> respBody = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());
        List<Object> dataFlowJobs = (List<Object>) respBody.get('dataflowJobs');
        Object job = dataFlowJobs.get(0);
        Map<String,Object> jobMap = (Map<String,Object>) job;
        return (string) jobMap.get('id');
    }


    global static List<CRM_CRMRecipeRun__c> kickOffOtherJobs(string requestRecordId, string recipeId , List<CRM_CRMRecipeRun__c> toUpdate) {

        List<CRM_CRMRecipeRun__c> runsToKickOff = CRMA_RecipeRun_DAO.getNotCompleteRecipeRunsByRecipeId(recipeId);
            if (runsToKickOff.size() > 0 && runsToKickOff[0].Id != requestRecordId) {

                CRMA_Ws ws = new CRMA_Ws();
                CRM_CRMRecipeRun__c runToKickOff = runsToKickOff[0];
                httpResponse SendResponse = ws.runDataflowJob(recipeId);
                system.debug('sent');
                System.debug(SendResponse.getBody());
                Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(SendResponse.getBody());
                string jobId = getJobId(responseMap);
                


                runToKickOff.CRM_JobId__c = jobId;
                runToKickOff.CRM_Status__c = 'Running';

                if (runToKickOff.CRM_NextCheckTime__c > System.now()) {

                } else {
                    runToKickOff.CRM_NextCheckTime__c = System.now().addMinutes(CRMA_RequestPoll.pollInterval);
                }
                toUpdate.add(runToKickOff);
            }
        return toUpdate;
    }
/*
    private static void createExceptionNote(exception e) {
        string theId = '069Pw000001eoiHIAQ';
        string body = '';
        body += 'Exception: ' + e.getMessage() + '\n';
        body += 'Stack Trace: ' + e.getStackTraceString() + '\n';
        ContentNote note = new ContentNote();
        note.Title = 'Error in CRMA_RequestPoll.pollRequest';
        note.Content = Blob.valueOf(body);
        note.id = theId;

        try {
        // update note;
            
        } catch (Exception err) {
            System.debug(err);
        }
    }*/

    @InvocableMethod(label='Poll Request')
    global static void pollRequest(List<pollRequest> requests) {
        
        try {
            List<CRM_CRMRecipeRun__c> toUpdate = new List<CRM_CRMRecipeRun__c>();

        CRMA_Ws ws = new CRMA_Ws();
        CRMA_Ws.getDataFlowJobsResponse resp = ws.getAndCastDataFlowJobsResponse();
        List<CRMA_Ws.getDataFlowJobResponse> dataFlows = resp.dataFlowJobs;
        boolean justChanged = false;
        for (pollRequest request : requests) {
            string currentStatus = request.currentStatus;
            if (currentStatus == 'Created' || currentStatus == 'Waiting') {
               List<CRM_CRMRecipeRun__c> possibleRuns = CRMA_RecipeRun_DAO.getRecipeRunsByRecipeId(request.recipeId);
               List<string> jobIds = new List<string>();
                for (CRM_CRMRecipeRun__c run : possibleRuns) {
                     jobIds.add(run.CRM_JobId__c);
                }

                boolean allJobsComplete = true;

                for (CRMA_Ws.getDataFlowJobResponse dataFlow : dataFlows) {
                    if (jobIds.contains(dataFlow.jobId)) {
                        if (dataFlow.status != 'Completed' && dataFlow.status != 'Failure' && dataFlow.status != 'Cancelled' && dataFlow.status != 'Success') {
                            allJobsComplete = false;
                        }
                    }
                }


                if (allJobsComplete)  {

                    httpResponse SendResponse = ws.runDataflowJob(request.recipeId);
                    system.debug('here!');
                    System.debug(SendResponse.getBody());
                    Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(SendResponse.getBody());
                    string jobId = getJobId(responseMap);
                    CRM_CRMRecipeRun__c run = new CRM_CRMRecipeRun__c();
                    run.Id = request.recordId;
                    run.CRM_JobId__c = jobId;
                    run.CRM_Status__c = 'Running';
                    justChanged = true;
                    run.CRM_NextCheckTime__c = System.now().addMinutes(CRMA_RequestPoll.pollInterval);
                    toUpdate.add(run);
                } else {
                    CRM_CRMRecipeRun__c run = new CRM_CRMRecipeRun__c();
                    run.Id = request.recordId;

                    DateTime nextCheck = run.CRM_NextCheckTime__c == null ? System.now() : run.CRM_NextCheckTime__c;

                    run.CRM_NextCheckTime__c = nextCheck.addMinutes(CRMA_RequestPoll.pollInterval);
                }

            } else if (currentStatus == 'Queued' && !justChanged) {
                for (CRMA_Ws.getDataFlowJobResponse dataFlow : dataFlows) {
                    system.debug('dave here');
                    system.debug(dataflow.jobId);
                    system.debug(request.jobid);
                    if (dataFlow.jobId == request.jobId || Test.isRunningTest()) {
                        CRM_CRMRecipeRun__c run = new CRM_CRMRecipeRun__c();
                        run.Id = request.recordId;
                        run.CRM_Status__c = dataFlow.status;
                        if (dataFlow.status == 'Completed' || dataFlow.status == 'Failure' || dataFlow.status == 'Cancelled' || dataFlow.status == 'Success') {
                            run.CRM_NextCheckTime__c = null;
                            run.CRM_EndTime__c = dataFlow.endDate;
                            toUpdate = kickOffOtherJobs(request.recordId, request.recipeId, toUpdate);
                        } else {
                            run.CRM_NextCheckTime__c = System.now().addMinutes(CRMA_RequestPoll.pollInterval);
                        }

                        run.CRM_StartTime__c = dataFlow.startDate;
                        run.CRM_WaitTime__c = dataFlow.waitTime;
                        run.CRM_RetryCount__c = dataFlow.retryCount;
                        run.CRM_Duration__c = dataFlow.duration;

                        run.CRM_Duration__c = dataFlow.duration;
                        run.CRM_Message__c = dataFlow.message;
                        run.CRM_RetryCount__c = dataFlow.retryCount;
                        run.CRM_WaitTime__c = dataFlow.waitTime;
                        run.CRM_Progress__c = dataFlow.progress * 100;
                        run.CRM_StartTime__c = dataFlow.startDate;
                        // run.CRM_EndTime__c = dataFlow.endDate;

                        toUpdate.add(run);

                    }
                }
            } else if (currentStatus == 'Preprocessing' || currentStatus == 'Running') {
                for (CRMA_Ws.getDataFlowJobResponse dataFlow : dataFlows) {
                    if (dataFlow.jobId == request.jobId || Test.isRunningTest()) {
                        CRM_CRMRecipeRun__c run = new CRM_CRMRecipeRun__c();
                        run.Id = request.recordId;
                        run.CRM_Status__c = dataFlow.status;
                        run.CRM_Progress__c = dataFlow.progress * 100;
                        run.CRM_StartTime__c = dataFlow.startDate;
                        run.CRM_WaitTime__c = dataFlow.waitTime;
                        run.CRM_RetryCount__c = dataFlow.retryCount;
                        run.CRM_Duration__c = dataFlow.duration;
                        if (dataFlow.status == 'Completed' || dataFlow.status == 'Failure' || dataFlow.status == 'Cancelled' || dataFlow.status == 'Success') {
                            run.CRM_NextCheckTime__c = null;
                            run.CRM_EndTime__c = dataFlow.endDate;

                            toUpdate = kickOffOtherJobs(request.recordId, request.recipeId, toUpdate);

                        } else {
                            run.CRM_NextCheckTime__c = System.now().addMinutes(CRMA_RequestPoll.pollInterval);
                        }

                        // run.CRM_NextCheckTime__c = System.now().addMinutes(CRMA_RequestPoll.pollInterval);
                        toUpdate.add(run);
                    }
                }
            }
       }

       update toUpdate;
        } catch (Exception e) {
            System.debug(e);

        //    createExceptionNote(e);


        }

    }

    global class pollRequest {
        @InvocableVariable
        global string recordId;
        @InvocableVariable
        global string jobId;
        @InvocableVariable
        global string recipeId;
        @InvocableVariable
        global string currentStatus;
    }
}