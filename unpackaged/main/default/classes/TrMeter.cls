public with sharing class TrMeter {
    
    @InvocableMethod
    /*
    * This method built to be called via process builder and sends a plan text email alert to the Trading team
    * This alert will only alert trading of any meters that have been made inactive, where the meter has a current
    * or future flex product
    */
    public static void inactiveMeterAlertTrading(List<Id> meterIds){
        
        Set<Id> meterIdSet = new Set<Id>(meterIds);
        system.debug('meterIdSet: ' +meterIdSet);
        List<Supply_Contract__c> supplyContractList = [ SELECT Id,Meter__c,Product_Type__c,Contract_End_Date__c 
                                                        FROM Supply_Contract__c 
                                                        WHERE Meter__c =: meterIdSet
                                                        AND Contract_End_Date__c >=: system.today()];
        
        system.debug('supplyContractList: ' +supplyContractList);
        
        //Create and populate set of meter IDs to perform SOQL Statement to get fields for email build                                  
        Set<Id> metersToRecieveNotificationSet = new Set<Id>();
        
        system.debug('supplyContractList: ' +supplyContractList);
        
        if(!supplyContractList.isEmpty()){
            
            Integer i = 0;
            
            for(Supply_Contract__c s : supplyContractList){
                
                system.debug('i: ' +i);
                
                system.debug('s: ' +s);
                if(s.Product_Type__c != null){
                    
                    if(s.Meter__c != null && s.Product_Type__c.contains('Flex') && s.Contract_End_Date__c >= system.today()){
                        metersToRecieveNotificationSet.add(s.Meter__c);
                    
                        system.debug('metersToRecieveNotificationSet: ' +metersToRecieveNotificationSet);
                    
                    }
                }
                i++;            
            }           
        }                                                       
        List<Meter_Details__c> flexMeterInformation = [SELECT Id,Name FROM Meter_Details__c WHERE Id =: metersToRecieveNotificationSet];
        system.debug('flexMeterInformation: ' +flexMeterInformation);
        
        //Send email
        if(!flexMeterInformation.isEmpty()){
            Messaging.SingleEmailMessage email = createTradingEmail(flexMeterInformation);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            
            system.debug('email: ' +email);
        }
    }
    
    /**
    * This method builds a plain text email notification to alert the trading desk that a meter has been made inactive
    * @param List of meters to send the email to, must include the meter name field within List
    * @returns single email message, populated with recipient - TRADING DESK, subject and email body
    */
    public static Messaging.SingleEmailMessage createTradingEmail(List<Meter_Details__c> meters){
        
        List<Meter_Details__c> meterNotificationList = new List<Meter_Details__c>(meters);
        
        final String TRADING_INBOX = 'tradingdesk@amberenergy.net';
        final String SUBJECT ='Inactive Meter Alert';
        String meterString = '';
        String emailBody = '';
        
        //Create list of recipients
        List<String> recipients = new List<String>();
        recipients.add(TRADING_INBOX);
        
        //Create string of meters for the email body and create email body
        for(Meter_Details__c m : meterNotificationList){
            meterString = meterString + m.Name + '\n'; 
        }
        
        emailBody = 'The following meters have been made inactive within Salesforce and currently hold or will hold a flex contract:'
                    + '\n\n' +meterString;
                
        //Build and return email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(recipients);
        mail.setSubject(SUBJECT);
        mail.setPlainTextBody(emailBody);
        mail.setUseSignature(false);
        
        return mail;
    }
    
}