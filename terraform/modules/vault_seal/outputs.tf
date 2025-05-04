output "alias_name" {
  description = "The KMS alias of the vault seal key."
  value       = aws_kms_alias.vault_seal.name
}
