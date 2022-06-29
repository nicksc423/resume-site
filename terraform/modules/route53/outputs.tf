output "cert_valid" {
  description = "The ssl cert that has been issued and is valid"
  value       = aws_acm_certificate_validation.cert_valid
}

output "r53_zone" {
  description = "The hosted zone in route 53"
  value       = data.aws_route53_zone.zone
}

output "cert" {
  description = "The SSL cert provisioned for our domain"
  value       = aws_acm_certificate.cert
}
