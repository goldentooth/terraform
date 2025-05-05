resource "aws_route53_record" "cloud_proxy" {
  name    = var.distribution_domain_name
  type    = "A"
  zone_id = var.zone_id

  alias {
    name                   = aws_cloudfront_distribution.cloud_proxy.domain_name
    zone_id                = aws_cloudfront_distribution.cloud_proxy.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_proxy_wildcard" {
  name    = "*.${var.distribution_domain_name}"
  type    = "A"
  zone_id = var.zone_id

  alias {
    name                   = aws_cloudfront_distribution.cloud_proxy.domain_name
    zone_id                = aws_cloudfront_distribution.cloud_proxy.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for domain_validation_option in aws_acm_certificate.cloud_proxy.domain_validation_options : domain_validation_option.domain_name => {
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
