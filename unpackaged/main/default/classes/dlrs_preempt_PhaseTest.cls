/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_preempt_PhaseTest
{
    @IsTest(SeeAllData=true)
    private static void testTrigger()
    {
        // Force the dlrs_preempt_PhaseTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new preempt__Phase__c());
    }
}