module "bare_domain" {
  source = "./modules/bare_domain"

  domain_name = local.domain_name
  zone_id     = local.zone_id
}

