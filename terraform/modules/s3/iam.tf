# Since not all of AWS supports authorization-based tags we make a separate policy for those objects with defined resources
data "aws_iam_policy_document" "github_actions" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:PutObjectTagging"
    ]
    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "github_authorized_actions" {
  name        = "github_actions_s3"
  description = "Grant Github Actions the ability to affect s3 objects that don't support authorization-based tags"
  policy      = data.aws_iam_policy_document.github_actions.json
}

resource "aws_iam_role_policy_attachment" "github_authorized_actions" {
  role       = var.iam_role.name
  policy_arn = aws_iam_policy.github_authorized_actions.arn
}
