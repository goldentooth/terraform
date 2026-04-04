# Route53 CNAME pointing pds.goldentooth.net at the Cloudflare Tunnel.
resource "aws_route53_record" "pds" {
  zone_id = local.zone_id
  name    = "pds.goldentooth.net"
  type    = "CNAME"
  ttl     = local.default_ttl

  records = [
    "${cloudflare_zero_trust_tunnel_cloudflared.goldentooth.id}.cfargotunnel.com",
  ]
}

# Route53 wildcard CNAME for per-user PDS handles.
resource "aws_route53_record" "pds_wildcard" {
  zone_id = local.zone_id
  name    = "*.pds.goldentooth.net"
  type    = "CNAME"
  ttl     = local.default_ttl

  records = [
    "${cloudflare_zero_trust_tunnel_cloudflared.goldentooth.id}.cfargotunnel.com",
  ]
}

# S3 bucket for PDS backups with versioning and lifecycle management.
resource "aws_s3_bucket" "pds_backup" {
  bucket = "goldentooth-pds-backup"
}

resource "aws_s3_bucket_public_access_block" "pds_backup" {
  bucket = aws_s3_bucket.pds_backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
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
