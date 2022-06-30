# Create an OIDC provider for GitHub actions
# Docs: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-cloud-providers
# Thumbprint: https://github.blog/changelog/2022-01-13-github-actions-update-on-oidc-based-deployments-to-aws/
# Thumbprint can change if GitHub updates the Actions SSL certificates, so this will need to be manually updated
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = [ "sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# Make a policy so our Repo's can assume a Role
data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = var.repositories
    }
  }
}

# Create the IAM role
resource "aws_iam_role" "github_actions" {
  name               = "github-actions"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}

# Grant permissions to our IAM role
# note the condition, only infra tagged with permit-github-action: true can be affected
# The one caveat to the above is that s3 does not support conditional permissions for s3
data "aws_iam_policy_document" "github_actions" {
  statement {
    actions = var.actions
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/permit-github-action"

      values = ["true"]
    }
  }
}

resource "aws_iam_policy" "github_actions" {
  name        = "github-actions"
  description = "Grant Github Actions the ability to push to ECR"
  policy      = data.aws_iam_policy_document.github_actions.json
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}

# This is a super ugly way to make a list of all our buckets and att '/*' to the end
# so they work for our IAM policy.  Needs to be rewritten
locals {
  permitted_bucket_objects = formatlist("%s/*", var.permitted_buckets)
}

# Since AWS does not allow conditional permissions for s3, we restrict s3 permissions
# on a per bucket basis
data "aws_iam_policy_document" "github_s3_actions" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:PutObjectTagging"
    ]
    resources = concat(var.permitted_buckets, local.permitted_bucket_objects)
  }
}

resource "aws_iam_policy" "github_s3_actions" {
  name        = "github-s3-actions"
  description = "Grant Github Actions the ability to push to ECR"
  policy      = data.aws_iam_policy_document.github_s3_actions.json
}

resource "aws_iam_role_policy_attachment" "github_s3_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_s3_actions.arn
}
