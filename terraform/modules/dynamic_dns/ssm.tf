data "aws_kms_key" "ssm_default" {
  key_id = "alias/aws/ssm"
}

resource "aws_ssm_parameter" "credentials" {
  name   = "/goldentooth/cluster/dynamic_dns/credentials"
  type   = "SecureString"
  value  = "CHANGE:ME"
  key_id = data.aws_kms_key.ssm_default.id

  lifecycle {
    ignore_changes = [value]
  }
}
