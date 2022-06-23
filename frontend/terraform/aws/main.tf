# ---------------
# Storage Backend
# ---------------
# Instead of storing the .tfstate files here in the repo, we use a remote storage backend. The state
# file can contain secrets that we do not want committed to the repo.
#
# The storage account and container are created manually prior to terraform initialization.
# *IMPORTANT* There is no transaction control because we are storing the state in S3 to save $$$

terraform {
  backend "s3" {
    bucket = "nickcollins.link-tfstate"
    key    = "nickcollins.link-tfstate"
    region = "us-east-1"
  }
}

# ---------------
# Providers
# ---------------

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      ManagedBy  = "Terraform"
      Project    = "nickcollins.link"
      Section    = "frontend"
    }
  }
}

# -----------------
# Module: s3
# -----------------
# We create an s3 bucket to store all of the static content for the website
module "s3" {
    source = "../modules/s3"

    resource_name = "${var.resource_prefix}-content"
    region = var.region
}

# -----------------
# Module: Route53
# -----------------
# We setup Route53 for our website.
# Note that Terraform will not register the domain for you, for more information look at modules/route53/main.tf
# This is just to automate the creation/deletion of records
module "route53" {
    source = "../modules/route53"

    dns_root_name = var.dns_root_name
}

# -----------------
# Module: cloudfront
# -----------------
# We make a cloudfront distribution to host our static website for us.

module "cloudfront" {
    source = "../modules/cloudfront"

    resource_name = "${var.resource_prefix}-content"
    bucket = module.s3.bucket
    root_object = "resume.html"
    dns_name = var.dns_root_name
    ssl_cert_arn = module.route53.cert_valid.certificate_arn
}
