# Name of the bucket
variable "resource_name" {
    type = string
}

# the s3 bucket object this cloudfront CDN will be hosting
variable "bucket" {
}

# File name of the object in the s3 that will be our root object
# defaults to index.html
variable "root_object" {
    type = string
    default = "index.html"
}

# DNS name we want this cloudfront CDN to host
variable "dns_name" {
    type = string
}

# The ARN of the SSL cert we wish to use
variable "ssl_cert_arn" {
  type = string
}
