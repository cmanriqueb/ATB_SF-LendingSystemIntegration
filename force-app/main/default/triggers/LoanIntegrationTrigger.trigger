trigger LoanIntegrationTrigger on Loan__c (after insert, after update, after delete) {
    Set<Id> loanIdsForCreation = new Set<Id>();
    Set<Id> loanIdsForUpdate = new Set<Id>();
    Set<String> loanIdsForDeletion = new Set<String>();

    if (Trigger.isInsert) {
        for (Loan__c loan : Trigger.new) {
            if (loan.LoanId__c == null) { 
                loanIdsForCreation.add(loan.Id); // New loans needing creation
            }
        }
    } else if (Trigger.isUpdate) {
        for (Loan__c loan : Trigger.new) {
            Loan__c oldLoan = Trigger.oldMap.get(loan.Id);
            if (loan.Amount__c != oldLoan.Amount__c  && String.isNotBlank(loan.LoanId__c)) {
                loanIdsForUpdate.add(loan.Id); // Existing loans needing update
            }
        }
    }else if (Trigger.isDelete) {
        for (Loan__c loan : Trigger.old) {
            if (loan.LoanId__c!=null) { 
                loanIdsForDeletion.add(loan.LoanId__c); // Collecting loan IDs for deletion
            }
        }
        if (!loanIdsForDeletion.isEmpty()) {
            LendingSystemIntegration.deleteLoan(loanIdsForDeletion);
        }
    }

    // Enqueue future executions for each operation
    // NOTE: Currently, the LendingSystemIntegration class utilizes future methods. Be aware that within a single Apex  
    //       transaction, there is a limit of up to 50 future calls. 
    //       Alternatively, for high-volume scenarios or to enhance scalability, transitioning 
    //       to the Queueable Apex interface may be beneficial, as it allows for the chaining of asynchronous 
    //       operations and more sophisticated state management.

    if (!loanIdsForCreation.isEmpty()) {
        LendingSystemIntegration.createLoan(loanIdsForCreation);
    }
    if (!loanIdsForUpdate.isEmpty()) {
        LendingSystemIntegration.updateLoan(loanIdsForUpdate);
    }
    if (!loanIdsForDeletion.isEmpty()) {
        LendingSystemIntegration.deleteLoan(loanIdsForDeletion);
    }
}
