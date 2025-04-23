@isTest
class SandboxSetupTest {

    @isTest
    static void testMySandboxPrep() {

        TestData.setupProductsAndPriceBooks();
        
        Test.startTest();

        Test.testSandboxPostCopyScript(
            new SandboxSetup(), UserInfo.getOrganizationId(),
                UserInfo.getOrganizationId(), UserInfo.getOrganizationName());

        Test.stopTest();

    }
}