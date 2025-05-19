resource "aws_kms_key" "vault_seal" {
  description             = "KMS key for managing the Goldentooth vault seal"
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = true
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "vault_seal" {
  name          = "alias/goldentooth/vault-seal"
  target_key_id = aws_kms_key.vault_seal.key_id
}
