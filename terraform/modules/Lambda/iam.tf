# Since not all of AWS supports authorization-based tags we make a separate policy for those objects with defined resources
data "aws_iam_policy_document" "github_actions" {
  statement {
    actions = [
      "lambda:UpdateFunctionCode"
    ]
    resources = [
      aws_lambda_function.lambda.arn
    ]
  }
}

resource "aws_iam_policy" "github_authorized_actions" {
  name        = "github_actions_lambda"
  description = "Grant Github Actions the ability to affect lambda objects that don't support authorization-based tags"
  policy      = data.aws_iam_policy_document.github_actions.json
}

resource "aws_iam_role_policy_attachment" "github_authorized_actions" {
  role       = var.iam_role.name
  policy_arn = aws_iam_policy.github_authorized_actions.arn
}
