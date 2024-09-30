# Configure the AWS provider
provider "aws" {
  region = var.aws_region  # Use the region specified in variables.tf
}