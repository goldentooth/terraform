resource "aws_acm_certificate" "dynamic_dns" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "dynamic_dns" {
  certificate_arn         = aws_acm_certificate.dynamic_dns.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}
