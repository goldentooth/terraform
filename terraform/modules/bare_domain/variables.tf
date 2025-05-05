variable "domain_name" {
  description = "The domain name for the CloudFront distribution, Route53 records, etc."
  type        = string
  default     = "goldentooth.net"
}

variable "zone_id" {
  description = "The Route53 Zone ID."
  type        = string
  default     = "Z0736727S7ZH91VKK44A"
}
