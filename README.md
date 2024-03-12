# Salesforce Lending System Integration

This project enables real-time synchronization between Salesforce and an external lending system, designed primarily for financial institutions managing loan processes. This integration ensures seamless updates and tracking of loan statuses within Salesforce, streamlining loan management workflows.

## Features

- **Real-time Synchronization**: Ensures Salesforce records are automatically updated to reflect changes from the external lending system.
- **Error Handling**: Implements robust error handling and logging for reliable data synchronization.
- **Secure API Integration**: Utilizes Salesforce Named Credentials for secure communication with the external system.
- **Comprehensive Testing**: Includes extensive Apex tests to ensure code reliability and maintain high coverage.

## Prerequisites

Before you begin, ensure you have the following:

- A Salesforce Org (Developer, Sandbox, or Production).
- Access and credentials for the external lending system's API.
- Appropriate permissions in Salesforce to manage Named Credentials, create and modify Apex classes, and triggers.

## Installation

1. Clone this repository to your local machine:
   ```bash
   git clone https://github.com/cmanriqueb/salesforce-lending-integration.git

2. Deploy the source code to your Salesforce Org using the Salesforce CLI:
   ```bash
   sfdx force:source:deploy -p force-app -u yourOrgAlias

3. Configure Named Credentials in Salesforce to connect securely to the external lending system:
   - Navigate to Setup > Security > Named Credentials.
   - Create a new Named Credential with the API details of the external lending system.
  
## Usage

Follow these steps to utilize the integration:

- Go to the Loans tab in Salesforce and create a new Loan__c record.
- Fill out the necessary fields and save the record to initiate synchronization with the external lending system.
- Check back on the saved Loan__c record to see updated information reflecting the external system's response.

## Troubleshooting
  - Check the Named Credentials settings if there are issues with API connectivity (It should be named LendingSystem).
  - Activate and review Apex debug logs for errors related to synchronization processes.

## Testing

To run the Apex tests, use the following Salesforce CLI command:
  ```bash
  sfdx apex:run:test -u yourOrgAlias -r human -c -l RunLocalTests

