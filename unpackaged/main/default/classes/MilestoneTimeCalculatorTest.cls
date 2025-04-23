@isTest 
private class MilestoneTimeCalculatorTest {
    static testMethod void testMilestoneTimeCalculator() {        
      
        // Select an existing milestone type to test with
        List<MilestoneType> milestones = [SELECT Id,Name FROM MilestoneType];      
        if(milestones.size() == 0) { return; }
        
        Case testCase = TestData.createCommunityCase();
        insert testCase;
        
        Test.setCreatedDate(testCase.Id, DateTime.newInstance(2012,12,12,17,42,29));
        
        //using the time above i know the time left today is 6 hours and 17 minutes
        //that would mean we expect the following
        // next working day kpis are expected to by 1440 + (6*60) + 17 = 1817
        // 5 working day kpis are expected to by (1440 * 5) + (6*60) + 17 = 7577
        
        MilestoneTimeCalculator calculator = new MilestoneTimeCalculator();
        
        for(MilestoneType mt : milestones){
            
            if(mt.Name.equals('5 Working Day Resolution')){              
                System.assertEquals(calculator.calculateMilestoneTriggerTime(testCase.Id, mt.Id),7577);
            }
            else{           
                System.assertEquals(calculator.calculateMilestoneTriggerTime(testCase.Id, mt.Id),1817);
            }
            
            
        }
         
    }
}