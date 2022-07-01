data "archive_file" "lambda_code" {
  type = "zip"

  source_dir  = "../../content/lambda"
  output_path = "../../content/out/lambda.zip"
}

# Upload to s3
resource "aws_s3_object" "lambda_s3" {
  bucket = var.bucket.id

  key    = "lambda.zip"
  source = data.archive_file.lambda_code.output_path

  etag = filemd5(data.archive_file.lambda_code.output_path)
}

# Create the Lambda
resource "aws_lambda_function" "lambda" {
  function_name = "incrementAndReturnViewcount"

  s3_bucket = var.bucket.id
  s3_key    = aws_s3_object.lambda_s3.key

  runtime = "python3.9"
  handler = "lambda.lambda_handler"

  source_code_hash = data.archive_file.lambda_code.output_base64sha256

  role = aws_iam_role.lambda_role.arn

  tags = {
    permit-github-action = "true"
  }
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
