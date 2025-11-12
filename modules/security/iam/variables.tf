# ============================================
# CORE ROLE CONFIGURATION
# ============================================
variable "create_role" {
  description = "Whether to create a role"
  type        = bool
  default     = false
  validation {
    condition     = contains([true, false], var.create_role)
    error_message = "Valid values for variable: create_role are `true`, `false`."
  }
}

variable "role_type" {
  description = "The type of IAM role will be created. Valid values: `irsa`, `assume-role`, `service-linked`, `instance-profile`"
  type        = string
  default     = "irsa"
  validation {
    condition     = contains(["irsa", "assume-role", "service-linked", "instance-profile"], var.role_type)
    error_message = "Valid values for var: role_type are `irsa`, `assume-role`, `service-linked`, `instance-profile`"
  }
}

variable "role_name" {
  description = "IAM role name"
  type        = string
  default     = "pvcom-demo"
}

variable "role_description" {
  description = "IAM Role description"
  type        = string
  default     = null
}

variable "role_path" {
  description = "Path of IAM role"
  type        = string
  default     = "/"
}

variable "role_permissions_boundary_arn" {
  description = "Permissions boundary ARN to use for IAM role"
  type        = string
  default     = null
}

variable "max_session_duration" {
  description = "Maximum CLI/API session duration in seconds between 3600 and 43200"
  type        = number
  default     = 3600
  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "Valid values for variable: max_session_duration must be between 3600 and 43200."
  }
}

variable "role_policy_arns" {
  description = "List of ARNs of IAM policies to attach to IAM role"
  type        = list(string)
  default     = []
}

variable "force_detach_policies" {
  description = "Whether policies should be detached from this role when destroying"
  type        = bool
  default     = false
  validation {
    condition     = contains([true, false], var.force_detach_policies)
    error_message = "Valid values for variable: force_detach_policies are `true`, `false`."
  }
}

variable "custom_policy" {
  type        = string
  default     = null
  description = "The policy document. This is a JSON formatted string."
}

variable "custom_trust_policy" {
  description = "Custom trust relationship policy JSON. If specified, this will override the default assume role policy."
  type        = string
  default     = null
}

# ============================================
# IRSA (IAM Role for Service Account)
# ============================================
variable "provider_urls" {
  description = "List of URLs of the OIDC Providers"
  type        = list(string)
  default     = []
}

variable "aws_account_id" {
  description = "The AWS account ID where the OIDC provider lives, leave empty to use the account for the AWS provider"
  type        = string
  default     = null
}

variable "oidc_fully_qualified_subjects" {
  description = "The fully qualified OIDC subjects to be added to the role policy"
  type        = set(string)
  default     = []
}

variable "oidc_subjects_with_wildcards" {
  description = "The OIDC subject using wildcards to be added to the role policy"
  type        = set(string)
  default     = []
}

variable "oidc_fully_qualified_audiences" {
  description = "The audience to be added to the role policy. Set to sts.amazonaws.com for cross-account assumable role. Leave empty otherwise."
  type        = set(string)
  default     = []
}

# ============================================
# ASSUME ROLE CONFIGURATION
# ============================================
variable "trusted_role_arns" {
  description = "ARNs of AWS entities who can assume these roles"
  type        = list(string)
  default     = []
}

variable "trusted_role_services" {
  description = "AWS Services that can assume these roles"
  type        = list(string)
  default     = []
}

variable "trusted_principal_arns" {
  description = "PrincipalArn that can assume these roles (in condition block)"
  type        = list(string)
  default     = []
}

variable "mfa_age" {
  description = "Max age of valid MFA (in seconds) for roles which require MFA"
  type        = number
  default     = 86400
  validation {
    condition     = var.mfa_age >= 3600 && var.mfa_age <= 86400
    error_message = "Valid values for variable: mfa_age must be between 3600 and 86400."
  }
}

variable "role_requires_mfa" {
  description = "Whether admin role requires MFA"
  type        = bool
  default     = false
  validation {
    condition     = contains([true, false], var.role_requires_mfa)
    error_message = "Valid values for variable: role_requires_mfa are `true`, `false`."
  }
}

# ============================================
# SERVICE LINKED ROLE
# ============================================
variable "service_linked" {
  type = map(object({
    service_name  = string
    custom_suffix = optional(string)
    description   = optional(string)
  }))
  description = <<-EOF
  A service-linked role is a unique type of IAM role that is linked directly to an AWS service.
  **service_linked options:**
  - `service_name`   = (Optional|string) The AWS service to which this role is attached. You use a string similar to a URL but without the http:// in front. For example: elasticbeanstalk.amazonaws.com.
  - `custom_suffix`  = (Optional|string) Additional string appended to the role name. Not all AWS services support custom suffixes.
  - `description`    = (Optional|string) The description of the role.
  EOF
  default     = {}
}

# ============================================
# INSTANCE PROFILE
# ============================================
variable "iam_instance_profile_arn" {
  description = "Amazon Resource Name (ARN) of an existing IAM instance profile. Used when `role_type` is not `instance-profile` or `create_role` = false"
  type        = string
  default     = null
  validation {
    condition     = var.iam_instance_profile_arn != null ? can(regex("^arn:aws:iam::[[:digit:]]{12}:instance-profile/.+", var.iam_instance_profile_arn)) : true
    error_message = "Valid values for variable: must be a valid AWS IAM role ARN. (ex: arn:aws:iam::336924118301:instance-profile/ExampleInstanceProfile)"
  }
}

# ============================================
# COMMON VARIABLES
# ============================================
variable "master_prefix" {
  description = "To specify a key prefix for aws resource"
  type        = string
  default     = "dso"
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.master_prefix))
    error_message = "Valid values for variable: master_prefix cannot be empty."
  }
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}