# The aws_route53domains_registered_domain resource behaves differently from normal resources
# Terraform does not register this domain, but instead "adopts" it into management.
# terraform destroy does not delete the domain but does remove the resource from Terraform state.

resource "aws_route53domains_registered_domain" "domain" {
  domain_name = var.dns_root_name
}

# We provision an SSL cert and wait for it to be issued
# We use everything in this block to ensure that it is created before we go further
resource "aws_acm_certificate" "cert" {
  domain_name       = var.dns_root_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "zone" {
  name         = var.dns_root_name
  private_zone = false
}

resource "aws_route53_record" "record" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.zone.zone_id
}

resource "aws_acm_certificate_validation" "cert_valid" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.record : record.fqdn]
}
