# ============================================
# IAM ROLE OUTPUTS
# ============================================
output "iam_role_arn" {
  description = "ARN of IAM role"
  value       = try(aws_iam_role.iam_role[0].arn, "")
}

output "iam_role_name" {
  description = "Name of IAM role"
  value       = try(aws_iam_role.iam_role[0].name, "")
}

output "iam_role_path" {
  description = "Path of IAM role"
  value       = try(aws_iam_role.iam_role[0].path, "")
}

output "iam_role_unique_id" {
  description = "Unique ID of IAM role"
  value       = try(aws_iam_role.iam_role[0].unique_id, "")
}

# ============================================
# SERVICE LINKED ROLE OUTPUTS
# ============================================
output "service_linked_role_arn" {
  description = "List ARN of IAM Service Linked Role"
  value       = { for k, v in aws_iam_service_linked_role.service_linked_role : k => try(v.arn, "") }
}

# ============================================
# INSTANCE PROFILE OUTPUTS
# ============================================
output "iam_instance_profile_arn" {
  description = "ARN assigned by AWS to the instance profile"
  value       = try(aws_iam_instance_profile.instance_profile[0].arn, var.iam_instance_profile_arn)
}

output "iam_instance_profile_id" {
  description = "Instance profile's ID"
  value       = try(aws_iam_instance_profile.instance_profile[0].id, null)
}

output "iam_instance_profile_unique" {
  description = "Stable and unique string identifying the IAM instance profile"
  value       = try(aws_iam_instance_profile.instance_profile[0].unique_id, null)
}