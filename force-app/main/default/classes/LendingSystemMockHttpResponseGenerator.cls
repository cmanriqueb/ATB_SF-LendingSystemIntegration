@isTest
public class LendingSystemMockHttpResponseGenerator implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
    
        // Adjust logic to match the consolidated loan.php endpoint
        if (req.getBody().contains('"operation":"I"')) {
            // Mock response for creation
            res.setBody('{"loanId": "loan-123456789"}');
            res.setStatusCode(200);
        } else if (req.getBody().contains('"operation":"U"')) {
            // Mock response for update
            res.setBody('{"status": "updated", "loanId": "loan-123456789"}');
            res.setStatusCode(200);
        } else if (req.getBody().contains('"operation":"D"')) {
            // Mock response for deletion
            res.setBody('{"status": "deleted", "loanId": "loan-123456789"}');
            res.setStatusCode(200);
        } else {
            // Fallback error response
            res.setBody('{"error": "Unknown request"}');
            res.setStatusCode(400);
        }
    
        return res;
    }
}
