/**********************************************************************
Name:  Ge_GenerateNewOrderItems_I
Copyright © 2023
======================================================
======================================================
Purpose:  Invocable class for Email Message flow

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0      Lynn Mejos          04/04/2023     
***********************************************************************/
public class Ge_GenerateNewOrderItems_I {
    /*******************************************************************
    @description Method to create new OrderItem from existing OpportunityLineItem
    @param List<Requests> request - list of request variables
    @return List<Results> – list of new tender products to create
    @author Lynn Mejos
    @date 13/03/2023
    ********************************************************************/
    @InvocableMethod(label='Create New Order Items' description='Returns the OrderItems' category='Opportunity')
    public static List<Results> createNewOrderItems(List<Requests> request) {
        Order newOrder = request[0].newOrder;
        Opportunity wonOpportunity = request[0].wonOpportunity;
        List<OrderItem> newOrderProducts = new List<OrderItem>();
        List<Job__c> newDeliverables = new List<Job__c>(); 
        for(OpportunityLineItem op : request[0].oppProducts ){
            OrderItem newOrderProd = returnNewOrderProduct(op.Id,newOrder.Id,op.product2Id,op.unitPrice,op.quantity,op.productCode,op.description,op.Product_Family__c);
            newOrderProducts.add(newOrderProd);
            newDeliverables.addall(deliverableCreationHandler(op.productCode,newOrder.Id,wonOpportunity.Id));
        }
        insert newOrderProducts;
        insert newDeliverables;         
        Results response = new Results();
        response.newOrderProducts = newOrderProducts;
        response.newDeliverables = newDeliverables;
        List<Results> responseWrapper= new List<Results>();
        responseWrapper.add(response);
        return responseWrapper;
    }
    
    public static OrderItem returnNewOrderProduct (Id opProdId, Id orderId, Id prodId, Decimal cost,
                     Decimal quantity, String prodCode, String description, String family){        
        List<PriceBookEntry> prices = [SELECT Id,ProductCode FROM PriceBookEntry ];
    	Map<String,PriceBookEntry> priceBookEntryMap = new Map<String,PriceBookEntry>();
        for(PriceBookEntry pb: prices){
            priceBookEntryMap.put(pb.ProductCode,pb);
        } 
        OrderItem newOrderProduct = new OrderItem();
        newOrderProduct.OrderId = orderId;
        newOrderProduct.product2Id = prodId;
        newOrderProduct.quantity = quantity;
        newOrderProduct.unitPrice = cost;
        newOrderProduct.description = description;
        newOrderProduct.priceBookEntryId = priceBookEntryMap.get(prodCode).Id;
        newOrderProduct.Opp_Product_Id__c = opProdId;
        newOrderProduct.family__c = family;
        return newOrderProduct;
    }
    
    public static List<Job__c> deliverableCreationHandler(String productCode,Id orderId, Id oppId){
        Map<string,RecordType> recordTypeMap = new Map<string,RecordType>();   
        List<RecordType> recordTypes = [SELECT Id,Name,SobjectType FROM RecordType];
        for(RecordType rt: recordTypes){
            recordTypeMap.put(rt.SobjectType+rt.Name,rt);
        }
        List<Job__c> newDels = new List<Job__c>(); 
        String recordTypeName = null; 
        Set<String> keySet = recordTypeMap.keyset();
        List<String> keyList = new List<String>(keySet);
         
        Integer index = 0;
        for(String key : keyList){
            if(key.contains('Job__c') && key.contains(productCode)){
                recordTypeName = key;
            }
            index++;  
        }
        
        if(recordTypeName != null){   
            newDels.add(returnDeliverable(productCode,orderId,recordTypeMap.get(recordTypeName).id,oppId));
        }
        return new List<Job__c>();   
    } 
    
    public static Job__c returnDeliverable(String name, Id orderId, String recTypeId, Id oppId){        
        Job__c newDel = new Job__c();
        newDel.recordTypeId = recTypeId;
        newDel.order__c = orderId;
        newDel.name = name;  
        newDel.Opportunities__c = oppId; 
        return newDel;
    }
    
    /*******************************************************************
    @description wrapper class to hold parameters from the flow
    @author Lynn Mejos
    @date 28/03/2023
    ********************************************************************/
    public class Requests {
        @InvocableVariable(label='Opportunity Line Items' description='List of Opportunity Line Item' required=true)
        public List<OpportunityLineItem> oppProducts;
        @InvocableVariable(label='Order' description='Newly created Order' required=true)
        public Order newOrder;
        @InvocableVariable(label='Opportunity' description='Won Opportunity' required=true)
        public Opportunity wonOpportunity;
    }
    
    /*******************************************************************
    @description wrapper class to hold results to be returned to the flow
    @author Lynn Mejos
    @date 13/03/2023
    ********************************************************************/
    public class Results {
        @InvocableVariable(label='Records for Output' description='yourDescription' required=true)
        public List<OrderItem> newOrderProducts;
        @InvocableVariable(label='Records for Output' description='yourDescription' required=true)
        public List<Job__c> newDeliverables;
    }

}