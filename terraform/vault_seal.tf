module "vault_seal" {
  source = "./modules/vault_seal"
}

output "vault_seal_alias" {
  description = "The KMS alias of the vault seal key."
  value       = module.vault_seal.alias_name
}
