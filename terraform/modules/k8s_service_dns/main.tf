terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.50.0"
    }
  }
}

# Static K8s service records (managed by Terraform)
# For services that should not be managed by external-dns
resource "aws_route53_record" "k8s_services" {
  for_each = var.k8s_services

  zone_id = var.zone_id
  name    = "${each.key}.services.k8s.${var.domain_name}"
  type    = "A"
  ttl     = var.default_ttl
  records = [each.value.ip]

  lifecycle {
    create_before_destroy = true
  }
}

# Wildcard for all K8s services (optional)
# This allows any *.services.k8s.goldentooth.net to resolve
# Useful during development/testing
resource "aws_route53_record" "k8s_wildcard" {
  count = var.enable_external_dns_management ? 0 : 1

  zone_id = var.zone_id
  name    = "*.services.k8s.${var.domain_name}"
  type    = "A"
  ttl     = var.default_ttl
  records = ["10.4.11.1"]  # Default MetalLB range start

  lifecycle {
    create_before_destroy = true
  }
}

# TXT record for external-dns ownership
# This allows external-dns to identify which records it owns
resource "aws_route53_record" "external_dns_owner" {
  count = var.enable_external_dns_management ? 1 : 0

  zone_id = var.zone_id
  name    = "external-dns-owner.services.k8s.${var.domain_name}"
  type    = "TXT"
  ttl     = 300
  records = ["heritage=external-dns,external-dns/owner=k8s-cluster"]
}