resource "aws_route53_record" "clog_github_pages" {
  zone_id = local.zone_id
  name    = "clog.goldentooth.net"
  type    = "CNAME"
  ttl     = local.default_ttl

  records = [
    "goldentooth.github.io"
  ]
}