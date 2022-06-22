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
