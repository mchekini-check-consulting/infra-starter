output "certificate_arn" {
  value = aws_acm_certificate_validation.sm_cert_validate.certificate_arn
}