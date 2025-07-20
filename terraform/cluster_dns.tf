# Cluster DNS Configuration
# Manages all DNS records for the Goldentooth cluster in a single Route53 zone

module "cluster_dns" {
  source = "./modules/cluster_dns"

  zone_id     = local.zone_id
  domain_name = local.domain_name
  default_ttl = local.default_ttl
  haproxy_ip  = "10.4.0.10"  # allyrion

  # Node IP mappings
  nodes = {
    allyrion  = "10.4.0.10"
    bettley   = "10.4.0.11"
    cargyll   = "10.4.0.12"
    dalt      = "10.4.0.13"
    erenford  = "10.4.0.14"
    fenn      = "10.4.0.15"
    gardener  = "10.4.0.16"
    harlton   = "10.4.0.17"
    inchfield = "10.4.0.18"
    jast      = "10.4.0.19"
    karstark  = "10.4.0.20"
    lipps     = "10.4.0.21"
    velaryon  = "10.4.0.30"
  }

  # External services (non-cluster)
  external_services = {
    # GitHub Pages for documentation
    clog = {
      type   = "CNAME"
      target = "goldentooth.github.io."  # Trailing dot for FQDN
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

# Outputs for use in other configurations
output "cluster_dns" {
  description = "Cluster DNS configuration details"
  value = {
    zone_id              = local.zone_id
    domain_name          = local.domain_name
    node_fqdns           = module.cluster_dns.node_fqdns
    haproxy_domains      = module.cluster_dns.haproxy_target_domains
    clearbrook_fqdn      = module.cluster_dns.clearbrook_fqdn
    k8s_services_domain  = module.k8s_service_dns.k8s_services_domain
    external_dns_filter  = module.k8s_service_dns.external_dns_filter_domain
  }
}