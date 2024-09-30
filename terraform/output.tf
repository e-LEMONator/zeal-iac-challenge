# Define output values for the deployed resources

# Output the URL of the deployed API Gateway
output "api_url" {
  description = "The URL of the API Gateway"
  value       = aws_api_gateway_deployment.deployment.invoke_url
}

# Output the name of the DynamoDB table
output "dynamodb_table_name" {
  value = aws_dynamodb_table.address_book.name
}


# Output the ARN of the Lambda function
output "lambda_function_arn" {
  value = aws_lambda_function.crud_lambda.arn
}
