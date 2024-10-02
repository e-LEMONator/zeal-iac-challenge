# Address Book API

This project provides a serverless API for managing an address book using AWS Lambda, API Gateway, and DynamoDB.

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform installed
- Python 3.x installed
- `pip` installed

## Project Structure

- `terraform/`: Contains Terraform configuration files
- `lambda/`: Contains the Lambda function code
- `windows_deploy.ps1`: Deployment script for Windows
- `linux_deploy.sh`: Deployment script for Unix-based systems

## Setup Instructions

### 1. Build the Lambda Deployment Package

Navigate to the `lambda/` directory and install the required dependencies:

```sh
cd lambda
pip install -r requirements.txt -t .
```
Create a zip file for the Lambda function:
```
zip -r ../lambda_function.zip .
```

### 2. **Deploy the infrastructure**:
Navigate to the `terraform/` directory and initialize Terraform:
```sh
cd ../terraform
terraform init
```
Apply the Terraform configuration to plan and deploy the infrastructure:
```sh
terraform plan
terraform apply
```

### 3. **Use the Deployment Scripts**:
**Windows**
Open PowerShell and run the `windows_deploy.ps1` script:
```sh
.\windows_deploy.ps1
```

**Unix-based**
Open a terminal and run the `linux_deploy.sh` script:
```sh
./linux_deploy.sh
```

### 4. **Test the API endpoints**:
Use tools like Postman or curl to test the API endpoints.

* GET `/contacts`: Retrieve a contact by `contact_id`
    * Query Parameters: `contact_id`
    * Example: `curl -X GET "https://<api-id>.execute-api.<region>.amazonaws.com/prod/contacts?contact_id=<contact_id>"`
* POST `/contacts`: Create a new contact
    * Query Parameters: `contact_id`
    * Request Body: JSON object with `name`, and `address`
    * Example: `https://<api-id>.execute-api.<region>.amazonaws.com/prod/contacts?contact_id=<contact_id>" \
  -H "Content-Type: application/json" \
  -d '{
        "name": "John Doe",
        "address": "123 Main St"
      }'`
*  PUT `/contacts`: Update an existing contact
    * Query Parameters: `contact_id`
    * Request Body: JSON object with `name`, and `address`
    * Example: `curl -X PUT "https://<api-id>.execute-api.<region>.amazonaws.com/prod/contacts?contact_id=<contact_id>" \
  -H "Content-Type: application/json" \
  -d '{
        "name": "John Doe Updated",
        "address": "456 Main St"
      }'`
* DELETE `/contacts`: Delete a contact by `contact_id`
    * Query Parameters: `contact_id`
    * Example: `curl -X DELETE "https://<api-id>.execute-api.<region>.amazonaws.com/prod/contacts?contact_id=<contact_id>"`

### 5. **Clean up the resources**:
To clean up the resources created by Terraform, the following command in the `terraform/` directory::
```sh
terraform destroy
```

## Lambda Function

- `lambda_function.py`: Handles all CRUD operations (Create, Read, Update, Delete) for the address book.

## Terraform Configuration

- `main.tf`: Main Terraform configuration file.
- `variables.tf`: Defines input variables.
- `outputs.tf`: Defines output values.
- `provider.tf`: Configures the AWS provider.