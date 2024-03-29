public class BackendTransactionLogger {
    public static void logTransaction(String operation, String statusCode, String message, String loanName) {
        String status = statusCode == '200' ? 'Succeeded' : 'Failed';

        BackendTransaction__c log = new BackendTransaction__c(
            Operation__c = operation,
            Status__c = status,
            StatusCode__c = statusCode,
            Message__c = message,
            Loan_Name__c = loanName
        );
        insert log;
    }
}
