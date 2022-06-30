resource "local_file" "GitHub_IAM_ARN" {
    filename = "../out/GitHub_IAM_ARN"
    content = aws_iam_role.github_actions.arn
}
