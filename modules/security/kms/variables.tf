################################################################################
# KMS Variables
################################################################################

variable "create_kms" {
  type        = bool
  default     = true
  description = "Whether to enable Key Management"
  validation {
    condition     = contains([true, false], var.create_kms)
    error_message = "Valid values for variable: create_kms are `true`, `false`."
  }
}

variable "deletion_window_in_days" {
  type        = number
  default     = 30
  description = "Duration in days after which the key is deleted after destruction of the resource."
  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "Valid values for variable: deletion_window_in_days must be between 7 and 30"
  }
}

variable "enable_key_rotation" {
  type        = bool
  default     = true
  description = "Specifies whether key rotation is enabled"
  validation {
    condition     = contains([true, false], var.enable_key_rotation)
    error_message = "Valid values for variable: enable_key_rotation are `true`, `false`."
  }
}

variable "description" {
  type        = string
  default     = "Parameter Store KMS master key"
  description = "The description of the key as viewed in AWS console"
}

variable "aliases" {
  type        = list(string)
  description = "A list of aliases to create."
  validation {
    condition     = length(var.aliases) > 0
    error_message = "Valid values for variable: aliases cannot be empty."
  }
}

variable "policy" {
  type        = string
  default     = null
  description = "A valid KMS policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy."
}

variable "key_usage" {
  type        = string
  default     = "ENCRYPT_DECRYPT"
  description = "Specifies the intended use of the key. Valid values: `ENCRYPT_DECRYPT` or `SIGN_VERIFY`."
  validation {
    condition     = contains(["ENCRYPT_DECRYPT", "SIGN_VERIFY"], var.key_usage)
    error_message = "Valid values for variable: key_usage are `ENCRYPT_DECRYPT`, `SIGN_VERIFY`."
  }
}

variable "customer_master_key_spec" {
  type        = string
  default     = "SYMMETRIC_DEFAULT"
  description = "Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: `SYMMETRIC_DEFAULT`, `RSA_2048`, `RSA_3072`, `RSA_4096`, `ECC_NIST_P256`, `ECC_NIST_P384`, `ECC_NIST_P521`, or `ECC_SECG_P256K1`."
  validation {
    condition     = contains(["SYMMETRIC_DEFAULT", "RSA_2048", "RSA_3072", "RSA_4096", "HMAC_256", "ECC_NIST_P256", "ECC_NIST_P384", "ECC_NIST_P521", "ECC_SECG_P256K1"], var.customer_master_key_spec)
    error_message = "Valid values for variable: customer_master_key_spec are `SYMMETRIC_DEFAULT`, `RSA_2048`, `RSA_3072`, `RSA_4096`, `HMAC_256`, `ECC_NIST_P256`, `ECC_NIST_P384`, `ECC_NIST_P521` , `ECC_SECG_P256K1`."
  }
}

variable "kms_tags" {
  description = "Additional tags for the KMS resource."
  type        = map(string)
  default     = {}
}

variable "service_linked_arn" {
  type        = list(string)
  default     = []
  description = "The list AWS service linked arn to which this role is attached."
  validation {
    condition = (length(var.service_linked_arn) > 0 ? alltrue([
      for arn in var.service_linked_arn : can(regex("^arn:aws:iam::[[:digit:]]{12}:role/.+", arn))
    ]) : length(var.service_linked_arn) == 0)
    error_message = "Valid values for variable: all value must be valid AWS service-linked arn. (ex: arn:aws:iam::302010997939:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling)"
  }
}

variable "aws_services" {
  type = list(string)
  default = [
    "vpc-flow-logs",
    "delivery.logs",
    "cloudtrail",
    "logs"
  ]
  description = "The list AWS service use CMK. For example: [logs, lambda]"
}

variable "kms_via_services" {
  type = list(string)
  default = [
    "ec2"
  ]
  description = "The list Via AWS service use CMK. For example: [ec2, rds]"
}

variable "enable_route53_dnssec" {
  description = "Determines whether the KMS policy used for Route53 DNSSEC signing is enabled"
  type        = bool
  default     = false
}

variable "route53_dnssec_sources" {
  description = "A list of maps containing `account_ids` and Route53 `hosted_zone_arn` that will be allowed to sign DNSSEC records"
  type        = list(any)
  default     = []
}

variable "multi_region" {
  description = "Indicates whether the KMS key is a multi-Region (`true`) or regional (`false`) key. Defaults to `false`"
  type        = bool
  default     = false
  validation {
    condition     = contains([true, false], var.multi_region)
    error_message = "Valid values for variable: multi_region are `true`, `false`."
  }
}

variable "is_enabled" {
  description = "Specifies whether the key is enabled. Defaults to `true`"
  type        = bool
  default     = true
  validation {
    condition     = contains([true, false], var.is_enabled)
    error_message = "Valid values for variable: is_enabled are `true`, `false`."
  }
}

variable "master_prefix" {
  description = "To specify a key prefix for aws resource"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.master_prefix))
    error_message = "Valid values for variable: master_prefix cannot be empty."
  }
}
