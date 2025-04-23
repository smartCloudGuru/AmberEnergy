/**
 * PCIPalSession class is responsible for interacting with the PCI Pal API to initiate a payment session and retrieve a session URL.
 * 
 * The method takes a list of input parameters, formats them as required by the API, and makes an HTTP POST request to generate a session.
 * 
 * 
 * If the request is successful, it returns the session URL; otherwise, it logs an error.
 * 
 * Amber Energy 2024
 * 
 * 	There are three use cases:
 * 
 * 	1) Request Interactive Voice Session (this returns a session url only -triggered by the type of flow)
 *  2) Request Interactive Digital Session (this returns a session url only - triggered by the type of flow)
 * 	3) Request Non-Interactive Digital Session (this returns a digital link only - triggered by the type of OAuth token)
 */


public class PCIPalSession {
   
    /**
     * Invocable method that retrieves the session URL from the PCI Pal API for a given payment session.
     * 
     * @param inputVariables List of input parameters, including amount, access token, API URL, etc.
     * @return List<String> containing the session URL if the request is successful, or an empty list otherwise.
     */
    
    @InvocableMethod
    public static List<outputVariables> getSessionUrl(List<inputVariables> inputVariables) {
 		
		// Prepare amount as integer value for API (expecting no decimals)
		Decimal originalAmount = inputVariables.get(0).amount;

		// Multiply by 100 and round to the nearest integer to avoid scale issues
		Integer amount = (originalAmount * 100).setScale(0, RoundingMode.HALF_UP).intValue();
	        
        // Holds the result of token retrievals for each set of input parameters
        List<outputVariables> results = new List<outputVariables>();

        // Check if access token is available
        if (inputVariables.get(0).access_token != null) {
            
            outputVariables outputVar = new outputVariables();
                    
            HttpRequest req = new HttpRequest();
            req.setEndpoint(inputVariables.get(0).api_url);
            
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + inputVariables.get(0).access_token);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Cache-Control', 'no-cache');
            
            
            // Prepare JSON payload
            Map<String, Object> jsonPayload = new Map<String, Object>();
            Integer flowId = Integer.valueOf(inputVariables.get(0).flow_id);
			jsonPayload.put('flow_Id', flowId);

            Map<String, Object> transactionDetails = new Map<String, Object>();
            String reference = inputVariables.get(0).reference.replace('-', ' ').replaceAll('\\s', '');
            transactionDetails.put('reference', reference);
            transactionDetails.put('amount', amount);

            
            // Add "additional_fields" array to transaction details
			List<Map<String, Object>> additionalFields = new List<Map<String, Object>>();

			Map<String, Object> additionalField1 = new Map<String, Object>();
			additionalField1.put('display_name', 'payment_source');
			additionalField1.put('value', 'PCIPal');
			additionalFields.add(additionalField1);

			transactionDetails.put('additional_fields', additionalFields);

			// Add transaction details to payload
			jsonPayload.put('transaction_details', transactionDetails);

            // Set consumer details
            Map<String, Object> consumerDetails = new Map<String, Object>();
            consumerDetails.put('first_name', inputVariables.get(0).first_Name);
            consumerDetails.put('last_name', inputVariables.get(0).last_Name);
            consumerDetails.put('email_address', inputVariables.get(0).eMail_Address);
            
            Map<String, String> phoneNumber = new Map<String, String>();
            phoneNumber.put('country_code', '+44');
            phoneNumber.put('number', inputVariables.get(0).phone_number);
            consumerDetails.put('phone_number', phoneNumber);

            // Set address details if available
            Map<String, Object> address = new Map<String, Object>();
            address.put('address_line1', inputVariables.get(0).address_Line_1);
            address.put('address_line2', inputVariables.get(0).address_Line_2);
            address.put('town_or_city', inputVariables.get(0).address_city);
            address.put('state_or_county', inputVariables.get(0).address_county);
            address.put('postcode', inputVariables.get(0).address_postcode);
            consumerDetails.put('address', address);

            jsonPayload.put('consumer_details', consumerDetails);

            // Serialize JSON payload and set to request body
            String jsonBody = JSON.serialize(jsonPayload);
            req.setBody(jsonBody);

            Http http = new Http();
            HttpResponse res;
            try {
                // Send HTTP request
                res = http.send(req);
                if (res.getStatusCode() == 200) {
                    // Parse response for session_id if successful
                    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    
                    
                    String sessionId = (String) responseMap.get('session_id');
					String url = ''; // Initialize url to an empty string

					if (sessionId != null) {
    					// Construct and add session URL to result if sessionId is set
    					url = inputVariables.get(0).session_url +'/'+ inputVariables.get(0).tenant_id + '/view/' + sessionId + '/framed';
					}
                    
                    outputVar.sessionURL = (String) url;
  					outputVar.digitalLink = responseMap.containsKey('digital_link') ? (String)responseMap.get('digital_link') : '';
                         
         			// Add the populated or empty outputVariables object to results list
            		results.add(outputVar);
                    
                } else {
                    // Set the sessionURL to indicate an error with status code
                    outputVar.sessionURL = 'Error: HTTP request failed with status ' + res.getStatusCode() + ' - ' + res.getBody();
                    results.add(outputVar);
                }
            } catch (Exception e) {
                // Set the sessionURL to indicate an exception
                outputVar.sessionURL = 'Exception: ' + e.getTypeName() + ' - ' + e.getMessage();
                results.add(outputVar);
                logException(e);
            }
        } else {
            outputVariables outputVar = new outputVariables();
            outputVar.sessionURL = 'Error: Could not obtain OAuth token';
            results.add(outputVar);
        }
        // Return list of access and refresh tokens (or empty if request failed)
        return results;
    }

    /**
     * Logs exceptions encountered during the HTTP request or JSON processing.
     *
     * @param e - Exception encountered during request processing
     */
    private static void logException(Exception e) {
        System.debug('Exception: ' + e.getTypeName() + ' - ' + e.getMessage());
        System.debug('Stack Trace: ' + e.getStackTraceString());
    }
    
    /**
     * Inner class representing the input variables for the PCI Pal API.
     */
    public class inputVariables {
        @InvocableVariable(required=true)
        public String reference;
        
        @InvocableVariable(required=true)
        public String first_Name;
        
        @InvocableVariable(required=true)
        public String last_Name;
        
        @InvocableVariable(required=true)
        public String eMail_Address;

        @InvocableVariable(required=true)
        public String phone_number;

        @InvocableVariable(required=false)
        public String address_Line_1;

        @InvocableVariable(required=false)
        public String address_Line_2;

        @InvocableVariable(required=false)
        public String address_city;

        @InvocableVariable(required=false)
        public String address_county;

        @InvocableVariable(required=false)
        public String address_postcode;

        @InvocableVariable(required=true)
        public Decimal amount;
        
        @InvocableVariable(required=true)
        public String access_token;
        
        @InvocableVariable(required=true)
        public String api_url;
        
        @InvocableVariable(required=true)
        public String session_url;
        
        @InvocableVariable(required=true)
        public String tenant_id;
        
        @InvocableVariable(required=true)
        public String flow_id;
    }
    
     public class outputVariables {
        @InvocableVariable(required=false)
        public String sessionURL;
        
        @InvocableVariable(required=false)
        public String digitalLink;
     }
}