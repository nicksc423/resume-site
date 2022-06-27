# ---------------
# Input Variables
# ---------------
# These are the different variables needed to make an environment.
# Their values are set in the terraform.tfvars file or are defaulted here if unlikely to change

# This is the region that all resources are made in
variable "region" {
    type = string
}

# A prefix for naming resources. Adding the prefix ensures uniqueness and also potentially helps distinguish our own resources from each other
variable "resource_prefix" {
    type = string
}

# This domain is registered via Route53
variable "dns_root_name" {
    type = string
}

# This is our accountID
variable "accountID" {
    type = string
}

# This is the certificate arn
# TODO: This is bad, but will be refactored out later
variable "certificate_arn" {
    type = string
}

# This is the route53 zone id
# TODO: This is bad, but will be refactored out later
variable "r53_zoneID" {
    type = string
}
