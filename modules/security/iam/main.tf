# ============================================
# IAM ROLE
# ============================================
resource "aws_iam_role" "iam_role" {
  count = local.create_iam_role ? 1 : 0

  name                 = format("%s-%s-role", var.master_prefix, var.role_name)
  description          = var.role_description
  path                 = var.role_path
  max_session_duration = var.max_session_duration

  force_detach_policies = var.force_detach_policies
  permissions_boundary  = var.role_permissions_boundary_arn

  assume_role_policy = local.assume_role_policy

  tags = var.tags
}

# ============================================
# MANAGED POLICY ATTACHMENTS
# ============================================
resource "aws_iam_role_policy_attachment" "role_policy" {
  count = local.create_iam_role ? length(var.role_policy_arns) : 0

  role       = aws_iam_role.iam_role[0].name
  policy_arn = element(var.role_policy_arns, count.index)
}

# ============================================
# CUSTOM INLINE POLICY
# ============================================
resource "aws_iam_policy" "custom_policy" {
  count = local.create_iam_role && var.custom_policy != null && var.custom_policy != "" ? 1 : 0

  name   = format("%s-%s-policy", var.master_prefix, var.role_name)
  policy = var.custom_policy

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "custom_policy" {
  count = local.create_iam_role && var.custom_policy != null && var.custom_policy != "" ? 1 : 0

  role       = aws_iam_role.iam_role[0].name
  policy_arn = aws_iam_policy.custom_policy[0].arn
}

# ============================================
# SERVICE LINKED ROLE
# ============================================
resource "aws_iam_service_linked_role" "service_linked_role" {
  for_each = { for k, v in var.service_linked : k => v if local.create_service_linked }

  custom_suffix    = each.value.custom_suffix
  aws_service_name = each.value.service_name
  description      = each.value.description
}

# ============================================
# INSTANCE PROFILE
# ============================================
resource "aws_iam_instance_profile" "instance_profile" {
  count = local.create_iam_instance_profile ? 1 : 0
  role  = aws_iam_role.iam_role[0].name

  name = format("%s-%s-role", var.master_prefix, var.role_name)
  path = var.role_path

  tags = var.tags
}