resource "aws_route53_record" "k8s_control_plane" {
  zone_id = local.zone_id
  name    = "cp.k8s.goldentooth.net"
  type    = "A"
  ttl     = local.default_ttl

  records = [
    "10.4.0.9", # kube-vip VIP for control plane HA
  ]
}
