#!/bin/bash

# Check if running on Unix-based system
if [[ "$OSTYPE" == "linux-gnu"* || "$OSTYPE" == "darwin"* ]]; then
    echo "Running on Unix-based system"

    # Navigate to the lambda directory
    cd lambda

    # Install dependencies
    pip install -r requirements.txt -t .

    # Create a zip file for the Lambda function
    zip -r ../lambda_function.zip .

    # Clean up the pip installed files
    find . -type f ! -name 'lambda_function.zip' ! -name 'requirements.txt' -delete
    find . -type d ! -name '.' ! -name 'lambda_function.zip' ! -name 'requirements.txt' -exec rm -r {} +

    # Navigate to the terraform directory
    cd ../terraform

    # Initialize Terraform
    terraform init

    # Apply the Terraform configuration
    terraform apply -auto-approve
else
    echo "This script is intended to run on Unix-based systems."
fi