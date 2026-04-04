# Random secret used to authenticate the tunnel connector.
resource "random_password" "tunnel_secret" {
  length  = 32
  special = false
}

# Shared Cloudflare Tunnel for routing public traffic to cluster services.
resource "cloudflare_zero_trust_tunnel_cloudflared" "goldentooth" {
  account_id    = local.cloudflare_account_id
  name          = "goldentooth"
  tunnel_secret = base64encode(random_password.tunnel_secret.result)
  config_src    = "cloudflare"
}

# Tunnel ingress configuration — add new services as hostname/service pairs.
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "goldentooth" {
  account_id = local.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.goldentooth.id

  config = {
    ingress = [
      # PDS (AT Protocol Personal Data Server)
      {
        hostname = "pds.goldentooth.net"
        service  = "http://pds.pds.svc.cluster.local:3000"
      },
      {
        hostname = "*.pds.goldentooth.net"
        service  = "http://pds.pds.svc.cluster.local:3000"
      },
      # Catch-all — must be last
      {
        service = "http_status:404"
      },
    ]
  }
}

# Construct the tunnel token (base64-encoded JSON of account, tunnel ID, and secret).
locals {
  tunnel_token = base64encode(jsonencode({
    a = local.cloudflare_account_id
    t = cloudflare_zero_trust_tunnel_cloudflared.goldentooth.id
    s = base64encode(random_password.tunnel_secret.result)
  }))
}

output "tunnel_id" {
  description = "Cloudflare Tunnel ID for the goldentooth cluster."
  value       = cloudflare_zero_trust_tunnel_cloudflared.goldentooth.id
}

output "tunnel_token" {
  description = "Cloudflare Tunnel token for the cluster connector."
  value       = local.tunnel_token
  sensitive   = true
}
