public without sharing class TriggerHandlerTest extends TriggerHandler {

    public TriggerHandlerTest() {
        this.setMaxLoopCount(3);
        this.clearMaxLoopCount();
        TriggerHandler.bypass('test');
        TriggerHandler.isBypassed('test'); 
        TriggerHandler.clearBypass('test');
        TriggerHandler.clearAllBypasses();      
    }
    
}