output "iam_role" {
  description = "The iam role for the github_actions role to assume"
  value       = aws_iam_role.github_actions
}

resource "local_file" "GitHub_IAM_ARN" {
    filename = "../out/GitHub_IAM_ARN"
    content = aws_iam_role.github_actions.arn
}
