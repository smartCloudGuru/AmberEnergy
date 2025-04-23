public with sharing class CU_TariffCalculator {
    
    public Map<Id,Meter_Details__c> meterMap;
    public Map<Id,List<Supply_Contract__c>> meterToSupplyContracts;
    public Map<Id,List<Flex_Rate__c>> supplyContractToFlexRates;
    public Map<Id,Flex_Rate__c> meterTariffToFlexRate;
    List<CU_Meter_Tariff__c> meterTariffs;
    CU_Tariff__c tariff;
    CU_Tariff__c newTariff = new Cu_Tariff__c();
    
    public CU_TariffCalculator(Id tariffId) {
        gatherData(tariffId);
        newTariff.Id = tariffId;
    }
    
    public CU_Tariff__c calculateTariff() {
        Id meterId = metertariffs[0].Meter__c;
        Meter_Details__c meter = meterMap.get(meterId);
        RecordType rt = [Select Id, name from recordtype where id = :meter.RecordTypeId];
        if (rt.Name.contains('Gas')) {
            calculateGasTariffs();
        } else {
            calculateElectricalTariffs();
        }
        
        update meterTariffs;
         
       
        update this.newTariff;
      
        
        return this.tariff;
    }
    
    public void calculateGasTariffs() {
        for (CU_Meter_Tariff__c meterTariff : meterTariffs) {
            Meter_Details__c meter = meterMap.get(meterTariff.Meter__c);
            meterTariff = this.calculateGasTariff(meterTariff);
        }
        
        decimal llConribution = this.tariff.Landlord_Contribution_p_kWh__c;
        decimal debtSinkingFund = this.tariff.Debt_Sinking_Fund_p_kWh__c;
        decimal tariffVat = this.tariff.Tariff_VAT__c;
     
        decimal d = this.tariff.Number_of_Apartments__c;
        decimal e = this.tariff.Landlord_Subsidy_p_day__c;
        decimal f = this.tariff.LL_Communal_Contribution__c;
       
        decimal heatEfficiency = this.tariff.Heat_Efficiency_Factor__c;
   
        decimal unitRatTotal = 0;
        decimal residentStandingCharge = 0;
        
        for (CU_Meter_Tariff__c meterTariff : meterTariffs) {
            //decimal currentVal = ((meterTariff.MT_Tariff_Single_Rate_p_kWh__c / heatEfficiency) -llConribution + debtSinkingFund) * (1+tariffVat);
            
            decimal currentVal = (
        (
            meterTariff.MT_Tariff_Single_Rate_p_kWh__c + debtSinkingFund
        ) 
        / heatEfficiency
    ) 
    - llConribution;

    // If column O still includes VAT, multiply at the end:
    currentVal = currentVal * (1 + tariffVat);
            
            
            unitRatTotal +=  currentVal;
            residentStandingCharge += meterTariff.MT_Resident_Standing_Charge_p_day__c;
            meterTariff.Meter_Tariff_Unit_Rate_p_kWh__c = currentVal;
        }
        
        this.tariff.Tariff_Unit_Rate__c = unitRatTotal;
        this.newTariff.Tariff_Unit_Rate__c = unitRatTotal;
        this.tariff.Resident_Standing_Charge_p_day__c = (residentStandingCharge * ((1 - f) / d) * (1 + tariffVat)) - e;
        this.newTariff.Resident_Standing_Charge_p_day__c = this.tariff.Resident_Standing_Charge_p_day__c;
    }



    private void logWithParamName(String paramName, Object paramValue) {
        system.debug(paramName + ' is ' + paramValue);
    }
    
    public CU_Meter_Tariff__c calculateGasTariff(CU_Meter_Tariff__c meterTariff) {
        decimal h = this.tariff.Commodity_Rate__c;
        
        decimal gasSingleRate = 0;
        decimal sumConfirmedCharge = 0;
        
        // Get the specific flex rate for this meter tariff
        Flex_Rate__c flexRate = meterTariffToFlexRate.get(meterTariff.Id);
        if(flexRate != null) {
            decimal o = flexRate.Confirmed_All_Units_pkWh__c ?? 0;
            decimal t = flexRate.Confimed_Standing_Charge_pday__c ?? 0;
            
            gasSingleRate = o + h;
            sumConfirmedCharge = t;
        }
        
        meterTariff.MT_Tariff_Single_Rate_p_kWh__c = gasSingleRate;
        meterTariff.MT_Resident_Standing_Charge_p_day__c = sumConfirmedCharge;
        
        return meterTariff;
    }
    
    public void calculateElectricalTariffs() {
        decimal ksum = 0;

        system.debug('Starting to calculate electrical tariffs');
        
        logWithParamName('h', this.tariff.Commodity_Rate__c);
        decimal h = this.tariff.Commodity_Rate__c;

        //log params as we make them!
        logWithParamName('a', this.tariff.Landlord_Contribution_p_kWh__c);

        decimal a = this.tariff.Landlord_Contribution_p_kWh__c;
        logWithParamName('b', this.tariff.Debt_Sinking_Fund_p_kWh__c);

        decimal b = this.tariff.Debt_Sinking_Fund_p_kWh__c;
        logWithParamName('c', this.tariff.Tariff_VAT__c);
        decimal c = this.tariff.Tariff_VAT__c;
        logWithParamName('d', this.tariff.Number_of_Apartments__c);
        decimal d = this.tariff.Number_of_Apartments__c;

        logWithParamName('e', this.tariff.Landlord_Subsidy_p_day__c);
        decimal e = this.tariff.Landlord_Subsidy_p_day__c;
        logWithParamName('f', this.tariff.LL_Communal_Contribution__c);
        decimal f = this.tariff.LL_Communal_Contribution__c;
        logWithParamName('x',(String.isBlank(String.valueOf(this.tariff.Capacity_p_kva_day__c)) ? 0 : this.tariff.Capacity_p_kva_day__c));
        decimal x = (String.isBlank(String.valueOf(this.tariff.Capacity_p_kva_day__c)) ? 0 : this.tariff.Capacity_p_kva_day__c);
       
        system.debug('looping through meter tariffs');
        for (CU_Meter_Tariff__c meterTariff : meterTariffs) {
            Meter_Details__c meter = meterMap.get(meterTariff.Meter__c);
            system.debug('current meter is ' + meter.Name);
            system.debug('current meter EAC is ' + meter.EAC__c);

            system.debug('ksum was ' + ksum);
            ksum+= meter.EAC__c;
            system.debug('ksum is now ' + ksum);

            system.debug('calling calculate electrical tariff for this one tariff');
            meterTariff = this.calculateElectricalTariff(meterTariff);
        }
        
        decimal tariffSingleRate = 0;
        decimal unitRateSum = 0;
        decimal capacitySum = 0;
        decimal residentStandingCharge = 0;

        for (CU_Meter_Tariff__c meterTariff : meterTariffs) {
            Meter_Details__c meter = meterMap.get(meterTariff.Meter__c);
            decimal k = meter.EAC__c;
            system.debug('singlerate - ' + meterTariff.MT_Tariff_Single_Rate_p_kWh__c + ' k:' + k + 'ksum:'+ksum);
            tariffSingleRate += (meterTariff.MT_Tariff_Single_Rate_p_kWh__c * k) / ksum;
            unitRateSum += (meterTariff.Meter_Tariff_Unit_Rate_p_kWh__c * k) / ksum;
            capacitySum += meterTariff.MT_Capacity_p_kva_day__c;
            residentStandingCharge += meterTariff.MT_Resident_Standing_Charge_p_day__c;
        }

        logWithParamName('residentStandingCharge', residentStandingCharge);


        system.debug('calculating single rate');
        system.debug(tariffSingleRate);
        this.tariff.Tariff_Single_Rate__c = tariffSingleRate;
        this.newTariff.Tariff_Single_Rate__c = tariffSingleRate;
        system.debug(this.tariff.Tariff_Single_Rate__c);
        this.tariff.Tariff_Unit_Rate__c = unitRateSum;
        this.newTariff.Tariff_Unit_Rate__c = unitRateSum;
        this.tariff.Capacity_p_kva_day__c = capacitySum;
            this.newTariff.Capacity_p_kva_day__c = capacitySum;
            System.debug('calculating Resident_Standing_Charge_p_day__c using ((residentStandingCharge) * ((1 - f) / d) * (1 + c)) - e');
        this.tariff.Resident_Standing_Charge_p_day__c = ((residentStandingCharge+capacitySum) * ((1 - f) / d) * (1 + c)) - e;
        logWithParamName('Resident_Standing_Charge_p_day__c', this.tariff.Resident_Standing_Charge_p_day__c);

        this.newTariff.Resident_Standing_Charge_p_day__c = this.tariff.Resident_Standing_Charge_p_day__c;
    }
    
    public CU_Meter_Tariff__c calculateElectricalTariff(CU_Meter_Tariff__c meterTariff) {

        
        Meter_Details__c meter = meterMap.get(meterTariff.Meter__c);

        logWithParamName('k', meter.EAC__c);
        decimal k = meter.EAC__c ?? 0;
        logWithParamName('n', meter.kVA__c);
        decimal n = meter.kVA__c ?? 0;
        
        logWithParamName('meter.Day_Split__c', meter.Day_Split__c);
        logWithParamName('l', (meter.Day_Split__c != null) ? meter.Day_Split__c / 100 : 0);
        decimal l = (meter.Day_Split__c != null) ? meter.Day_Split__c / 100 : 0;
                
        logWithParamName('meter.Night_Split__c', meter.Night_Split__c);
        logWithParamName('m', (meter.Night_Split__c != null) ? meter.Night_Split__c / 100 : 0);
        decimal m = (meter.Night_Split__c != null) ? meter.Night_Split__c / 100 : 0;
        

        logWithParamName('h', this.tariff.Commodity_Rate__c);
        decimal h = this.tariff.Commodity_Rate__c;
        logWithParamName('a', this.tariff.Landlord_Contribution_p_kWh__c);
        decimal a = this.tariff.Landlord_Contribution_p_kWh__c;
        logWithParamName('b', this.tariff.Debt_Sinking_Fund_p_kWh__c);
        decimal b = this.tariff.Debt_Sinking_Fund_p_kWh__c;

        logWithParamName('c', this.tariff.Tariff_VAT__c);
        decimal c = this.tariff.Tariff_VAT__c;
        
        decimal elecSingleRate = 0;
        decimal elecCapacityRate = 0;
        decimal sumConfirmedCharge = 0;
        
        // Get the specific flex rate for this meter tariff
        Flex_Rate__c flexRate = meterTariffToFlexRate.get(meterTariff.Id);
        if(flexRate != null) {
            system.debug('got flex rate');
            logWithParamName('o', flexRate.Confirmed_All_Units_pkWh__c);
            decimal o = flexRate.Confirmed_All_Units_pkWh__c ?? 0;
            logWithParamName('p', flexRate.Confirmed_Day_Units_pkWh__c);
            decimal p = flexRate.Confirmed_Day_Units_pkWh__c ?? 0;
            logWithParamName('q', flexRate.Confirmed_Night_Units_pkWh__c);
            decimal q = flexRate.Confirmed_Night_Units_pkWh__c ?? 0;
            logWithParamName('t', flexRate.Confimed_Standing_Charge_pday__c);
            decimal t = flexRate.Confimed_Standing_Charge_pday__c ?? 0;

            
            logWithParamName('u', flexRate.Confirmed_Capacity_Charge_pkVAmonth__c);
            decimal u = flexRate.Confirmed_Capacity_Charge_pkVAmonth__c ?? 0;
            
            if (flexRate.Supply_Contract__r.Tariff_Type__c == 'Single Rate') {
                system.debug('is Single rate so using (l * o) + (m * o)');
                elecSingleRate = (l * o) + (m * o);
                logWithParamName('elecSingleRate', elecSingleRate);
            } 
            else if(flexRate.Supply_Contract__r.Tariff_Type__c == 'Day/Night') {
                system.debug('is Day/Night so using (l * p) + (m * q)');
                elecSingleRate = (l * p) + (m * q);
                logWithParamName('elecSingleRate', elecSingleRate);

            }
            system.debug('electCapacityRate using ((n * u) * 12) / 365');
            elecCapacityRate = ((n * u) * 12) / 365;
            logWithParamName('elecCapacityRate', elecCapacityRate);
            sumConfirmedCharge = t;
            logWithParamName('sumConfirmedCharge', sumConfirmedCharge);
        }
        
        meterTariff.MT_Tariff_Single_Rate_p_kWh__c = elecSingleRate;
        meterTariff.MT_Capacity_p_kva_day__c = elecCapacityRate;
        

        system.debug('calculating unit rate using ((elecSingleRate + h - a + b) * (1 + c))');
        decimal unitRate = (elecSingleRate + h - a + b)   * (1 + c);
        //decimal UnitRate = ((elecSingleRate + h + b) - a) * (1 + c);
        logWithParamName('unitRate', unitRate);
        meterTariff.Meter_Tariff_Unit_Rate_p_kWh__c = unitRate; 
        meterTariff.MT_Resident_Standing_Charge_p_day__c = sumConfirmedCharge;
        
        return meterTariff;
    }
    public void gatherData(Id tariffId) {
        system.debug('tariff id received is ' + tariffId);
        
        // Get the tariff
        this.tariff = [SELECT Id, Capacity_p_kva_day__c 
                      FROM CU_Tariff__c 
                      WHERE Id = :tariffId 
                      LIMIT 1];
        
        // Get meter tariffs with Flex Rate reference
        this.meterTariffs = [SELECT Id, Meter__c, Flex_Rate__c, 
                                   MT_Tariff_Single_Rate_p_kWh__c, 
                                   MT_Resident_Standing_Charge_p_day__c,
                                   Meter_Tariff_Unit_Rate_p_kWh__c, 
                                   MT_Capacity_p_kva_day__c 
                            FROM CU_Meter_Tariff__c 
                            WHERE CU_Tariff__c = :tariffId];
        
        Set<Id> meterIds = new Set<Id>();
        Set<Id> flexRateIds = new Set<Id>();
        
        for (CU_Meter_Tariff__c meterTariff : meterTariffs) {
            meterIds.add(meterTariff.Meter__c);
            if(meterTariff.Flex_Rate__c != null) {
                flexRateIds.add(meterTariff.Flex_Rate__c);
            }
        }
        
        // Get meters
        List<Meter_Details__c> meters = [SELECT Id, RecordTypeId, Name, Site__c, 
                                              EAC__c, Resident_Supply__c, Sub_Billed__c,
                                              Day_Split__c, Night_Split__c, kVA__c   
                                       FROM Meter_Details__c 
                                       WHERE Id IN :meterIds];
        
        this.meterMap = new Map<Id,Meter_Details__c>(meters);
        
        // Get only the specific flex rates needed
        List<Flex_Rate__c> flexRates = [SELECT Id, Confirmed_All_Units_pkWh__c,
                                              Confirmed_Day_Units_pkWh__c,
                                              Confirmed_Night_Units_pkWh__c,
                                              Confirmed_Weekday_pkWh__c,
                                              Confirmed_Evening_Weekend_pkWh__c,
                                              Confimed_Standing_Charge_pday__c,
                                              Confirmed_Capacity_Charge_pkVAmonth__c,
                                              Supply_Contract__r.Tariff_Type__c
                                       FROM Flex_Rate__c 
                                       WHERE Id IN :flexRateIds];
        
        // Create map of meter tariff to flex rate
        this.meterTariffToFlexRate = new Map<Id,Flex_Rate__c>();
        for(CU_Meter_Tariff__c mt : meterTariffs) {
            if(mt.Flex_Rate__c != null) {
                for(Flex_Rate__c fr : flexRates) {
                    if(fr.Id == mt.Flex_Rate__c) {
                        meterTariffToFlexRate.put(mt.Id, fr);
                        break;
                    }
                }
            }
        }
    }
    
    @InvocableMethod(label='Calculate CU Tariff') 
    public static List<calculateResponse> calculateTariff(List<calculateRequest> reqList) {
        List<calculateResponse> responses = new List<calculateResponse>();
        calculateRequest req = reqList[0];
        
        CU_TariffCalculator calc = new CU_TariffCalculator(req.tariffId);
        calc.tariff.Landlord_Contribution_p_kWh__c = req.landLordContribution;
        calc.tariff.Debt_Sinking_Fund_p_kWh__c = req.debtSinkingFund;
        calc.tariff.Tariff_VAT__c = req.vat / 100;
        calc.tariff.Number_of_Apartments__c = req.numberOfApartments;
        calc.tariff.Landlord_Subsidy_p_day__c = req.landLordSubsidy;
        calc.tariff.LL_Communal_Contribution__c = req.llCommunalContribution / 100;
        calc.tariff.Heat_Efficiency_Factor__c = req.heatEfficiencyFactor / 100;
        system.debug('given heat efficent   ' +  req.heatEfficiencyFactor);
        calc.tariff.Commodity_Rate__c = req.commodityRate;
        
        calculateResponse response = new calculateResponse();
        response.success = false;
        try {
            calc.calculateTariff();
            response.success = true;
            response.errorMessage = '';
        } catch (Exception e) {
            response.success = false;
            response.errorMessage = e.getMessage() + ' ' + e.getStackTraceString();
        }
        
        responses.add(response);
        return responses;
    }
    
    public class cuMeterTariffWrapper {
        public Id tariffId;
        public CU_Meter_Tariff__c tariff;
        public Meter_Details__c meter;
        public List<Supply_Contract__c> supplyContracts;
        public Map<Id,List<Flex_Rate__c>> flexRates;
    }
    
    public class calculateRequest {
        @invocableVariable(label='CU Tariff Id' required=true)
        public Id tariffId;
        
        @invocableVariable(label='Landlord Contribution (p/kWh)' required=true)
        public Decimal landLordContribution ;
        
        @invocableVariable(label='Debt Sinking Fund (p/kWh)' required=true)
        public Decimal debtSinkingFund ;
        
        //Below is pinvocableVariableercent
        @invocableVariable(label='VAT' required=true)
        public Decimal vat ;
        
        @invocableVariable(label='Number of Apartments' required=true)
        public Integer numberOfApartments ;
        
        @invocableVariable(label='Landlord Subsidy (p/day)' required=true)
        public Decimal landLordSubsidy ;
        
        //Below is percent
        @invocableVariable(label='LL Communal Contribution' required=true)
        public Decimal llCommunalContribution ;
        
        //Below is percent
        @invocableVariable(label='Heat Efficiency Factor' required=true)
        public Decimal heatEfficiencyFactor ;
        
        @invocableVariable(label='Commodity Rate' required=true)
        public Decimal commodityRate ;
    }
    
    public class calculateResponse{
        @invocableVariable(label='Success')
        public Boolean success ;
        @invocableVariable(label='Error Message')
        public string errorMessage ;
    }
}