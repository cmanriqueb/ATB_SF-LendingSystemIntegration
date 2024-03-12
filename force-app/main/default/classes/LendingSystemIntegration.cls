public class LendingSystemIntegration {
    private static final String INSERT_OPERATION = 'I';
    private static final String UPDATE_OPERATION = 'U';
    private static final String DELETE_OPERATION = 'D';
    
    // Method to INSERT a new loan
    @future (callout=true)
    public static void createLoan(Set<Id> loanRecordIds) {
        List<Loan__c> loansToCreate = [SELECT Id, Name, Amount__c FROM Loan__c WHERE Id IN :loanRecordIds];

        List<Loan__c> createdLoans = new List<Loan__c>();
        for (Loan__c loan : loansToCreate) {

            String requestBody = JSON.serialize(
                new Map<String, Object>{
                    'operation' => INSERT_OPERATION,
                    'accountNumber' => loan.Name,
                    'amount' => loan.Amount__c
                }
            );
            
            // Create HTTP request for Loan backend insertion operation
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:LendingSystem/loan.php'); // Using NamedCredential named 'LendingSystem'
            req.setMethod('POST'); // The external system uses POST for insertions
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
                    createdLoans.add(loan);
                }
            } else {
                System.debug(LoggingLevel.ERROR, 'Error response from backend: StatusCode=' + res.getStatusCode() + '; Body=' + res.getBody());
            }
            // Log the transaction
            BackendTransactionLogger.logTransaction(INSERT_OPERATION, String.valueOf(res.getStatusCode()), res.getBody(),  'loan-'+loan.Name);
        }
        
        if (!createdLoans.isEmpty()) {
            update createdLoans; // Perform bulk update
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
                        'operation' => UPDATE_OPERATION,
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
                // Log the transaction
                BackendTransactionLogger.logTransaction(UPDATE_OPERATION, String.valueOf(res.getStatusCode()), res.getBody(), 'loan-'+loan.Name);
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
                req.setMethod('DELETE'); // The external system uses DELETE for deletions
                req.setHeader('Content-Type', 'application/json');
                
                // Construct the JSON payload
                Map<String, Object> payload = new Map<String, Object>{
                    'operation' => DELETE_OPERATION,
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
                    System.debug(LoggingLevel.ERROR, 'Error deleting Loan || Error response from backend : StatusCode=' + res.getStatusCode() + '; Body=' + res.getBody());
                } else{
                    System.debug(LoggingLevel.INFO, 'Successfully synced deletion event in the external system for Loan: ' + loan);
                }
                // Log the transaction
                BackendTransactionLogger.logTransaction(DELETE_OPERATION, String.valueOf(res.getStatusCode()), res.getBody(), loan);
            }
        }
    } 
}
