resource "aws_kms_key" "custom_key" {
  count                    = var.create_kms ? 1 : 0
  deletion_window_in_days  = var.deletion_window_in_days
  enable_key_rotation      = var.enable_key_rotation
  policy                   = coalesce(var.policy, data.aws_iam_policy_document.kms_policy[0].json)
  description              = var.description
  key_usage                = var.key_usage
  multi_region             = var.multi_region
  customer_master_key_spec = var.customer_master_key_spec
  is_enabled               = var.is_enabled
  tags                     = var.kms_tags
}

resource "aws_kms_alias" "custom_key" {
  for_each = { for k, v in local.aliases : k => v if var.create_kms }

  name          = format("alias/%s-%s", var.master_prefix, each.value.name)
  target_key_id = aws_kms_key.custom_key[0].key_id
}
