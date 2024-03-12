# Salesforce Lending System Integration

This project enables real-time synchronization between Salesforce and an external lending system, designed primarily for financial institutions managing loan processes. This integration ensures seamless updates and tracking of loan statuses within Salesforce, streamlining loan management workflows.

## Features

- **Real-time Synchronization**: Ensures Salesforce records are automatically updated to reflect changes from the external lending system, maintaining up-to-date and accurate information across platforms.
- **Robust Backend Integration**: Seamlessly synchronize Salesforce data with external systems while maintaining high data integrity and real-time tracking, ensuring that your Salesforce environment and the external backend system stay in perfect harmony.
- **Comprehensive Logging Mechanism**: Utilizes the `BackendTransaction__c` custom object for detailed logging of all backend interactions, enabling strong management and visibility of backend events. This facilitates effective monitoring, troubleshooting, and auditability of integration flows.
- **Error Handling**: Implements robust error handling and comprehensive logging for reliable data synchronization. Quickly identify and address issues with dynamic response tracking and clear reporting on the nature and outcome of each operation.
- **Secure API Integration**: Leverages Salesforce Named Credentials for secure and streamlined communication with the external system, ensuring data privacy and integrity.
- **Dynamic Error Handling and Reporting**: Enhances troubleshooting with detailed error messages and status codes, allowing for quick identification and resolution of integration issues.
- **Transparent Operation Tracking**: Provides clear insights into the status of each operation performed between Salesforce and the external backend, enhancing operational awareness and control.
- **Comprehensive Testing**: Includes extensive Apex tests covering a wide range of scenarios to ensure code reliability and maintain high coverage, bolstering the overall robustness of the integration.
- **Scalable Architecture**: Designed to accommodate growing business needs and increasing volumes of backend interactions, ensuring that your integration solution remains reliable and efficient as your organization evolves.


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
  
4. Add validation rules to the Loan__c object
   ### Rule 1: Positive Amount
   - **Rule Name**: Amount_Must_Be_Positive
   - **Description**: Ensures that the loan amount is a positive number greater than zero.
   - **Formula**: `Amount__c <= 0`
   - **Error Message**: "The amount must be greater than zero."
   - **Error Location**: "The Loan Amount must be greater than zero."
    ### Rule 2: LoanName_Digits_Only
   - **Rule Name**: LoanName_Digits_Only
   - **Description**: The Loan Name must only contain numbers and no spaces or special characters. This ensures that the Loan Name field is used consistently and follows a standardized format.
   - **Error Condition Formula**: `NOT(REGEX(Name, "^\\d+$"))`
   - **Error Message**: "The Loan Name must only contain numbers and no spaces or special characters."

  
## Usage

Follow these steps to utilize the integration:

- Go to the Loans tab in Salesforce and create a new Loan__c record.
- Fill out the necessary fields and save the record to initiate synchronization with the external lending system.
- Check the saved Loan__c record to see updated information reflecting the external system's response.

## Troubleshooting
  - Check the Named Credentials settings if there are issues with API connectivity (It should be named LendingSystem).
  - Activate and review Apex debug logs for errors related to synchronization processes.

## Backend Transactions Logging

### Overview

The `BackendTransaction__c` custom object logs all interactions between Salesforce and the external backend system. This logging mechanism helps in monitoring the success or failure of operations such as inserts (`I`), updates (`U`), and deletes (`D`) performed on external systems.

### Fields Description

- **Operation__c**: A picklist field that indicates the type of operation. Possible values include:
  - `I` - Insert
  - `U` - Update
  - `D` - Delete
- **Status__c**: A picklist field representing the outcome of the operation. It can be either:
  - `Succeeded`
  - `Failed`
- **StatusCode__c**: A text field that stores the HTTP status code returned by the external system.
- **Message__c**: A text area that captures any messages or descriptions returned by the external system or generated during the operation.
- **Loan_Name__c**: A text field used to store the name of the loan. This ensures that the reference to the loan's name persists even if the `Loan__c` record is deleted.

### Usage

Each time Salesforce performs an operation that interacts with the external system (such as creating, updating, or deleting loan records), a `BackendTransaction__c` record is created to log the details of this interaction. This includes the operation type, the status and code of the response, and any relevant messages. This setup assists administrators and developers in troubleshooting and provides an audit trail of all external interactions.

### Example of Logging

Upon the successful creation of a loan record in the external system, a `BackendTransaction__c` record might look like this:

- **Operation__c**: `I`
- **Status__c**: `Succeeded`
- **StatusCode__c**: `200`
- **Message__c**: `Loan record created successfully in the external system.`
- **Loan_Name__c**: `Sample Loan Name`

Conversely, if an update operation fails, the corresponding `BackendTransaction__c` record could be:

- **Operation__c**: `U`
- **Status__c**: `Failed`
- **StatusCode__c**: `404`
- **Message__c**: `Loan record not found in the external system.`
- **Loan_Name__c**: `Sample Loan Name`

By maintaining these logs, Salesforce users can gain insights into the data flow between Salesforce and the external backend system and quickly address any issues.


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

- `loan.php`:
   - "operation": "I" --> Inserts a new loan record.
   - "operation": "U" --> Updates an existing loan record.
   - "operation": "D" --> Deletes an existing loan record.
- `operations.sql`: Contains the SQL script to create the `operations` table in your MySQL database.

### Database Setup

To set up the database, run the `operations.sql` script in your MySQL environment. 

### API Endpoints

The backend system provides the following API endpoint:
 - Create Loan: POST /loan.php
 - Update Loan: PUT /loan.php
 - Delete Loan: DELETE /loan.php

Each endpoint expects a JSON payload with the necessary information to process the loan operation.

### Configuration

Ensure the database connection details in each PHP file are updated to match your MySQL database configuration.


### Deployment

Deploy the backend system to a PHP-supported server environment and ensure it's accessible from your Salesforce Org for outbound HTTP requests. Update the Named Credentials in Salesforce to point to the URL where the backend system is hosted.
