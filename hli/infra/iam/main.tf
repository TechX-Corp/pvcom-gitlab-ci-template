module "pvcom_demo_role" {
  source = "../../../modules/security/iam"

  # Core configuration
  create_role      = var.create_role
  role_type        = var.role_type
  role_name        = var.role_name
  role_description = var.role_description
  master_prefix    = var.master_prefix

  # Trust relationships
  trusted_role_services = var.trusted_role_services
  trusted_role_arns     = var.trusted_role_arns

  # Policy attachments
  role_policy_arns = var.role_policy_arns
  custom_policy    = var.custom_policy

  # Tags
  tags = var.tags
}

## TRigger pipeline
## TRigger pipeline
