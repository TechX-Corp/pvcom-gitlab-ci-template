locals {
  # Account ID resolution
  aws_account_id = var.aws_account_id != null && var.aws_account_id != "" ? var.aws_account_id : data.aws_caller_identity.current.account_id
  
  # Clean OIDC provider URLs (remove https://)
  urls = [
    for url in compact(var.provider_urls) :
    replace(url, "https://", "")
  ]
  
  # Determine assume role policy based on role type and custom policy
  assume_role_policy = var.custom_trust_policy != null ? var.custom_trust_policy : (
    var.create_role && var.role_type == "irsa" ? data.aws_iam_policy_document.assume_role_with_oidc[0].json : (
      var.create_role && (var.role_type == "assume-role" || var.role_type == "instance-profile") ?
      try(data.aws_iam_policy_document.assume_role_with_mfa[0].json, data.aws_iam_policy_document.assume_role[0].json, "") : ""
    )
  )
  
  # Feature flags for conditional resource creation
  create_iam_role             = var.create_role && var.role_type != "service-linked" ? true : false
  create_service_linked       = var.create_role && var.role_type == "service-linked" ? true : false
  create_iam_instance_profile = var.create_role && var.role_type == "instance-profile" ? true : false
}