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
  ```


# Backend System

The backend system serves as the intermediary between Salesforce and the external lending system, handling real-time data synchronization, including insertions, updates, and deletions of loan records.

### Overview

The backend is implemented in PHP and interacts with a MySQL database to store operation logs and manage the data flow between Salesforce and the external lending system. It provides endpoints for Salesforce to call for each operation type and records each transaction in the database for audit and reconciliation purposes.

### Directory Structure

The backend code is organized in the `backend` folder within the repository, containing the following files:

- `create_loan.php`: Handles the insertion of new loan records.
- `update_loan.php`: Manages updates to existing loan records.
- `delete_loan.php`: Takes care of deleting loan records.
- `operations.sql`: Contains the SQL script to create the `operations` table in your MySQL database.

### Database Setup

To set up the database, run the `operations.sql` script in your MySQL environment. 

### API Endpoints

The backend system provides the following API endpoints:
 - Create Loan: POST /create_loan.php
 - Update Loan: PUT /update_loan.php
 - Delete Loan: DELETE /delete_loan.php

Each endpoint expects a JSON payload with the necessary information to process the loan operation. Please refer to the specific PHP file for details on the expected payload structure.

### Configuration

Ensure the database connection details in each PHP file are updated to match your MySQL database configuration.


### Deployment

Deploy the backend system to a PHP-supported server environment and ensure it's accessible from your Salesforce Org for outbound HTTP requests. Update the Named Credentials in Salesforce to point to the URL where the backend system is hosted.
