global without sharing class AutoApprovalSchedule implements Schedulable {
    
    //for setup we can run this script that will schedule the class to run on the 1st minute of every hour  
    /*
        String chron = '0 0 * * * ? *';
        System.schedule('AutoApprovalSchedule',chron, new AutoApprovalSchedule());
    **/
     
    //for aborting use the following for aborting, put in the name from scheduled jobs page as shown    
    /*
        CronTrigger ct = [SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType FROM CronTrigger
                 WHERE CronJobDetail.Name = 'AutoApprovalSchedule:1576509076640'];
        system.abortJob(ct.Id);
    **/ 
     
    private Integer timeoutHours = General_Settings__c.getInstance().Approval_Timeout_Hours__c.IntValue();
    private String approveMsg = 'Auto Approving request for Opportunity as '+timeoutHours+'hrs have passed.';
     
    global void execute(SchedulableContext SC) {
        system.debug('run AutoApprovalSchedule');
        
        try{    
            
            Set<String> userAliasToApproveFor = new Set<String>();
            userAliasToApproveFor.add('mcorn');
            userAliasToApproveFor.add('jgree');
            userAliasToApproveFor.add('ibeyn');
            userAliasToApproveFor.add('jthom');
                         
            List<ProcessInstanceWorkitem> pItems = [SELECT Id,ActorId FROM ProcessInstanceWorkitem WHERE ElapsedTimeInHours > :timeoutHours];
            system.debug('pItems.size() = '+pItems.size());
                        
            if(!pItems.isEmpty()){
                        
                List<User> usersToApproveFor = [SELECT Id FROM User WHERE Alias IN : userAliasToApproveFor];        
                Set<Id> approverIds = new Set<Id>();
                for(User u : usersToApproveFor){
                    approverIds.add(u.Id);
                }
                                      
                for(ProcessInstanceWorkitem p : pItems){                        
                    system.debug(p);                    
                    if(approverIds.contains(p.ActorId)) {
                        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                        req.setComments(approveMsg); 
                        req.setAction('Approve');
                        req.setWorkitemId(p.Id);            
                        Approval.ProcessResult result = Approval.process(req);      
                    }                   
                }         
            }   
        }catch(Exception e){
            system.debug('AutoApprovalSchedule Error');
            system.debug(e.getMessage());
            Error__c err = new Error__c(Title__c = 'AutoApprovalSchedule',Object__c = 'AutoApprovalSchedule',Description__c = 
                'Problem encountered in AutoApprovalSchedule',Sub_Description__c = e.getMessage()+' : '+e);
            insert err;
        }   
    }   
     
}