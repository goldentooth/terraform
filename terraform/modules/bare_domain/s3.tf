resource "aws_s3_bucket" "bare_domain" {
  bucket        = "goldentooth.net"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "bare_domain" {
  bucket = aws_s3_bucket.bare_domain.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "bare_domain" {
  bucket = aws_s3_bucket.bare_domain.id

  redirect_all_requests_to {
    host_name = "clog.goldentooth.com"
    protocol  = "https"
  }

}
