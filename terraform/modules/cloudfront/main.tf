locals {
  s3_origin_id = "${var.resource_name}-content"
}

# Make an OAI to access our s3 bucket
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "${var.resource_name}-OAI"
}

# Update the bucket policy for the s3 bucket to allow the OAI to access it
# TODO: Update this to append to the existing policy
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${var.bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "oai_policy" {
  bucket = var.bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_cloudfront_distribution" "distribution" {

  # Define what we want Cloudfront to host, in this case our S3 Bucket
  origin {
    domain_name = var.bucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.resource_name} CDN"
  default_root_object = var.root_object

  aliases = [var.dns_name]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.ssl_cert_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method = "sni-only"
  }

  tags = {
    permit-github-action = "true"
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to cache invalidations
      in_progress_validation_batches
    ]
  }
}

# We load in our root route53 zone
data "aws_route53_zone" "zone" {
  name         = var.dns_name
  private_zone = false
}

resource "aws_route53_record" "site" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.dns_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
