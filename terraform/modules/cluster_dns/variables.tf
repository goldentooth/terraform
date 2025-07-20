variable "zone_id" {
  description = "Route53 zone ID for goldentooth.net"
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

variable "haproxy_ip" {
  description = "IP address of HAProxy load balancer (allyrion)"
  type        = string
  default     = "10.4.0.10"
}

variable "nodes" {
  description = "Map of node names to their IP addresses"
  type        = map(string)
  default = {
    allyrion   = "10.4.0.10"
    bettley    = "10.4.0.11"
    cargyll    = "10.4.0.12"
    dalt       = "10.4.0.13"
    erenford   = "10.4.0.14"
    fenn       = "10.4.0.15"
    gardener   = "10.4.0.16"
    harlton    = "10.4.0.17"
    inchfield  = "10.4.0.18"
    jast       = "10.4.0.19"
    karstark   = "10.4.0.20"
    lipps      = "10.4.0.21"
    velaryon   = "10.4.0.30"
  }
}

variable "external_services" {
  description = "Map of external service names to their targets"
  type = map(object({
    type   = string
    target = string
  }))
  default = {}
}

variable "enable_wildcards" {
  description = "Enable wildcard DNS records for service domains"
  type        = bool
  default     = true
}