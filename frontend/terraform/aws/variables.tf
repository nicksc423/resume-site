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
