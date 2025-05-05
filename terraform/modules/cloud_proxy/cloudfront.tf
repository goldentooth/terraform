resource "aws_cloudfront_origin_request_policy" "cloud_proxy" {
  name    = "goldentooth-cloud-proxy"
  comment = "For GoldenTooth: forward original Host header and all headers"

  headers_config {
    header_behavior = "allViewer"
  }

  cookies_config {
    cookie_behavior = "all"
  }

  query_strings_config {
    query_string_behavior = "all"
  }
}

resource "aws_cloudfront_distribution" "cloud_proxy" {

  aliases             = [var.distribution_domain_name, "*.${var.distribution_domain_name}"]
  comment             = "Proxy for home services."
  enabled             = true
  is_ipv6_enabled     = false
  price_class         = "PriceClass_100"
  retain_on_delete    = true
  wait_for_deployment = false

  # AWS Managed Caching Policy (CachingDisabled)
  default_cache_behavior {
    # Using the CachingDisabled managed policy ID:
    cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods           = ["GET", "HEAD", "OPTIONS"]
    origin_request_policy_id = aws_cloudfront_origin_request_policy.cloud_proxy.id
    target_origin_id         = var.origin_domain_name
    viewer_protocol_policy   = "allow-all"
  }

  origin {
    domain_name = var.origin_domain_name
    origin_id   = var.origin_domain_name

    custom_origin_config {
      http_port                = 7463
      https_port               = 7464
      origin_protocol_policy   = "http-only"
      origin_ssl_protocols     = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
    }

  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE", "DK", "ES", "FI", "FR", "HU", "IE", "NO", "SE"]
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cloud_proxy.certificate_arn
    minimum_protocol_version = "TLSv1.2_2019"
    ssl_support_method       = "sni-only"
  }

}
