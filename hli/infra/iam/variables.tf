# ============================================
# DEPLOYMENT VARIABLES
# ============================================

variable "create_role" {
  description = "Whether to create a role"
  type        = bool
  default     = true
}

variable "role_type" {
  description = "The type of IAM role"
  type        = string
  default     = "assume-role"
}

variable "role_name" {
  description = "IAM role name"
  type        = string
}

variable "role_description" {
  description = "IAM Role description"
  type        = string
  default     = null
}

variable "master_prefix" {
  description = "Resource prefix"
  type        = string
  default     = "dso"
}

variable "trusted_role_services" {
  description = "AWS Services that can assume these roles"
  type        = list(string)
  default     = []
}

variable "trusted_role_arns" {
  description = "ARNs of AWS entities who can assume these roles"
  type        = list(string)
  default     = []
}

variable "role_policy_arns" {
  description = "List of ARNs of IAM policies to attach"
  type        = list(string)
  default     = []
}

variable "custom_policy" {
  description = "Custom policy JSON"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-southeast-1"
}

variable "assume_role" {
  description = "AssumeRole ARN for deployment"
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "development"
}
