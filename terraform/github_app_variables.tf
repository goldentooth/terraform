module "github_app_variables" {
  source = "github.com/bitterbridge/terraform-modules//terraform/modules/github_app_variables?ref=v0.0.3"

  for_each = toset(keys(module.repositories.repositories))

  organization_name = "goldentooth"
  repository_name   = each.key
}
