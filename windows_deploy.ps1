# Check if running on Windows
if ($IsWindows) {
    Write-Output "Running on Windows"

    # Navigate to the lambda directory
    Set-Location -Path "lambda"

    # Install dependencies
    pip install -r requirements.txt -t .

    # Create a zip file for the Lambda function
    Compress-Archive -Path * -DestinationPath ../lambda_function.zip -Force

    # Clean up the pip installed files
    Get-ChildItem -Path . -Exclude "lambda_function.zip", "requirements.txt" | Remove-Item -Recurse -Force

    # Navigate to the terraform directory
    Set-Location -Path "../terraform"

    # Initialize Terraform
    terraform init

    # Apply the Terraform configuration
    terraform apply -auto-approve
} else {
    Write-Output "This script is intended to run on Windows."
}