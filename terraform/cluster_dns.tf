# Cluster DNS Configuration
# Manages all DNS records for the Goldentooth cluster in a single Route53 zone
module "cluster_dns" {
  source = "./modules/cluster_dns"

  zone_id     = local.zone_id
  domain_name = local.domain_name
  default_ttl = local.default_ttl
  haproxy_ip  = "10.4.0.10"

  # No individual node DNS records - only service wildcards via HAProxy
  nodes = {}

  # External services (non-cluster)
  external_services = {
    # GitHub Pages for documentation
    clog = {
      type   = "CNAME"
      target = "goldentooth.github.io"
    }
    p5js-sketches = {
      type   = "CNAME"
      target = "goldentooth.github.io"
    }
  }
}

# Kubernetes Service DNS
# Can be managed by both Terraform and external-dns
module "k8s_service_dns" {
  source = "./modules/k8s_service_dns"

  zone_id     = local.zone_id
  domain_name = local.domain_name
  default_ttl = local.default_ttl

  # Static K8s services (managed by Terraform)
  # Most services should be managed by external-dns instead
  k8s_services = {
    # Example static entry:
    # argocd = {
    #   ip          = "10.4.11.10"
    #   description = "Argo CD Web UI"
    # }
  }

  # Allow external-dns to manage records in services.k8s.goldentooth.net
  enable_external_dns_management = true
}

# MetalLB services are now managed entirely by external-dns
# No static Terraform records to avoid conflicts

# Outputs for use in other configurations
output "cluster_dns" {
  description = "Cluster DNS configuration details"
  value = {
    zone_id             = local.zone_id
    domain_name         = local.domain_name
    haproxy_ip          = module.cluster_dns.haproxy_ip
    haproxy_domains     = module.cluster_dns.haproxy_target_domains
    clearbrook_fqdn     = module.cluster_dns.clearbrook_fqdn
    k8s_services_domain = module.k8s_service_dns.k8s_services_domain
    external_dns_filter = module.k8s_service_dns.external_dns_filter_domain
  }
}
