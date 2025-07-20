terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.50.0"
    }
  }
}

locals {
  # Define all wildcard domains that should point to HAProxy
  wildcard_domains = [
    "*.nodes",                # Node homepages via HAProxy SNI
    "*.services",             # Cluster-wide services via HAProxy
    "*.services.nomad",       # Nomad services via HAProxy
  ]
  # Note: *.services.k8s is intentionally excluded - ExternalDNS manages this subdomain
  # with direct A records to MetalLB IPs, not HAProxy routing
}

# Individual node A records - direct access to node IPs
resource "aws_route53_record" "nodes" {
  for_each = var.nodes

  zone_id = var.zone_id
  name    = "${each.key}.${var.domain_name}"
  type    = "A"
  ttl     = 300  # 5 minutes for relatively static IPs
  records = [each.value]
}

# Wildcard records for service domains - all point to HAProxy
resource "aws_route53_record" "wildcards" {
  for_each = var.enable_wildcards ? toset(local.wildcard_domains) : []

  zone_id = var.zone_id
  name    = "${each.key}.${var.domain_name}"
  type    = "A"
  ttl     = var.default_ttl  # 60 seconds for dynamic services
  records = [var.haproxy_ip]
}

# Special case: clearbrook record for dynamic home IP
# This will be updated by the dynamic-dns Lambda
resource "aws_route53_record" "clearbrook" {
  zone_id = var.zone_id
  name    = "clearbrook.${var.domain_name}"
  type    = "A"
  ttl     = var.default_ttl
  records = ["1.1.1.1"]  # Placeholder - will be updated by dynamic DNS

  lifecycle {
    ignore_changes = [records]  # Ignore changes since Lambda updates this
  }
}

# External service A records
resource "aws_route53_record" "external_services_a" {
  for_each = {
    for name, service in var.external_services : name => service
    if service.type == "A"
  }

  zone_id = var.zone_id
  name    = "${each.key}.${var.domain_name}"
  type    = "A"
  ttl     = var.default_ttl
  records = [each.value.target]
}

# External service CNAME records
resource "aws_route53_record" "external_services_cname" {
  for_each = {
    for name, service in var.external_services : name => service
    if service.type == "CNAME"
  }

  zone_id = var.zone_id
  name    = "${each.key}.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300  # 5 minutes for CNAME records
  records = [each.value.target]
}