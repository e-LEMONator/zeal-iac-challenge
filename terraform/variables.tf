# Define variables for the Terraform configuration

# Variable for project name
variable "project_name" {
  description = "The name of the project for resource naming"
  type        = string
  default     = "zeal-iac-challenge"
}

# Variable for the AWS region
variable "aws_region" {
  description = "The AWS region to deploy the resources"
  type        = string
  default     = "us-east-2" # Or any preferred region
}

# Variable for the DynamoDB table name
variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  type        = string
  default     = "AddressBook"
}

# Variable for the Lambda function name
variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
  default     = "crud_lambda"
}

# Variable for the API Gateway name
variable "api_gateway_name" {
  description = "The name of the API Gateway"
  type        = string
  default     = "AddressBookAPI"
}

# Variable for the Lambda execution role
variable "lambda_exec_role_name" {
  description = "The name of the IAM role for Lambda execution"
  type        = string
  default     = "lambda_exec_role"
}

variable "lambda_runtime" {
  description = "Runtime environment for Lambda"
  type        = string
  default     = "python3.11"
}
