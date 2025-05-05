module "cloud_proxy" {
  source = "./modules/cloud_proxy"

  distribution_domain_name = "home-proxy.${local.domain_name}"
  origin_domain_name       = "clearbrook.${local.domain_name}"
  zone_id                  = local.zone_id
}

import {
  to = module.cloud_proxy.aws_acm_certificate.cloud_proxy
  id = "arn:aws:acm:us-east-1:665449637458:certificate/74b44ab9-5b03-40ff-9ba4-12254224a1c7"
}

import {
  to = module.cloud_proxy.aws_cloudfront_distribution.cloud_proxy
  id = "E2N5EMTIJ96VDJ"
}

import {
  to = module.cloud_proxy.aws_cloudfront_origin_request_policy.cloud_proxy
  id = "9d9c631e-3a1d-41c5-a8f3-ecfee3336ee3"
}

import {
  to = module.cloud_proxy.aws_route53_record.cloud_proxy
  id = "Z0736727S7ZH91VKK44A_home-proxy.goldentooth.net_A"
}

import {
  to = module.cloud_proxy.aws_route53_record.cloud_proxy_wildcard
  id = "Z0736727S7ZH91VKK44A_*.home-proxy.goldentooth.net_A"
}
