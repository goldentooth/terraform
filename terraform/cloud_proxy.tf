module "cloud_proxy" {
  source = "./modules/cloud_proxy"

  distribution_domain_name = "home-proxy.${local.domain_name}"
  origin_domain_name       = "clearbrook.${local.domain_name}"
  zone_id                  = local.zone_id
}
