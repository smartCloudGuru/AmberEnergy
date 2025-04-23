@isTest
public class PCIPalSessionTest {
    
    @isTest
    static void testGetSessionUrlSuccess() {
        // Mock HTTP response for a successful case
        Test.setMock(HttpCalloutMock.class, new PCIPalSessionMockSuccess());

        // Prepare input data
        PCIPalSession.inputVariables input = new PCIPalSession.inputVariables();
        input.reference = 'TestReference-123';
        input.first_Name = 'John';
        input.last_Name = 'Doe';
        input.eMail_Address = 'john.doe@example.com';
        input.phone_number = '1234567890';
        input.address_Line_1 = '123 Main St';
        input.address_Line_2 = 'Apt 4B';
        input.address_city = 'Anytown';
        input.address_county = 'Anycounty';
        input.address_postcode = '12345';
        input.amount = 100.00;
        input.access_token = 'MockAccessToken';
        input.api_url = 'https://mock-api-url.com';
        input.session_url = 'https://mock-session-url.com';
        input.tenant_id = 'mockTenantId';
        input.flow_id = '1';
        
        List<PCIPalSession.inputVariables> inputs = new List<PCIPalSession.inputVariables>{ input };

        // Invoke the method
        List<PCIPalSession.outputVariables> outputs = PCIPalSession.getSessionUrl(inputs);

        // Assert the result
        System.assertEquals(1, outputs.size(), 'Expected one output record');
        System.assertNotEquals(outputs[0].sessionURL,null, 'Session URL should not be null');
        System.assertEquals('https://mock-session-url.com/mockTenantId/view/mockSessionId/framed', outputs[0].sessionURL);
    }

    @isTest
    static void testGetSessionUrlErrorHandling() {
        // Mock HTTP response for an error case
        Test.setMock(HttpCalloutMock.class, new PCIPalSessionMockError());

        // Prepare input data
        PCIPalSession.inputVariables input = new PCIPalSession.inputVariables();
        input.reference = 'TestReference-123';
        input.first_Name = 'Jane';
        input.last_Name = 'Doe';
        input.eMail_Address = 'jane.doe@example.com';
        input.phone_number = '9876543210';
        input.amount = 50.00;
        input.access_token = 'MockAccessToken';
        input.api_url = 'https://mock-api-url.com';
        input.session_url = 'https://mock-session-url.com';
        input.tenant_id = 'mockTenantId';
        input.flow_id = '2';
        
        List<PCIPalSession.inputVariables> inputs = new List<PCIPalSession.inputVariables>{ input };

        // Invoke the method
        List<PCIPalSession.outputVariables> outputs = PCIPalSession.getSessionUrl(inputs);

        // Assert the result
    	System.assertEquals(1, outputs.size(), 'Expected one output record for an error response');
    	System.assertNotEquals(null, outputs[0].sessionURL, 'Session URL should not be null in case of an error');
    	System.assert(outputs[0].sessionURL.startsWith('Error:'), 'Session URL should indicate an error');
    }


// Mock for successful HTTP response
public class PCIPalSessionMockSuccess implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('{"session_id": "mockSessionId"}');
        return res;
    }
}

// Mock for error HTTP response
public class PCIPalSessionMockError implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(400);
        res.setBody('{"error": "Invalid request"}');
        return res;
    }
}
    
}