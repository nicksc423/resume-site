output "cert_valid" {
  description = "The ssl cert that has been issued and is valid"
  value       = aws_acm_certificate_validation.cert_valid
}
