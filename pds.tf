# Cloudflare account lookup for tunnel resources.
data "cloudflare_accounts" "main" {}

# Random secret used to authenticate the tunnel connector.
resource "random_password" "pds_tunnel_secret" {
  length  = 64
  special = false
}

# Cloudflare Tunnel for routing public traffic to the PDS service.
resource "cloudflare_zero_trust_tunnel_cloudflared" "pds" {
  account_id = data.cloudflare_accounts.main.accounts[0].id
  name       = "goldentooth-pds"
  secret     = random_password.pds_tunnel_secret.result
}

# Tunnel ingress configuration — routes hostnames to the in-cluster PDS service.
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "pds" {
  account_id = data.cloudflare_accounts.main.accounts[0].id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.pds.id

  config = {
    ingress_rules = [
      {
        hostname = "pds.goldentooth.net"
        service  = "http://pds.pds.svc.cluster.local:3000"
      },
      {
        hostname = "*.pds.goldentooth.net"
        service  = "http://pds.pds.svc.cluster.local:3000"
      },
      {
        service = "http_status:404"
      },
    ]
  }
}

# Route53 CNAME pointing pds.goldentooth.net at the Cloudflare Tunnel.
resource "aws_route53_record" "pds" {
  zone_id = local.zone_id
  name    = "pds.goldentooth.net"
  type    = "CNAME"
  ttl     = local.default_ttl

  records = [
    "${cloudflare_zero_trust_tunnel_cloudflared.pds.id}.cfargotunnel.com",
  ]
}

# Route53 wildcard CNAME for per-user PDS handles.
resource "aws_route53_record" "pds_wildcard" {
  zone_id = local.zone_id
  name    = "*.pds.goldentooth.net"
  type    = "CNAME"
  ttl     = local.default_ttl

  records = [
    "${cloudflare_zero_trust_tunnel_cloudflared.pds.id}.cfargotunnel.com",
  ]
}

# S3 bucket for PDS backups with versioning and lifecycle management.
resource "aws_s3_bucket" "pds_backup" {
  bucket = "goldentooth-pds-backup"
}

resource "aws_s3_bucket_versioning" "pds_backup" {
  bucket = aws_s3_bucket.pds_backup.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "pds_backup" {
  bucket = aws_s3_bucket.pds_backup.id

  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

output "pds_tunnel_id" {
  description = "Cloudflare Tunnel ID for the PDS service."
  value       = cloudflare_zero_trust_tunnel_cloudflared.pds.id
}

output "pds_tunnel_token" {
  description = "Cloudflare Tunnel token for the PDS connector."
  value       = cloudflare_zero_trust_tunnel_cloudflared.pds.tunnel_token
  sensitive   = true
}
