/**
 * PCIPalAuthorise class
 * 
 * This class is designed to interact with the PCI Pal API to obtain OAuth tokens.
 * The primary method, getOAuthToken, is an invocable method that can be called
 * from other processes (e.g., Flows) to get authorization tokens for session management.
 * 
 * The process involves sending an HTTP POST request with client credentials and user details
 * to the specified TOKEN_URL endpoint, receiving the access and refresh tokens as a response.
 * 
 * This class includes:
 * - inputVariables : Storing input parameters from a flow.
 * - outputVariables : Storing output paramaters to a flow. 
 * - Methods to construct the request, handle the response, and log errors.
 * 
 * 	Amber Energy 2024
 * 
 * 	There are two use cases:
 * 
 * 	1) Request a OAuth for Interactive Client ID currently set to (but subject to change) AutoProvisionApplication (Payments)
 *  2) Request a OAuth for Non-Interactive Client ID currently set to (but subject to change): AutoprovisionApplication (Payments-Digital Only)
 * 
 */

public class PCIPalAuthorise {

    /**
     * Invocable method that sends a POST request to the PCI Pal API to retrieve OAuth tokens.
     * It takes a list of input variables (TOKEN_URL, CLIENT_ID, CLIENT_SECRET, GRANT_TYPE, TENANT_NAME)
     * and returns a list of output variables (access_token and refresh_token).
     *
     * @param inputVariables - List of inputVariables objects containing API and user credentials for PCIPal
     * @return List<outputVariables> - List of outputVariables objects containing access and refresh tokens
     */
    @InvocableMethod
    public static List<outputVariables> getOAuthToken(List<inputVariables> inputVariables) {
        // Holds the result of token retrievals for each set of input parameters
        List<outputVariables> results = new List<outputVariables>();

        // Loop through each set of input variables to process requests individually
        for (inputVariables inputVar : inputVariables) {
            outputVariables outputVar = new outputVariables();
            
            System.debug('Request Body: ' + createRequestBody(inputVar));
            
            try {
                // Sends the HTTP request to PCI Pal API and retrieves the response
                HttpResponse res = sendHttpRequest(inputVar);
                
                // Check if the response was successful (HTTP 200)
                if (res.getStatusCode() == 200) {
                    
                    // Parse JSON response to get access and refresh tokens
                    Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    
                    outputVar.access_token = (String) jsonResponse.get('access_token');
                    outputVar.refresh_token = (String) jsonResponse.get('refresh_token');
                    
                } else {
                    
                    // Log error details if the response indicates failure
                    logError(res.getStatusCode(), res.getBody());
                }
                
            } catch (Exception e) {
                
                // Log any exceptions encountered during HTTP request or response parsing
                logException(e);
            }

            // Add the populated or empty outputVariables object to results list
            results.add(outputVar);
        }

        // Return list of access and refresh tokens (or empty if request failed)
        return results;
    }

    /**
     * Helper method to send an HTTP POST request to the PCI Pal API.
     * This method constructs the request and sends it to the API endpoint.
     *
     * @param inputVar - inputVariables object containing API credentials and endpoint details
     * @return HttpResponse - HTTP response from PCI Pal API
     */
    
    private static HttpResponse sendHttpRequest(inputVariables inputVar) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(inputVar.TOKEN_URL);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Cache-Control', 'no-cache');
        
        // Set the request body using API credentials and user information
        req.setBody(createRequestBody(inputVar));

        Http http = new Http();
        return http.send(req);  // Sends the HTTP request and returns the response
    }

    /**
     * Helper method to construct the request body for the PCI Pal API request.
     *
     * @param inputVar - inputVariables object containing required API credentials and grant type
     * @return String - Formatted request body as a URL-encoded string
     */
    
    private static String createRequestBody(inputVariables inputVar) {
        String rawUsername = UserInfo.getUserName(); 
        String formattedUsername = rawUsername.split('@')[0].replace('.', '');
        
        if (inputVar.CLIENT_ID.toLowerCase().contains('digital')) {
           formattedUsername=formattedUsername+'digital';
        } else {
           formattedUsername=formattedUsername+'voice';
        }
        
        
        return 'grant_type=' + inputVar.GRANT_TYPE
            + '&client_id=' + inputVar.CLIENT_ID
            + '&client_secret=' + inputVar.CLIENT_SECRET
            + '&tenantname=' + inputVar.TENANT_NAME
            + '&username=' + formattedUsername;  // Automatically includes the username of the logged-in user
    }

    /**
     * Logs errors encountered during the HTTP request, specifically non-200 status codes.
     *
     * @param statusCode - HTTP status code returned by PCI Pal API
     * @param responseBody - Response body returned by PCI Pal API
     */
    private static void logError(Integer statusCode, String responseBody) {
        System.debug('HTTP request failed. Status Code: ' + statusCode);
        System.debug('Response Body: ' + responseBody);
    }

    /**
     * Logs exceptions for any unexpected errors during the HTTP request or JSON parsing.
     *
     * @param e - Exception object representing the error encountered
     */
    private static void logException(Exception e) {
        System.debug('Exception: ' + e.getTypeName() + ' - ' + e.getMessage());
        System.debug('Stack Trace: ' + e.getStackTraceString());
    }

    // Class to hold input parameters required by the PCI Pal API for token retrieval
    public class inputVariables {
        @InvocableVariable(required=true)
        public String TOKEN_URL;  // PCIPal Endpoint URL for token request
        
        @InvocableVariable(required=true)
        public String CLIENT_ID;  // Client ID for API authentication
        
        @InvocableVariable(required=true)
        public String CLIENT_SECRET;  // Client Secret for API authentication
        
        @InvocableVariable(required=true)
        public String GRANT_TYPE;  // OAuth grant type for token request
        
        @InvocableVariable(required=true)
        public String TENANT_NAME;  // Tenant name specific to the API instance
    }
    
    // Class to hold output tokens received from the PCI Pal API
    public class outputVariables {
        @InvocableVariable
        public String access_token;  // OAuth access token for API access
        
        @InvocableVariable
        public String refresh_token;  // OAuth refresh token for session management
    }
}