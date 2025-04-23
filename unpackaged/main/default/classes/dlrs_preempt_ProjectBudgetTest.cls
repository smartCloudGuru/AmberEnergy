/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_preempt_ProjectBudgetTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_preempt_ProjectBudgetTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new preempt__ProjectBudget__c());
    }
}