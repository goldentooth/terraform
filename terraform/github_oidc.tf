module "github_oidc" {
  source  = "terraform-module/github-oidc-provider/aws"
  version = "2.2.1"

  create_oidc_provider      = false
  oidc_provider_arn         = "arn:aws:iam::665449637458:oidc-provider/token.actions.githubusercontent.com"
  create_oidc_role          = true
  repositories              = [for repository in toset(keys(module.repositories.repositories)) : "goldentooth/${repository}"]
  oidc_role_attach_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  role_name                 = "goldentooth-github-oidc"
}

output "github_oidc_role" {
  value = module.github_oidc.oidc_role
}
