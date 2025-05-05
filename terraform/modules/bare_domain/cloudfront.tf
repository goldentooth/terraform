resource "aws_cloudfront_origin_request_policy" "bare_domain" {
  name    = "goldentooth-bare-domain"
  comment = "For GoldenTooth: forward all headers"

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

resource "aws_cloudfront_origin_access_control" "bare_domain" {
  name                              = "goldentooth-bare-domain"
  description                       = "GoldenTooth bare domain"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "bare_domain" {

  aliases             = [var.domain_name, "*.${var.domain_name}"]
  comment             = "Bare domain website."
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
    origin_request_policy_id = aws_cloudfront_origin_request_policy.bare_domain.id
    target_origin_id         = "goldentooth-bare-domain"
    viewer_protocol_policy   = "allow-all"

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.redirect.arn
    }
  }

  origin {
    domain_name              = aws_s3_bucket.bare_domain.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.bare_domain.id
    origin_id                = "goldentooth-bare-domain"
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE", "DK", "ES", "FI", "FR", "HU", "IE", "NO", "SE"]
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.bare_domain.certificate_arn
    minimum_protocol_version = "TLSv1.2_2019"
    ssl_support_method       = "sni-only"
  }

}

resource "aws_cloudfront_function" "redirect" {
  name    = "goldentooth-redirect"
  runtime = "cloudfront-js-1.0"
  comment = "Redirect root to clog.goldentooth.net"
  publish = true
  code    = file("${path.module}/function/redirect.js")
}
