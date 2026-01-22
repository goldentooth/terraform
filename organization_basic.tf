module "repositories" {
  source = "github.com/bitterbridge/terraform-modules//terraform/modules/repositories?ref=v0.0.432"

  organization_name = "goldentooth"
}

module "organization_basic" {
  source = "github.com/bitterbridge/terraform-modules//terraform/modules/organization_basic?ref=v0.0.432"

  organization_name = "goldentooth"
  repositories      = keys(module.repositories.repositories)
}
