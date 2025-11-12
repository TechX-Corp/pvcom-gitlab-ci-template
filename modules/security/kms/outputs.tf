output "key_arn" {
  value       = try(aws_kms_key.custom_key[0].arn, "")
  description = "KMS Key ARN"
}

output "key_id" {
  value       = try(aws_kms_key.custom_key[0].key_id, "")
  description = "KMS Key ID"
}

output "alias" {
  value       = try(aws_kms_alias.custom_key, {})
  description = "KMS Alias name"
}

output "key_policy" {
  value       = try(aws_kms_key.custom_key[0].policy, "")
  description = "KMS Key Policy"
}
