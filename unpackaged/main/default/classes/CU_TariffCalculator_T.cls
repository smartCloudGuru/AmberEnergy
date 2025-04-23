@IsTest
public with sharing class CU_TariffCalculator_T {
    public static final Id meterElecRTId = Schema.SObjectType.Meter_Details__c.getRecordTypeInfosByDeveloperName().get('Electricity').getRecordTypeId();
    public static final Id meterGasRTId = Schema.SObjectType.Meter_Details__c.getRecordTypeInfosByDeveloperName().get('Gas').getRecordTypeId();

    @TestSetup
    public static void testSetup(){
        Account acc = new Account();
        acc.Name = 'CU_TariffCalculator_T Account';
        insert acc;

        createTariffToFlexRateData(acc.Id, meterElecRTId);
        createTariffToFlexRateData(acc.Id, meterGasRTId);
    }

    public static void createTariffToFlexRateData(Id accountId, Id meterRecordTypeId){
        String randomNumber = String.valueof(Integer.valueof((Math.random() * 1000000)));

        CU_Tariff__c cu = new CU_Tariff__c();
        cu.Landlord_Contribution_p_kWh__c = 1;
        cu.Debt_Sinking_Fund_p_kWh__c = 1;
        cu.Tariff_VAT__c = 1;
        cu.Number_of_Apartments__c = 1;
        cu.Landlord_Subsidy_p_day__c = 1;
        cu.LL_Communal_Contribution__c = 1;
        cu.Heat_Efficiency_Factor__c = 1;
        cu.Commodity_Rate__c = 1;
        insert cu;

        Meter_Details__c md = new Meter_Details__c();
        md.Name = 'Meter' + randomNumber;
        md.RecordTypeId = meterRecordTypeId;
        md.Eac__c = 1;
        md.Day_Split__c = 1;
        md.Night_Split__c = 1;
        md.kVA__c = 1;
        md.Account__c = accountId;
        insert md;

        CU_Meter_Tariff__c cumt = new CU_Meter_Tariff__c();
        cumt.Meter__c = md.Id;
        cumt.CU_Tariff__c = cu.Id;
        cumt.MT_Tariff_Single_Rate_p_kWh__c = 1;
        cumt.Meter_Tariff_Unit_Rate_p_kWh__c = 1;
        insert cumt;
        
        
       

        Supply_Contract__c sc = new Supply_Contract__c();
        sc.Meter__c = md.Id;
        sc.Tariff_Type__c = 'Single Rate';
		sc.Is_Unit_Test__c = true;
        insert sc; 

        Flex_Rate__c fr = new Flex_Rate__c();
        fr.Name = 'FlexRate' + randomNumber;
        fr.Supply_Contract__c = sc.Id;
        fr.Confirmed_All_Units_pkWh__c = 1;
        fr.Confirmed_Day_Units_pkWh__c = 1;
        fr.Confirmed_Night_Units_pkWh__c = 1;
        fr.Confirmed_Weekday_pkWh__c = 1;
        fr.Confirmed_Evening_Weekend_pkWh__c = 1;
        fr.Confimed_Standing_Charge_pday__c = 1;
        fr.Confirmed_Capacity_Charge_pkVAmonth__c = 1;
        fr.Flex_Standing_Charge_p_day__c = 1;
        fr.Flex_All_Units_p_kWh__c = 1;
        // fr.Flex_Day_Units_p_kWh__c = 1;
        // fr.Flex_Night_Units_p_kWh__c = 1;
        // fr.Flex_Weekday_p_kWh__c = 1;
        // fr.Flex_Evening_Weekend_p_kWh__c = 1;
        insert fr;
    }

    public static testMethod void testComputeElectricityTariffs(){
        CU_TariffCalculator.calculateRequest cr = new CU_TariffCalculator.calculateRequest();

        cr.tariffId = [select Id, CU_Tariff__c from CU_Meter_Tariff__c where Meter__r.RecordTypeId = :meterElecRTId limit 1].CU_Tariff__c;
        cr.landLordContribution = 1;
        cr.debtSinkingFund = 1;
        cr.vat = 1;
        cr.numberOfApartments = 1;
        cr.landLordSubsidy = 1;
        cr.llCommunalContribution = 1;
        cr.heatEfficiencyFactor = 1;
        cr.commodityRate = 1;
        
        Test.startTest();
        List<CU_TariffCalculator.calculateResponse> testComputeTariffs = CU_TariffCalculator.calculateTariff(new List<CU_TariffCalculator.calculateRequest>{cr});
        System.debug('Electricity Test');
        System.debug(JSON.serializePretty(testComputeTariffs));
        Test.stopTest();
        
        System.assert(testComputeTariffs[0].success);
    }

    public static testMethod void testComputeGasTariffs(){
        CU_TariffCalculator.calculateRequest cr = new CU_TariffCalculator.calculateRequest();

        cr.tariffId = [select Id, CU_Tariff__c from CU_Meter_Tariff__c where Meter__r.RecordTypeId = :meterGasRTId limit 1].CU_Tariff__c;
        cr.landLordContribution = 1;
        cr.debtSinkingFund = 1;
        cr.vat = 1;
        cr.numberOfApartments = 1;
        cr.landLordSubsidy = 1;
        cr.llCommunalContribution = 1;
        cr.heatEfficiencyFactor = 1;
        cr.commodityRate = 1;
        
        Test.startTest();
        List<CU_TariffCalculator.calculateResponse> testComputeTariffs = CU_TariffCalculator.calculateTariff(new List<CU_TariffCalculator.calculateRequest>{cr});
        System.debug('Gas Test');
        System.debug(JSON.serializePretty(testComputeTariffs));
        Test.stopTest();
        
        System.assert(testComputeTariffs[0].success);
    }
}