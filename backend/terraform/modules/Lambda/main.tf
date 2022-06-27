data "archive_file" "lambda_code" {
  type = "zip"

  source_dir  = "../../content/lambda"
  output_path = "${path.module}/lambda.zip"
}

# Create the bucket and apply any tags
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.resource_name
}

# Upload to s3
resource "aws_s3_object" "lambda_s3" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "lambda.zip"
  source = data.archive_file.lambda_code.output_path

  etag = filemd5(data.archive_file.lambda_code.output_path)
}

# Block all public access to the bucket and it's contents
resource "aws_s3_bucket_public_access_block" "bucket_block_all_public_access" {
  bucket = aws_s3_bucket.lambda_bucket.id

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

# Enable versioning
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.lambda_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Create the Lambda
resource "aws_lambda_function" "lambda" {
  function_name = "incrementAndReturnViewcount"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_s3.key

  runtime = "python3.9"
  handler = "lambda.lambda_handler"

  source_code_hash = data.archive_file.lambda_code.output_base64sha256

  role = aws_iam_role.lambda_role.arn
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.resource_name}-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.resource_name}-lambda-policy"
  role = aws_iam_role.lambda_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect": "Allow",
        "Action": "dynamodb:UpdateItem",
        "Resource": "arn:aws:dynamodb:${var.region}:${var.accountID}:table/${var.dynamoTableName}"
      },
    ]
  })
}
