variable "distribution_domain_name" {
  description = "The distribution domain name for the CloudFront distribution."
  type        = string
  default     = "home-proxy.goldentooth.net"
}

variable "origin_domain_name" {
  description = "The origin domain name for the CloudFront distribution."
  type        = string
  default     = "clearbrook.goldentooth.net"
}

variable "zone_id" {
  description = "The Route53 Zone ID."
  type        = string
  default     = "Z0736727S7ZH91VKK44A"
}
