# Fetch the current AWS account ID
data "aws_caller_identity" "current" {}

# Upload Lambda zip to S3
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.project_name}-lambda-deployment-bucket"
}

resource "aws_s3_object" "lambda_zip" {
  bucket = aws_s3_bucket.lambda_bucket.bucket
  key    = "lambda_function.zip"
  source = "${path.module}/../lambda_function.zip" # Point to the zip in the parent directory
  etag   = filemd5("${path.module}/../lambda_function.zip")
}

# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_exec" {
  name = "${var.project_name}_${var.lambda_exec_role_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Sid    = "",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the AWSLambdaBasicExecutionRole policy to the IAM role
resource "aws_iam_policy_attachment" "lambda_policy" {
  name       = "${var.project_name}_lambda_policy_attachment"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Add a policy to allow Lambda to interact with DynamoDB
resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name   = "lambda_dynamodb_policy"
  role   = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ],
        Resource = "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${aws_dynamodb_table.address_book.name}"
      }
    ]
  })
}

# Create a DynamoDB table for storing contact information
resource "aws_dynamodb_table" "address_book" {
  name         = "${var.project_name}_${var.dynamodb_table_name}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "contact_id"

  attribute {
    name = "contact_id"
    type = "S"
  }
}

# Create the Lambda function for CRUD operations
resource "aws_lambda_function" "crud_lambda" {
  s3_bucket        = aws_s3_bucket.lambda_bucket.bucket
  s3_key           = aws_s3_object.lambda_zip.key
  function_name    = "${var.project_name}_${var.lambda_function_name}"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = var.lambda_runtime
  source_code_hash = filebase64sha256("${path.module}/../lambda_function.zip")

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.address_book.name
    }
  }
}

# Create an API Gateway REST API
resource "aws_api_gateway_rest_api" "address_book_api" {
  name        = "${var.project_name}_${var.api_gateway_name}"
  description = "API for Address Book CRUD operations"
}

# Create a resource for the /contacts endpoint
resource "aws_api_gateway_resource" "contacts" {
  rest_api_id = aws_api_gateway_rest_api.address_book_api.id
  parent_id   = aws_api_gateway_rest_api.address_book_api.root_resource_id
  path_part   = "contacts"
}

# Create a method for handling any HTTP request to the /contacts endpoint
resource "aws_api_gateway_method" "any_method" {
  rest_api_id   = aws_api_gateway_rest_api.address_book_api.id
  resource_id   = aws_api_gateway_resource.contacts.id
  http_method   = "ANY"
  authorization = "NONE"
}

# Integrate the Lambda function with the API Gateway
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.address_book_api.id
  resource_id             = aws_api_gateway_resource.contacts.id
  http_method             = aws_api_gateway_method.any_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.crud_lambda.invoke_arn
}

# Grant API Gateway permission to invoke the Lambda function
resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.crud_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.address_book_api.execution_arn}/*/*"
}

# Create a GET method for the /contacts endpoint
resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.address_book_api.id
  resource_id   = aws_api_gateway_resource.contacts.id
  http_method   = "GET"
  authorization = "NONE"
}

# Integrate the Lambda function with the GET method
resource "aws_api_gateway_integration" "get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.address_book_api.id
  resource_id             = aws_api_gateway_resource.contacts.id
  http_method             = aws_api_gateway_method.get_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.crud_lambda.invoke_arn
}

# Grant API Gateway permission to invoke the Lambda function for GET method
resource "aws_lambda_permission" "api_gateway_permission_get" {
  statement_id  = "AllowAPIGatewayInvokeGet"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.crud_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.address_book_api.execution_arn}/*/GET/contacts"
}

# Deploy the API Gateway
resource "aws_api_gateway_deployment" "deployment" {
  depends_on   = [aws_api_gateway_integration.lambda_integration, aws_api_gateway_integration.get_integration]
  rest_api_id  = aws_api_gateway_rest_api.address_book_api.id
  stage_name   = "prod"
}