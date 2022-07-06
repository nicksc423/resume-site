output "ecr" {
  description = "The ecr object"
  value       = aws_ecr_repository.repo
}

output "image" {
  description = "The image object for our lambda"
  value       = data.aws_ecr_image.lambda_image
}

resource "local_file" "ECR_URL" {
    filename = "../out/ECR_URL"
    content = aws_ecr_repository.repo.repository_url
}
