# Since not all of AWS supports authorization-based tags we make a separate policy for those objects with defined resources
data "aws_iam_policy_document" "github_actions" {
  statement {
    actions = [
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    resources = [
      aws_ecr_repository.repo.arn
    ]
  }
}

data "aws_iam_policy_document" "github_ecr_auth" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "github_authorized_actions" {
  name        = "github_actions_ecr"
  description = "Grant Github Actions the ability to affect ecr objects that don't support authorization-based tags"
  policy      = data.aws_iam_policy_document.github_actions.json
}

resource "aws_iam_policy" "github_ecr_authorize" {
  name        = "github_authorize_ecr"
  description = "Grant Github Actions the ability to login to ecr"
  policy      = data.aws_iam_policy_document.github_ecr_auth.json
}

resource "aws_iam_role_policy_attachment" "github_authorized_actions" {
  role       = var.iam_role.name
  policy_arn = aws_iam_policy.github_authorized_actions.arn
}

resource "aws_iam_role_policy_attachment" "github_authorize_ecr" {
  role       = var.iam_role.name
  policy_arn = aws_iam_policy.github_ecr_authorize.arn
}
