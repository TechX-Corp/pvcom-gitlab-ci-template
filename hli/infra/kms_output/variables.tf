# ============================================
# DEPLOYMENT VARIABLES
# ============================================

variable "create_kms" {
  type        = bool
  default     = true
  description = "Whether to create KMS key"
}

variable "master_prefix" {
  description = "Resource prefix"
  type        = string
  default     = "dso"
}

variable "description" {
  type        = string
  default     = "Parameter Store KMS master key"
  description = "KMS key description"
}

variable "deletion_window_in_days" {
  type        = number
  default     = 30
  description = "Deletion window in days (7-30)"
}

variable "enable_key_rotation" {
  type        = bool
  default     = true
  description = "Enable automatic key rotation"
}

variable "key_usage" {
  type        = string
  default     = "ENCRYPT_DECRYPT"
  description = "Key usage type"
}

variable "customer_master_key_spec" {
  type        = string
  default     = "SYMMETRIC_DEFAULT"
  description = "Key specification"
}

variable "multi_region" {
  description = "Multi-region key"
  type        = bool
  default     = false
}

variable "is_enabled" {
  description = "Enable the key"
  type        = bool
  default     = true
}

variable "aliases" {
  type        = list(string)
  description = "List of key aliases"
  default     = []
}

variable "policy" {
  type        = string
  default     = null
  description = "Custom KMS policy JSON"
}

variable "service_linked_arn" {
  type        = list(string)
  default     = []
  description = "Service-linked role ARNs"
}

variable "aws_services" {
  type        = list(string)
  default     = ["logs"]
  description = "AWS services that can use this key"
}

variable "kms_via_services" {
  type        = list(string)
  default     = ["ec2"]
  description = "Services that can use key via grants"
}

variable "enable_route53_dnssec" {
  description = "Enable Route53 DNSSEC"
  type        = bool
  default     = false
}

variable "route53_dnssec_sources" {
  description = "Route53 DNSSEC sources"
  type        = list(any)
  default     = []
}

variable "kms_tags" {
  description = "Additional KMS tags"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-southeast-1"
}

variable "assume_role" {
  description = "AssumeRole ARN"
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "development"
}

variable "division_tags" {
  description = "Division tags"
  type        = map(string)
  default     = {}
}

variable "global_tags" {
  description = "Global tags"
  type        = map(string)
  default     = {}
}
