global class SandboxSetup implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
        System.debug('Org ID: ' + context.organizationId());
        System.debug('Sandbox ID: ' + context.sandboxId());
        System.debug('Sandbox Name: ' + context.sandboxName());
        
        //if there are no accounts, then lets add some alt suppliers
        List<Account> existingAccounts = [SELECT Id FROM Account];
        if(existingAccounts.isEmpty()){         
            List<Account> smeSuppliers = TestData.insertSmeSuppliers();         
        }
        
        TestData.createBundlesFromProducts();
         
    }
    
    
    
}