@isTest
public class LendingSystemMockHttpResponseGenerator implements HttpCalloutMock {
    public static Boolean shouldSucceed = true;
    public static String operation = 'I'; // Default operation
    public static Integer statusCodeOverride = 200; // Default status code
    public static String loanIdOverride = 'loan-123456789'; // Default loan ID for responses

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        String responseBody;

        // Assuming 'operation' represents the intended action ('I', 'U', 'D')
        Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(req.getBody());
        String requestOperation = (String) requestData.get('operation');
        
        switch on requestOperation {
            when 'I' {
                // Mock response for creation
                responseBody = (shouldSucceed) ? '{"loanId": "' + loanIdOverride + '"}' : '{"error": "Mocked failure"}';
                res.setStatusCode(shouldSucceed ? 200 : statusCodeOverride);
            }
            when 'U' {
                // Mock response for update
                responseBody = (shouldSucceed) ? '{"status": "updated", "loanId": "' + loanIdOverride + '"}' : '{"error": "Mocked failure"}';
                res.setStatusCode(shouldSucceed ? 200 : statusCodeOverride);
            }
            when 'D' {
                // Mock response for deletion
                responseBody = (shouldSucceed) ? '{"status": "deleted", "loanId": "' + loanIdOverride + '"}' : '{"error": "Mocked failure"}';
                res.setStatusCode(shouldSucceed ? 200 : statusCodeOverride);
            }
            when else {
                // Fallback error response
                responseBody = '{"error": "Unknown operation"}';
                res.setStatusCode(400); // Assuming fallback is always an error scenario
            }
        }

        res.setBody(responseBody);
        return res;
    }

    // Reset method to restore defaults (useful between test methods)
    public static void reset() {
        shouldSucceed = true;
        operation = 'I';
        statusCodeOverride = 200;
        loanIdOverride = 'loan-123456789';
    }
}
