resource "aws_route53_record" "bare_domain" {
  zone_id = var.zone_id
  name    = "goldentooth.net"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.bare_domain.domain_name
    zone_id                = aws_cloudfront_distribution.bare_domain.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for domain_validation_option in aws_acm_certificate.bare_domain.domain_validation_options : domain_validation_option.domain_name => {
      name   = domain_validation_option.resource_record_name
      record = domain_validation_option.resource_record_value
      type   = domain_validation_option.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.zone_id
}
