# Name of the container repo
variable "resource_name" {
    type = string
}

# AWS region
variable "region" {
    type = string
}

# The account id
variable "accountID" {
    type = string
}

# iam role for github actions
variable iam_role {

}
