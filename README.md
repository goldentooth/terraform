# Terraform Infrastructure

Infrastructure-as-Code for Goldentooth cloud resources, providing AWS-based services that support the on-premises Raspberry Pi cluster.

## Overview

This Terraform configuration manages cloud infrastructure that complements the Goldentooth cluster, including DNS management, SSL certificates, dynamic DNS services, and secure cloud integrations.

## Architecture

### Cloud Integration Strategy
The Goldentooth cluster is primarily on-premises but leverages AWS for:
- **DNS Management**: Route53 hosted zones for `goldentooth.net`
- **SSL Certificates**: ACM certificates with automatic renewal
- **Dynamic DNS**: Lambda-based IP address updates
- **Content Delivery**: CloudFront distributions for static sites
- **Secret Management**: KMS keys for HashiCorp Vault seal

## Terraform Modules

### `bare_domain/`
**Purpose**: Manage the root domain `goldentooth.net`
- **Route53**: Hosted zone and DNS records
- **ACM**: SSL certificate for apex domain
- **CloudFront**: CDN distribution for static content
- **S3**: Origin bucket for website assets
- **Edge Functions**: Lambda@Edge for redirects

### `cloud_proxy/`
**Purpose**: Reverse proxy configuration via CloudFront
- **ACM**: Wildcard certificates for subdomains
- **CloudFront**: Edge locations for performance
- **Route53**: CNAME records for custom domains
- **Origin**: On-premises cluster endpoints

### `cluster_dns/`
**Purpose**: DNS records for cluster services
- **Route53**: A/CNAME records for services
- **Health Checks**: Route53 health monitoring
- **Failover**: DNS-based traffic routing
- **External Integration**: ExternalDNS automation

### `dynamic_dns/`
**Purpose**: Automatic public IP address updates
- **Lambda**: Python function for IP detection
- **API Gateway**: HTTP endpoint for IP updates
- **Route53**: Dynamic A record updates
- **SSM**: Parameter store for configuration
- **IAM**: Least-privilege access roles

### `vault_seal/`
**Purpose**: AWS KMS auto-unseal for HashiCorp Vault
- **KMS**: Customer-managed encryption keys
- **IAM**: Vault instance access policies
- **Cross-Region**: Multi-region key replication
- **Audit**: CloudTrail integration for key usage

## State Management

### Remote State
```hcl
backend "s3" {
  bucket       = "goldentooth.terraform"
  key          = "terraform.tfstate"
  region       = "us-east-1"
  use_lockfile = true
}
```

### State Isolation
- **Production**: Single environment approach
- **Locking**: DynamoDB table for state locking
- **Versioning**: S3 versioning for state history
- **Encryption**: AES-256 server-side encryption

## Key Resources

### DNS Infrastructure
```hcl
# Primary hosted zone
resource "aws_route53_zone" "main" {
  name = "goldentooth.net"
}

# Dynamic DNS record
resource "aws_route53_record" "home" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "home.goldentooth.net"
  type    = "A"
  ttl     = 300
}
```

### SSL Certificates
```hcl
# Wildcard certificate
resource "aws_acm_certificate" "wildcard" {
  domain_name               = "*.goldentooth.net"
  subject_alternative_names = ["goldentooth.net"]
  validation_method         = "DNS"
}
```

### CloudFront Distribution
```hcl
resource "aws_cloudfront_distribution" "main" {
  origin {
    domain_name = "home.goldentooth.net"
    origin_id   = "cluster-origin"
    
    custom_origin_config {
      http_port  = 80
      https_port = 443
    }
  }
}
```

## Deployment

### Prerequisites
- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- Access to `goldentooth.terraform` S3 bucket

### Commands
```bash
# Initialize Terraform
terraform init

# Plan changes
terraform plan

# Apply infrastructure
terraform apply

# Destroy resources (careful!)
terraform destroy
```

### Environment Variables
```bash
export AWS_REGION=us-east-1
export TF_VAR_domain_name="goldentooth.net"
export TF_VAR_cluster_ip="$(curl -s ifconfig.me)"
```

## Integration with Cluster

### ExternalDNS
Terraform-managed Route53 zones are used by ExternalDNS for automatic service DNS records:
```yaml
# ExternalDNS configuration
args:
  - --provider=aws
  - --aws-zone-type=public
  - --domain-filter=goldentooth.net
```

### Dynamic DNS Updates
Cluster services can update their public IP via the Lambda endpoint:
```bash
curl -X POST https://api.goldentooth.net/update-ip \
  -H "Content-Type: application/json" \
  -d '{"ip": "1.2.3.4"}'
```

### Vault Auto-Unseal
HashiCorp Vault uses AWS KMS for automatic unsealing:
```hcl
seal "awskms" {
  region     = "us-east-1"
  kms_key_id = "arn:aws:kms:us-east-1:..."
}
```

## Monitoring

### Cost Management
- **Billing Alerts**: CloudWatch alarms for cost thresholds
- **Resource Tagging**: Consistent tagging for cost allocation
- **Usage Reports**: AWS Cost Explorer integration

### Health Monitoring
- **Route53 Health Checks**: Endpoint availability monitoring
- **CloudWatch Metrics**: Lambda function performance
- **CloudTrail**: API call auditing and security monitoring

## Security

### IAM Best Practices
- **Least Privilege**: Minimal required permissions
- **Role-Based Access**: Service-specific IAM roles
- **MFA Requirements**: Multi-factor authentication for console access
- **Access Keys**: Short-lived credentials via IAM roles

### Network Security
- **CloudFront**: WAF integration for web application firewall
- **Security Groups**: Restrictive ingress/egress rules
- **VPC**: Private subnets for sensitive resources
- **Encryption**: Data encryption in transit and at rest
