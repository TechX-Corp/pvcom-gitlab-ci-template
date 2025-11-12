
output "kms_key_arn" {
  value = data.terraform_remote_state.kms.outputs.key_arn
}
