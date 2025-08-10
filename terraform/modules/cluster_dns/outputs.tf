output "wildcard_domains" {
  description = "List of wildcard domains created"
  value       = [for domain in local.wildcard_domains : "${domain}.${var.domain_name}"]
}

output "haproxy_ip" {
  description = "IP address of the HAProxy load balancer"
  value       = var.haproxy_ip
}

output "haproxy_target_domains" {
  description = "Domains that route to HAProxy for SNI-based routing"
  value = {
    nodes    = "*.nodes.${var.domain_name}"
    services = "*.services.${var.domain_name}"
    nomad    = "*.services.nomad.${var.domain_name}"
  }
}

output "clearbrook_fqdn" {
  description = "FQDN for dynamic home IP"
  value       = "clearbrook.${var.domain_name}"
}
