public class LendingSystemIntegration {

    // Method to INSERT a new loan
    @future (callout=true)
    public static void createLoan(Set<Id> loanRecordIds) {
        List<Loan__c> loansToUpdate = [SELECT Id, Name, Amount__c, LoanId__c FROM Loan__c WHERE Id IN :loanRecordIds];

        List<Loan__c> updatedLoans = new List<Loan__c>();
        for (Loan__c loan : loansToUpdate) {

            String requestBody = JSON.serialize(
                new Map<String, Object>{
                    'operation' => 'I',
                    'accountNumber' => loan.Name,
                    'amount' => loan.Amount__c
                }
            );
            
            // Create HTTP request for insertion
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:LendingSystem/loan.php'); // Using NamedCredential named 'LendingSystem'
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(requestBody);

            // Send the request
            System.debug(LoggingLevel.INFO, 'Making CREATE callout with body: ' + requestBody);
            Http http = new Http();
            HTTPResponse res = http.send(req);

            // If successful, update the Salesforce record with the external system's Loan ID
            if (res.getStatusCode() == 200) {
                Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                String externalLoanId = (String) responseData.get('loanId');
                if (externalLoanId != null) {
                    loan.LoanId__c = externalLoanId;
                    updatedLoans.add(loan);
                }
            } else {
                System.debug(LoggingLevel.ERROR, 'Error response from backend: StatusCode=' + res.getStatusCode() + '; Body=' + res.getBody());
            }
        }
        
        if (!updatedLoans.isEmpty()) {
            update updatedLoans; // Perform bulk update
        }
    }

    // Method to UPDATE an existing loan
    @future (callout=true)
    public static void updateLoan(Set<Id> loanRecordIds) {
        List<Loan__c> loansToUpdate = [SELECT Id, Name, Amount__c, LoanId__c FROM Loan__c WHERE Id IN :loanRecordIds];
    
        for (Loan__c loan : loansToUpdate) {
            if (String.isNotBlank(loan.LoanId__c)) { // Only proceed if there's an external Loan ID
                // Construct the payload
                String requestBody = JSON.serialize(
                    new Map<String, Object>{
                        'operation' => 'U',
                        'loanId' => loan.LoanId__c, // Use the external Loan ID
                        'amount' => loan.Amount__c
                    }
                );
    
                // Create HTTP request for update
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:LendingSystem/loan.php'); // Using NamedCredential named 'LendingSystem'
                req.setMethod('PUT'); // The external system uses PUT for updates
                req.setHeader('Content-Type', 'application/json');
                req.setBody(requestBody);
    
                // Send the request
                System.debug(LoggingLevel.INFO, 'Making UPDATE callout with body: ' + requestBody);
                Http http = new Http();
                HTTPResponse res = http.send(req);
    
                // Log the response for debugging; actual update logic in external system might vary
                if (res.getStatusCode() != 200) {
                    System.debug(LoggingLevel.ERROR, 'Error response from backend: StatusCode=' + res.getStatusCode() + '; Body=' + res.getBody());
                }
            }
        }
    }
    

    // Method to DELETE an existing loan
    @future (callout=true)
    public static void deleteLoan(Set<String> loansToDelete) {
        
        for (String loan : loansToDelete) {
            if (loan!=null) { // Proceed only if there's an external Loan ID
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:LendingSystem/loan.php');
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                
                // Construct the JSON payload
                Map<String, Object> payload = new Map<String, Object>{
                    'operation' => 'D',
                    'loanId' => loan
                };
                req.setBody(JSON.serialize(payload));
    
                // Log the endpoint for debugging
                System.debug(LoggingLevel.INFO, 'Making DELETE callout with body: ' + JSON.serialize(payload));
    
                // Send the request
                Http http = new Http();
                HTTPResponse res = http.send(req);
    
                // Log the response for debugging
                if (res.getStatusCode() != 200) {
                    System.debug(LoggingLevel.ERROR, 'Error deleting Loan in external system: StatusCode=' + res.getStatusCode() + '; Body=' + res.getBody());
                } else{
                    System.debug(LoggingLevel.INFO, 'Successfully reflected deletion in the external system for Loan: ' + loan);
                }
            }
        }
    }
    

}
