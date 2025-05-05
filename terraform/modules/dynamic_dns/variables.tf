variable "default_ttl" {
  description = "The default TTL for dynamic DNS records."
  type        = string
  default     = "60"
}

variable "domain_name" {
  description = "The domain name."
  type        = string
  default     = "dynamic-dns.goldentooth.net"
}

variable "zone_id" {
  description = "The Route53 Zone ID."
  type        = string
  default     = "Z0736727S7ZH91VKK44A"
}
