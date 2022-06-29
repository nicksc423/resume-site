# Name of the bucket
variable "resource_name" {
    type = string
}

# AWS region the bucket will be hosted in
variable "region" {
    type = string
}

# Content to upload to the bucket
variable "content" {
    default = {}
}

# Path to the content, this will be depricated when I add CICD
variable "contentPath" {
    default = ""
}
