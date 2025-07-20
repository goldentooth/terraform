# Cluster DNS Module

This module manages DNS records for the Goldentooth cluster using a single Route53 hosted zone.

## DNS Architecture

### Domain Categories

1. **External Services** (`*.goldentooth.net`)
   - `clog.goldentooth.net` - Documentation site (external)
   - `clearbrook.goldentooth.net` - Dynamic home IP
   - `home-proxy.goldentooth.net` - CloudFront proxy

2. **Node Direct Access** (`<node>.goldentooth.net`)
   - Direct A records to node private IPs
   - Example: `allyrion.goldentooth.net` → `10.4.0.10`

3. **Node Homepages** (`*.nodes.goldentooth.net`)
   - All resolve to HAProxy (`10.4.0.10`)
   - HAProxy uses SNI to route to correct node
   - Example: `allyrion.nodes.goldentooth.net` → HAProxy → `allyrion:443`

4. **Cluster Services** (`*.services.goldentooth.net`)
   - All resolve to HAProxy (`10.4.0.10`)
   - HAProxy routes based on service configuration
   - Example: `consul.services.goldentooth.net` → HAProxy → Consul cluster

5. **Kubernetes Services** (`*.services.k8s.goldentooth.net`)
   - Managed by external-dns or Terraform
   - Point to MetalLB LoadBalancer IPs
   - Example: `argocd.services.k8s.goldentooth.net` → `10.4.11.10`

6. **Nomad Services** (`*.services.nomad.goldentooth.net`)
   - All resolve to HAProxy (`10.4.0.10`)
   - HAProxy integrates with Nomad for service discovery

7. **Public Proxy** (`*.home-proxy.goldentooth.net`)
   - CloudFront distributions for external access
   - Forward to `clearbrook.goldentooth.net` endpoints

## Usage

```hcl
module "cluster_dns" {
  source = "./modules/cluster_dns"

  zone_id     = "Z0736727S7ZH91VKK44A"
  domain_name = "goldentooth.net"
  haproxy_ip  = "10.4.0.10"
  
  nodes = {
    allyrion = "10.4.0.10"
    bettley  = "10.4.0.11"
    # ... etc
  }
}
```

## DNS Resolution Flow

```
External Client → Route53 → CloudFront → clearbrook → HAProxy → Service
Internal Client → Route53 → HAProxy → Service
K8s Service     → Route53 → MetalLB IP → Service
```

## Integration with External-DNS

The Kubernetes external-dns controller can be configured to manage records in:
- `services.k8s.goldentooth.net` - Set `--domain-filter=services.k8s.goldentooth.net`
- Uses TXT records for ownership tracking
- Requires IAM permissions to modify Route53 zone

## Monitoring

All DNS endpoints are monitored by Prometheus Blackbox Exporter:
- DNS resolution tests
- HTTP/HTTPS endpoint checks
- TCP connectivity verification