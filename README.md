# Terraform Infrastructure

Infrastructure-as-Code for Goldentooth cloud resources, managing DNS and GitHub organization configuration for the Raspberry Pi cluster.

## Structure

```
terraform/
├── main.tf                 # Providers (AWS, GitHub) and S3 backend
├── locals.tf               # Shared values (domain, zone_id, ttl)
├── bare_domain.tf          # Apex domain redirect module
├── github_pages.tf         # CNAME for clog.goldentooth.net
├── k8s_control_plane.tf    # A record for control plane VIP
├── organization_basic.tf   # GitHub organization management
└── modules/
    └── bare_domain/        # CloudFront + ACM + S3 for apex redirect
```

## What This Manages

### DNS Records (Route53)
- `goldentooth.net` → CloudFront distribution (redirects to clog)
- `clog.goldentooth.net` → GitHub Pages (`goldentooth.github.io`)
- `cp.k8s.goldentooth.net` → `10.4.0.9` (kube-vip control plane VIP)

### Apex Domain Redirect (`modules/bare_domain/`)
- **ACM Certificate**: Wildcard cert for `*.goldentooth.net`
- **CloudFront Distribution**: Serves the apex domain with geo-restrictions
- **CloudFront Function**: 301 redirect to `clog.goldentooth.net`
- **S3 Bucket**: Origin bucket (unused, CloudFront function handles redirect)

### GitHub Organization
Uses external [Bitterbridge terraform-modules](https://github.com/bitterbridge/terraform-modules) to manage:
- Repository configuration
- Organization settings

## State Management

```hcl
backend "s3" {
  bucket       = "goldentooth.terraform"
  key          = "terraform.tfstate"
  region       = "us-east-1"
  use_lockfile = true
}
```

## Usage

```bash
terraform init
terraform plan
terraform apply
```

Requires:
- Terraform 1.11.0 (see `.terraform-version`)
- AWS credentials with Route53, CloudFront, ACM, S3 access
- GitHub token with org admin access
