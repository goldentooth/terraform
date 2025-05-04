module "github_oidc_role_variable" {
  source = "github.com/bitterbridge/terraform-modules//terraform/modules/github_oidc_role_variable?ref=v0.0.1"

  for_each = toset(keys(module.repositories.repositories))

  iam_role_arn    = module.github_oidc.oidc_role
  repository_name = each.key
}
