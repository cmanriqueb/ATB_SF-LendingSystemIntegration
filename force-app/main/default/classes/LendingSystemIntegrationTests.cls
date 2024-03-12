@isTest
private class LendingSystemIntegrationTests {

    @isTest static void testCreateLoanSuccess() {
        // Ensure we're starting with default settings
        LendingSystemMockHttpResponseGenerator.reset();
        // Set up for a successful response
        LendingSystemMockHttpResponseGenerator.shouldSucceed = true;
        LendingSystemMockHttpResponseGenerator.operation = 'I'; // 'I' for Insert/Create
        
        // Set up test data
        Loan__c testLoan = new Loan__c(Name='123456789', Amount__c=1000);
        insert testLoan;

        // Set up mock callout response
        Test.setMock(HttpCalloutMock.class, new LendingSystemMockHttpResponseGenerator());

        // Start test context
        Test.startTest();
        
        // Call the method to test
        Set<Id> loanIds = new Set<Id>{testLoan.Id};
        LendingSystemIntegration.createLoan(loanIds);
        
        // Stop test context
        Test.stopTest();
        
        // Verify the results
        testLoan = [SELECT LoanId__c FROM Loan__c WHERE Id = :testLoan.Id];
        System.assertNotEquals(null, testLoan.LoanId__c, 'Loan should have an external ID after successful creation');
    }

    @isTest static void testCreateLoanFailure() {
        // Reset to default settings and configure for a failure scenario
        LendingSystemMockHttpResponseGenerator.reset();
        LendingSystemMockHttpResponseGenerator.shouldSucceed = false; // Simulate failure
        LendingSystemMockHttpResponseGenerator.operation = 'I'; // 'I' for Insert/Create
        LendingSystemMockHttpResponseGenerator.statusCodeOverride = 400; // Error status code
        
        // Set up test data
        Loan__c testLoan = new Loan__c(Name='987654321', Amount__c=500); // Assume the loan does not have an external ID
        insert testLoan;

        // Set up mock callout response
        Test.setMock(HttpCalloutMock.class, new LendingSystemMockHttpResponseGenerator());

        // Start test context
        Test.startTest();
        
        // Attempt to create the loan, which should fail in this case
        Set<Id> loanIds = new Set<Id>{testLoan.Id};
        LendingSystemIntegration.createLoan(loanIds);
        
        // Stop test context
        Test.stopTest();
        
        // Verify the results - expecting no external ID due to failure
        testLoan = [SELECT LoanId__c FROM Loan__c WHERE Id = :testLoan.Id];
        System.assertEquals(null, testLoan.LoanId__c, 'Loan should not have an external ID after failed creation');
    }

    @isTest static void testUpdateLoanSuccess() {
        // Ensure we're starting with default settings
        LendingSystemMockHttpResponseGenerator.reset();
        // Set up for a successful response
        LendingSystemMockHttpResponseGenerator.shouldSucceed = true;
        LendingSystemMockHttpResponseGenerator.operation = 'U'; // 'U' for Update
    
        // Set up test data - assume the loan already exists and has an external ID
        Loan__c testLoan = new Loan__c(Name='123456789', Amount__c=1000, LoanId__c='loan-123456789');
        insert testLoan;
    
        // Modify test data for update
        testLoan.Amount__c = 1500; // Change the amount to simulate an update
        update testLoan; // Important to update the record in Salesforce before calling the update method
    
        // Set up mock callout response
        Test.setMock(HttpCalloutMock.class, new LendingSystemMockHttpResponseGenerator());
    
        // Start test context
        Test.startTest();
    
        // Call the method to test
        Set<Id> loanIds = new Set<Id>{testLoan.Id};
        LendingSystemIntegration.updateLoan(loanIds);
    
        // Stop test context
        Test.stopTest();
    
        // Verify the results - expecting the external ID to remain the same but verifying update was "successful"
        testLoan = [SELECT LoanId__c FROM Loan__c WHERE Id = :testLoan.Id];
        System.assertEquals('loan-123456789', testLoan.LoanId__c, 'Loan should retain the same external ID after successful update');
    }
    
    @isTest static void testUpdateLoanFailure() {
        // Reset to default settings and configure for a failure scenario
        LendingSystemMockHttpResponseGenerator.reset();
        LendingSystemMockHttpResponseGenerator.shouldSucceed = false; // Simulate failure
        LendingSystemMockHttpResponseGenerator.operation = 'U'; // 'U' for Update
        LendingSystemMockHttpResponseGenerator.statusCodeOverride = 404; // Error status code for update failure
    
        // Set up test data - assume the loan already exists and has an external ID
        Loan__c testLoan = new Loan__c(Name='987654321', Amount__c=1500, LoanId__c='loan-123456789');
        insert testLoan;
    
        // Modify test data for update
        testLoan.Amount__c = 2000; // Change the amount to simulate an update
        update testLoan; // Important to update the record in Salesforce before calling the update method
    
        // Set up mock callout response
        Test.setMock(HttpCalloutMock.class, new LendingSystemMockHttpResponseGenerator());
    
        // Start test context
        Test.startTest();
    
        // Attempt to update the loan, which should fail in this case
        Set<Id> loanIds = new Set<Id>{testLoan.Id};
        LendingSystemIntegration.updateLoan(loanIds);
    
        // Stop test context
        Test.stopTest();
    
        // Verify the results - expecting no changes in external ID and update to be "failed"
        testLoan = [SELECT LoanId__c FROM Loan__c WHERE Id = :testLoan.Id];
        System.assertEquals('loan-123456789', testLoan.LoanId__c, 'Loan should retain its original external ID after failed update');
    }

    @isTest static void testDeleteLoanSuccess() {
        // Ensure we're starting with default settings
        LendingSystemMockHttpResponseGenerator.reset();
        // Set up for a successful response
        LendingSystemMockHttpResponseGenerator.shouldSucceed = true;
        LendingSystemMockHttpResponseGenerator.operation = 'D'; // 'D' for Delete
        
        // Set up test data - assume the loan already exists and has an external ID
        Loan__c testLoan = new Loan__c(Name='123456789', Amount__c=1000, LoanId__c='loan-123456789');
        insert testLoan;
    
        // Prepare loan ID for deletion
        Set<String> loanIdsForDeletion = new Set<String>{testLoan.LoanId__c};
    
        // Set up mock callout response
        Test.setMock(HttpCalloutMock.class, new LendingSystemMockHttpResponseGenerator());
    
        // Start test context
        Test.startTest();
    
        // Call the method to test
        LendingSystemIntegration.deleteLoan(loanIdsForDeletion);
    
        // Stop test context
        Test.stopTest();
    
        // Verify the results - expecting the Loan__c record to be unchanged in Salesforce since it's a mock callout
        Loan__c deletedLoan = [SELECT LoanId__c FROM Loan__c WHERE Id = :testLoan.Id];
        System.assertEquals('loan-123456789', deletedLoan.LoanId__c, 'Loan should retain its external ID after successful mock delete');
    }
    
    @isTest static void testDeleteLoanFailure() {
        // Reset to default settings and configure for a failure scenario
        LendingSystemMockHttpResponseGenerator.reset();
        LendingSystemMockHttpResponseGenerator.shouldSucceed = false; // Simulate failure
        LendingSystemMockHttpResponseGenerator.operation = 'D'; // 'D' for Delete
        LendingSystemMockHttpResponseGenerator.statusCodeOverride = 404; // Error status code for delete failure
        
        // Set up test data - assume the loan already exists and has an external ID
        Loan__c testLoan = new Loan__c(Name='987654321', Amount__c=1000, LoanId__c='loan-987654321');
        insert testLoan;
    
        // Prepare loan ID for deletion
        Set<String> loanIdsForDeletion = new Set<String>{testLoan.LoanId__c};
    
        // Set up mock callout response
        Test.setMock(HttpCalloutMock.class, new LendingSystemMockHttpResponseGenerator());
    
        // Start test context
        Test.startTest();
    
        // Attempt to delete the loan, which should fail in this case
        LendingSystemIntegration.deleteLoan(loanIdsForDeletion);
    
        // Stop test context
        Test.stopTest();
    
        // Verify the results - expecting the Loan__c record to be unchanged in Salesforce since it's a mock callout
        Loan__c failedDeletedLoan = [SELECT LoanId__c FROM Loan__c WHERE Id = :testLoan.Id];
        System.assertEquals('loan-987654321', failedDeletedLoan.LoanId__c, 'Loan should retain its external ID after failed mock delete');
    }
    
}
