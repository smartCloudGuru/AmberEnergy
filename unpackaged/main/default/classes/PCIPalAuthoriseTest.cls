@IsTest
public class PCIPalAuthoriseTest {
    
    @IsTest
    static void testGetOAuthTokenSuccess() {
        // Setup test data for input variables
        PCIPalAuthorise.inputVariables inputVar = new PCIPalAuthorise.inputVariables();
        inputVar.TOKEN_URL = 'https://example.com/token';
        inputVar.CLIENT_ID = 'testClientId';
        inputVar.CLIENT_SECRET = 'testClientSecret';
        inputVar.GRANT_TYPE = 'client_credentials';
        inputVar.TENANT_NAME = 'testTenant';
        
        List<PCIPalAuthorise.inputVariables> inputVars = new List<PCIPalAuthorise.inputVariables>{inputVar};
        
        // Create a mock response for successful token retrieval
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"access_token": "testAccessToken", "refresh_token": "testRefreshToken"}');
        
        MockHttpResponseGenerator mockGen = new MockHttpResponseGenerator(mockResponse);
        
        // Configure the mock response for the HTTP callout
        Test.setMock(HttpCalloutMock.class, mockGen);
        
        // Call the method and assert results
        List<PCIPalAuthorise.outputVariables> result = PCIPalAuthorise.getOAuthToken(inputVars);
        
        // Assertions to verify access and refresh tokens
        System.assertEquals(1, result.size(), 'There should be one output variable set');
        System.assertEquals('testAccessToken', result[0].access_token, 'Access token should match');
        System.assertEquals('testRefreshToken', result[0].refresh_token, 'Refresh token should match');
    }
   
    @IsTest
    static void testGetOAuthTokenFailure() {
        // Setup test data for input variables
        PCIPalAuthorise.inputVariables inputVar = new PCIPalAuthorise.inputVariables();
        inputVar.TOKEN_URL = 'https://example.com/token';
        inputVar.CLIENT_ID = 'testClientId';
        inputVar.CLIENT_SECRET = 'testClientSecret';
        inputVar.GRANT_TYPE = 'client_credentials';
        inputVar.TENANT_NAME = 'testTenant';
        
        List<PCIPalAuthorise.inputVariables> inputVars = new List<PCIPalAuthorise.inputVariables>{inputVar};
        
        // Create a mock response for an error
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(400);
        mockResponse.setBody('{"error": "invalid_request"}');
        
        // Configure the mock response for the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        // Call the method and assert results
        List<PCIPalAuthorise.outputVariables> result = PCIPalAuthorise.getOAuthToken(inputVars);
        
        // Assertions to verify that tokens are not set when there's an error
        System.assertEquals(1, result.size(), 'There should be one output variable set');
        System.assertEquals(result[0].access_token,null, 'Access token should be null');
        System.assertEquals(result[0].refresh_token,null, 'Refresh token should be null');
    }
    
   @IsTest
    static void testGetOAuthTokenException() {
        // Setup test data for input variables
        PCIPalAuthorise.inputVariables inputVar = new PCIPalAuthorise.inputVariables();
        inputVar.TOKEN_URL = 'https://example.com/token';
        inputVar.CLIENT_ID = 'testClientId';
        inputVar.CLIENT_SECRET = 'testClientSecret';
        inputVar.GRANT_TYPE = 'client_credentials';
        inputVar.TENANT_NAME = 'testTenant';
        
        List<PCIPalAuthorise.inputVariables> inputVars = new List<PCIPalAuthorise.inputVariables>{inputVar};
        
        // Create a mock response that will throw an exception
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(500);
        mockResponse.setBody('{"error": "Internal Server Error"}');
        
        // Create a mock that simulates a callout exception
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        // Call the method and assert results
        List<PCIPalAuthorise.outputVariables> result = PCIPalAuthorise.getOAuthToken(inputVars);
        
        // Assertions to verify that tokens are not set when there's an exception
        System.assertEquals(1, result.size(), 'There should be one output variable set');
        System.assertEquals(result[0].access_token,null, 'Access token should be null');
        System.assertEquals(result[0].refresh_token,null, 'Refresh token should be null');
    }
     
    // Mock HTTP Callout Classes
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse response;
        
        public MockHttpResponseGenerator(HttpResponse response) {
            this.response = response;
        }
        
        public HttpResponse respond(HttpRequest req) {
            return response;
        }
    }
    
    
}