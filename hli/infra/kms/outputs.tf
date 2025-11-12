# ============================================
# KMS KEY OUTPUTS
# ============================================

output "key_arn" {
  description = "ARN of KMS key"
  value       = module.kms.key_arn
}

output "key_id" {
  description = "ID of KMS key"
  value       = module.kms.key_id
}

output "alias" {
  description = "KMS key aliases"
  value       = module.kms.alias
}

output "key_policy" {
  description = "KMS key policy"
  value       = module.kms.key_policy
  sensitive   = true
}
