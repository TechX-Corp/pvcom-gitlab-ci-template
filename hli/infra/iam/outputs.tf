# ============================================
# IAM ROLE OUTPUTS
# ============================================

output "iam_role_arn" {
  description = "ARN of IAM role"
  value       = module.pvcom_demo_role.iam_role_arn # ← Đổi từ module.iam
}

output "iam_role_name" {
  description = "Name of IAM role"
  value       = module.pvcom_demo_role.iam_role_name
}

output "iam_role_path" {
  description = "Path of IAM role"
  value       = module.pvcom_demo_role.iam_role_path
}

output "iam_role_unique_id" {
  description = "Unique ID of IAM role"
  value       = module.pvcom_demo_role.iam_role_unique_id
}

# ============================================
# SERVICE LINKED ROLE OUTPUTS
# ============================================

output "service_linked_role_arn" {
  description = "ARN of IAM Service Linked Role"
  value       = module.pvcom_demo_role.service_linked_role_arn
}

# ============================================
# INSTANCE PROFILE OUTPUTS
# ============================================

output "iam_instance_profile_arn" {
  description = "ARN assigned by AWS to the instance profile"
  value       = module.pvcom_demo_role.iam_instance_profile_arn
}

output "iam_instance_profile_id" {
  description = "Instance profile's ID"
  value       = module.pvcom_demo_role.iam_instance_profile_id
}

output "iam_instance_profile_unique" {
  description = "Stable and unique string identifying the IAM instance profile"
  value       = module.pvcom_demo_role.iam_instance_profile_unique
}
