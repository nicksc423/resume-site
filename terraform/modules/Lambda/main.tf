# Create the Lambda
resource "aws_lambda_function" "lambda" {
  function_name = "incrementAndReturnViewcount"

  image_uri = "${var.repository_url}@${var.lambda_image_id}"
  package_type = "Image"

  role = aws_iam_role.lambda_role.arn

  timeout = 300
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
