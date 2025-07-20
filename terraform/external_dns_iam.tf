# IAM Policy for External-DNS
# This allows the Kubernetes external-dns controller to manage Route53 records

# Create IAM policy for external-dns
resource "aws_iam_policy" "external_dns" {
  name        = "goldentooth-external-dns"
  description = "Policy for Kubernetes external-dns to manage Route53 records"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets"
        ]
        Resource = [
          "arn:aws:route53:::hostedzone/${local.zone_id}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:ListTagsForResource"
        ]
        Resource = ["*"]
      }
    ]
  })

  tags = {
    Purpose = "external-dns"
    Cluster = "goldentooth"
  }
}

# If using IRSA (IAM Roles for Service Accounts)
# Disabled until EKS OIDC provider is configured
# resource "aws_iam_role" "external_dns" {
#   name = "goldentooth-external-dns"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/YOUR_EKS_OIDC_PROVIDER"
#         }
#         Action = "sts:AssumeRoleWithWebIdentity"
#         Condition = {
#           StringEquals = {
#             "YOUR_EKS_OIDC_PROVIDER:sub" = "system:serviceaccount:external-dns:external-dns"
#             "YOUR_EKS_OIDC_PROVIDER:aud" = "sts.amazonaws.com"
#           }
#         }
#       }
#     ]
#   })
# }

# Attach policy to role
# resource "aws_iam_role_policy_attachment" "external_dns" {
#   policy_arn = aws_iam_policy.external_dns.arn
#   role       = aws_iam_role.external_dns.name
# }

# Output for external-dns configuration
output "external_dns_config" {
  description = "Configuration values for external-dns"
  value = {
    policy_arn     = aws_iam_policy.external_dns.arn
    zone_id        = local.zone_id
    domain_filter  = module.k8s_service_dns.external_dns_filter_domain
    txt_owner_id   = "k8s-cluster"
  }
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}