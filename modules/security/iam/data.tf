# ============================================
# COMMON DATA SOURCES
# ============================================
data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

# ============================================
# IRSA TRUST POLICY (for EKS Service Accounts)
# ============================================
data "aws_iam_policy_document" "assume_role_with_oidc" {
  count = var.create_role && var.role_type == "irsa" ? 1 : 0

  dynamic "statement" {
    for_each = local.urls

    content {
      effect = "Allow"

      actions = ["sts:AssumeRoleWithWebIdentity"]

      principals {
        type = "Federated"

        identifiers = ["arn:${data.aws_partition.current.partition}:iam::${local.aws_account_id}:oidc-provider/${replace(statement.value, "/^(.*provider/)/", "")}"]
      }

      dynamic "condition" {
        for_each = length(var.oidc_fully_qualified_subjects) > 0 ? local.urls : []

        content {
          test     = "StringEquals"
          variable = "${replace(statement.value, "/^(.*provider/)/", "")}:sub"
          values   = var.oidc_fully_qualified_subjects
        }
      }

      dynamic "condition" {
        for_each = length(var.oidc_subjects_with_wildcards) > 0 ? local.urls : []

        content {
          test     = "StringLike"
          variable = "${replace(statement.value, "/^(.*provider/)/", "")}:sub"
          values   = var.oidc_subjects_with_wildcards
        }
      }

      dynamic "condition" {
        for_each = length(var.oidc_fully_qualified_audiences) > 0 ? local.urls : []

        content {
          test     = "StringLike"
          variable = "${replace(statement.value, "/^(.*provider/)/", "")}:aud"
          values   = var.oidc_fully_qualified_audiences
        }
      }
    }
  }
}

# ============================================
# ASSUME ROLE TRUST POLICY (Standard)
# ============================================
data "aws_iam_policy_document" "assume_role" {
  count = var.create_role && (var.role_type == "assume-role" || var.role_type == "instance-profile") ? 1 : 0

  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "AWS"
      identifiers = var.trusted_role_arns
    }

    principals {
      type        = "Service"
      identifiers = var.trusted_role_services
    }

    dynamic "condition" {
      for_each = length(var.trusted_principal_arns) > 0 ? var.trusted_principal_arns : []

      content {
        test     = "ArnLike"
        variable = "aws:PrincipalArn"
        values   = var.trusted_principal_arns
      }
    }
  }
}

# ============================================
# ASSUME ROLE WITH MFA TRUST POLICY
# ============================================
data "aws_iam_policy_document" "assume_role_with_mfa" {
  count = var.create_role && var.role_type == "assume-role" && var.role_requires_mfa ? 1 : 0

  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = var.trusted_role_arns
    }

    principals {
      type        = "Service"
      identifiers = var.trusted_role_services
    }

    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }

    condition {
      test     = "NumericLessThan"
      variable = "aws:MultiFactorAuthAge"
      values   = [var.mfa_age]
    }
  }
}