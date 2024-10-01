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

### 3. **Test the API endpoints**:
Use tools like Postman or curl to test the API endpoints.

* GET `/contacts`: Retrieve a contact by `contact_id`
    * Query Parameters: `contact_id`
    * Example: `curl -X GET "https://<api-id>.execute-api.<region>.amazonaws.com/prod/contacts?contact_id=<contact_id>"`
* POST `/contacts`: Create a new contact
    * Request Body: JSON object with `contact_id`, `name`, and `address`
    * Example: `curl -X POST "https://<api-id>.execute-api.<region>.amazonaws.com/prod/contacts" \
  -H "Content-Type: application/json" \
  -d '{
        "contact_id": "123",
        "name": "John Doe",
        "address": "123 Main St"
      }'`
*  PUT `/contacts`: Update an existing contact
    * Request Body: JSON object with `contact_id`, `name`, and `address`
    * Example: `curl -X PUT "https://<api-id>.execute-api.<region>.amazonaws.com/prod/contacts" \
  -H "Content-Type: application/json" \
  -d '{
        "contact_id": "123",
        "name": "Jane Doe",
        "address": "456 Elm St"
      }'`
* DELETE `/contacts`: Delete a contact by `contact_id`
    * Request Body: JSON object with `contact_id`
    * Example: `curl -X DELETE "https://<api-id>.execute-api.<region>.amazonaws.com/prod/contacts" \
  -H "Content-Type: application/json" \
  -d '{
        "contact_id": "123"
      }'`

### 4. **Clean up the resources**:
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