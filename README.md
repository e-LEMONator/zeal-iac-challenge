# AWS Address Book Project

This project demonstrates a simple address book system using AWS services and Terraform. The architecture includes API Gateway, a single Lambda function, and DynamoDB.

## Project Structure

- `lambda/`: Contains the Lambda function code for CRUD operations.
- `terraform/`: Contains the Terraform configuration files for deploying the infrastructure.
- `.gitignore`: Specifies files and directories to be ignored by Git.
- `README.md`: Project documentation.

## Setup Instructions

### Prerequisites

- AWS CLI configured with appropriate permissions.
- Terraform installed.
- Python 3.8 or later.

### Steps

1. **Install Python dependencies**:
    ```sh
    cd lambda
    pip install -r requirements.txt -t .
    ```

2. **Deploy the infrastructure**:
    ```sh
    cd ../terraform
    terraform init
    terraform apply
    ```

3. **Test the API endpoints**:
    Use tools like Postman or curl to test the API endpoints.

## Lambda Function

- `lambda_function.py`: Handles all CRUD operations (Create, Read, Update, Delete) for the address book.

## Terraform Configuration

- `main.tf`: Main Terraform configuration file.
- `variables.tf`: Defines input variables.
- `outputs.tf`: Defines output values.
- `provider.tf`: Configures the AWS provider.