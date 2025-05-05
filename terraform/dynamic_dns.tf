module "dynamic_dns" {
  source = "./modules/dynamic_dns"

  default_ttl = local.default_ttl
  domain_name = "dynamic-dns.${local.domain_name}"
  zone_id     = local.zone_id
}
