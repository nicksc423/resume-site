resource "aws_ecr_repository" "repo" {
  name                 = var.resource_name
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  # TODO: Add with KMS config
  # encryption_configuration {
  #
  # }

  tags = {
    permit-github-action = "true"
  }
}

resource null_resource ecr_image {
 triggers = {
   python_file = md5(file("../../content/lambda/lambda.py"))
   docker_file = md5(file("../../content/lambda/Dockerfile"))
 }

 provisioner "local-exec" {
   command = <<EOF
           aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${var.accountID}.dkr.ecr.${var.region}.amazonaws.com
           cd ../../content/lambda/
           docker build -t ${aws_ecr_repository.repo.repository_url}/lambda:init .
           docker push ${aws_ecr_repository.repo.repository_url}/lambda:init
       EOF
 }
}

data aws_ecr_image lambda_image {
 depends_on = [
   null_resource.ecr_image
 ]
 repository_name = aws_ecr_repository.repo.name
 image_tag       = "init"
}
