# Load mime types so we can set based on file extension
locals {
  mime_types = jsondecode(file("${path.module}/mime.json"))
}

# Create the bucket and apply any tags
resource "aws_s3_bucket" "bucket" {
  bucket = var.resource_name
}

# Block all public access to the bucket and it's contents
resource "aws_s3_bucket_public_access_block" "bucket_block_all_public_access" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

# Enable versioning
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Upload all files in the ../frontent/content directory to the bucket
resource "aws_s3_object" "static_content" {
  for_each = var.content
  bucket = aws_s3_bucket.bucket.id
  key = each.value
  source = "${var.contentPath}${each.value}"
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.value), null)

  # take an md5 hash of the file & if it changes terraform will mark the file for upload
  etag = filemd5("${var.contentPath}${each.value}")
}
