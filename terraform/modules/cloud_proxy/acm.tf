resource "aws_acm_certificate" "cloud_proxy" {
  domain_name               = var.distribution_domain_name
  subject_alternative_names = [var.distribution_domain_name, "*.${var.distribution_domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "cloud_proxy" {
  certificate_arn         = aws_acm_certificate.cloud_proxy.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}
