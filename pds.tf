# DNS for PDS is managed by external-dns (HTTPRoute -> Route53).

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

# IAM user for PDS backup writes to S3.
resource "aws_iam_user" "pds_backup" {
  name = "goldentooth-pds-backup"
}

resource "aws_iam_user_policy" "pds_backup" {
  name = "pds-backup-s3-access"
  user = aws_iam_user.pds_backup.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket",
        ]
        Resource = [
          aws_s3_bucket.pds_backup.arn,
          "${aws_s3_bucket.pds_backup.arn}/*",
        ]
      },
    ]
  })
}

resource "aws_iam_access_key" "pds_backup" {
  user = aws_iam_user.pds_backup.name
}

output "pds_backup_aws_access_key_id" {
  description = "AWS access key ID for PDS backup IAM user."
  value       = aws_iam_access_key.pds_backup.id
}

output "pds_backup_aws_secret_access_key" {
  description = "AWS secret access key for PDS backup IAM user."
  value       = aws_iam_access_key.pds_backup.secret
  sensitive   = true
}
