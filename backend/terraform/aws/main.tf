# ---------------
# Storage Backend
# ---------------
# Instead of storing the .tfstate files here in the repo, we use a remote storage backend. The state
# file can contain secrets that we do not want committed to the repo.
#
# The storage account and container are created manually prior to terraform initialization.
# *IMPORTANT* There is no transaction control because we are storing the state in S3 to save $$$

terraform {
  backend "s3" {
    bucket = "nickcollins.link-tfstate"
    key    = "nickcollins.link-backend-tfstate"
    region = "us-east-1"
  }
}

# ---------------
# Providers
# ---------------

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      ManagedBy  = "Terraform"
      Project    = "nickcollins.link"
      Section    = "backend"
    }
  }
}

# -----------------
# Module: DynamoDB
# -----------------
# We create a DynamoDB instance to store the view count
module "dynamodb" {
    source = "../modules/DynamoDB"

    resource_name = "${var.resource_prefix}-ddb"
}

# -----------------
# Module: Lambda
# -----------------
# We create lambda to act as the backend, contains a Lambda, API Gateway, and DynamoDB instance
module "lambda" {
    source = "../modules/lambda"

    resource_name = "${var.resource_prefix}-backend"
    region = var.region
    accountID = var.accountID
    dynamoTableName = module.dynamodb.table.name
}

# -----------------
# Module: API Gateway
# -----------------
# We create a DynamoDB instance to store the view count
module "apigateway" {
    source = "../modules/apigateway"

    resource_name = "${var.resource_prefix}-apigw"
    lambda = module.lambda.lambda
    certificate_arn = var.certificate_arn
    dns_root_name = var.dns_root_name
    r53_zoneID = var.r53_zoneID
}
