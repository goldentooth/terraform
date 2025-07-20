variable "zone_id" {
  description = "Route53 zone ID"
  type        = string
}

variable "domain_name" {
  description = "Base domain name"
  type        = string
  default     = "goldentooth.net"
}

variable "default_ttl" {
  description = "Default TTL for DNS records"
  type        = string
  default     = "60"
}

variable "k8s_services" {
  description = "Map of Kubernetes service names to their LoadBalancer IPs"
  type = map(object({
    ip          = string
    description = string
  }))
  default = {}
}

variable "enable_external_dns_management" {
  description = "Whether to allow external-dns to manage records in this zone"
  type        = bool
  default     = true
}