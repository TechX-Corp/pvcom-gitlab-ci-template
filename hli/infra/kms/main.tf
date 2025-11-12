# ============================================
# KMS KEY DEPLOYMENT FOR HLI ENVIRONMENT
# ============================================

module "kms" {
  source = "../../../modules/security/kms"

  # Core configuration
  create_kms              = var.create_kms
  master_prefix           = var.master_prefix
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation

  # Key specifications
  key_usage                = var.key_usage
  customer_master_key_spec = var.customer_master_key_spec
  multi_region             = var.multi_region
  is_enabled               = var.is_enabled

  # Aliases
  aliases = var.aliases

  # Policy
  policy = var.policy

  # Service access
  service_linked_arn = var.service_linked_arn
  aws_services       = var.aws_services
  kms_via_services   = var.kms_via_services

  # Route53 DNSSEC
  enable_route53_dnssec  = var.enable_route53_dnssec
  route53_dnssec_sources = var.route53_dnssec_sources

  # Tags
  kms_tags = var.kms_tags
}

## Trigger pipeline
