# Cloudflare account lookup for tunnel resources.
data "cloudflare_accounts" "main" {}

# Random secret used to authenticate the tunnel connector.
resource "random_password" "tunnel_secret" {
  length  = 64
  special = false
}

# Shared Cloudflare Tunnel for routing public traffic to cluster services.
resource "cloudflare_zero_trust_tunnel_cloudflared" "goldentooth" {
  account_id = data.cloudflare_accounts.main.accounts[0].id
  name       = "goldentooth"
  secret     = random_password.tunnel_secret.result
}

# Tunnel ingress configuration — add new services as hostname/service pairs.
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "goldentooth" {
  account_id = data.cloudflare_accounts.main.accounts[0].id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.goldentooth.id

  config = {
    ingress_rules = [
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

output "tunnel_id" {
  description = "Cloudflare Tunnel ID for the goldentooth cluster."
  value       = cloudflare_zero_trust_tunnel_cloudflared.goldentooth.id
}

output "tunnel_token" {
  description = "Cloudflare Tunnel token for the cluster connector."
  value       = cloudflare_zero_trust_tunnel_cloudflared.goldentooth.tunnel_token
  sensitive   = true
}
