variable "resource_name" {
    type = string
}

variable "region" {
    type = string
}

variable "accountID" {
    type = string
}

variable "dynamoTableName" {
    type = string
}

variable "repository_url" {
    type = string
}

variable "lambda_image_id" {
    type = string
}

# iam role for github actions
variable iam_role {

}
