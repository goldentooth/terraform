output "k8s_service_fqdns" {
  description = "Map of Kubernetes service names to their FQDNs"
  value = {
    for name, service in var.k8s_services : name => "${name}.services.k8s.${var.domain_name}"
  }
}

output "k8s_services_domain" {
  description = "Base domain for Kubernetes services"
  value       = "services.k8s.${var.domain_name}"
}

output "external_dns_filter_domain" {
  description = "Domain filter for external-dns configuration"
  value       = "services.k8s.${var.domain_name}"
}