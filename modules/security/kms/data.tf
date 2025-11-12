data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "kms_policy" {
  count = var.create_kms ? 1 : 0

  # Root account full access
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  # Service-linked roles access
  dynamic "statement" {
    for_each = length(var.service_linked_arn) > 0 ? [1] : []
    content {
      sid    = "Allow service-linked role use of the CMK"
      effect = "Allow"
      principals {
        type        = "AWS"
        identifiers = var.service_linked_arn
      }
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:CreateGrant",
        "kms:DescribeKey"
      ]
      resources = ["*"]
    }
  }

  # AWS Services access
  dynamic "statement" {
    for_each = length(local.aws_services) > 0 ? [1] : []
    content {
      sid    = "Allow AWS Services to use the key"
      effect = "Allow"
      principals {
        type        = "Service"
        identifiers = local.aws_services
      }
      actions = [
        "kms:Decrypt",
        "kms:GenerateDataKey",
        "kms:CreateGrant"
      ]
      resources = ["*"]
    }
  }

  # Via Services access (e.g., EC2, RDS)
  dynamic "statement" {
    for_each = length(local.kms_via_services) > 0 ? [1] : []
    content {
      sid    = "Allow attachment of persistent resources"
      effect = "Allow"
      principals {
        type        = "AWS"
        identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      }
      actions = [
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant"
      ]
      resources = ["*"]
      condition {
        test     = "StringEquals"
        variable = "kms:ViaService"
        values   = local.kms_via_services
      }
    }
  }

  # Route53 DNSSEC
  dynamic "statement" {
    for_each = var.enable_route53_dnssec ? [1] : []
    content {
      sid    = "Allow Route 53 DNSSEC Service"
      effect = "Allow"
      principals {
        type        = "Service"
        identifiers = ["dnssec-route53.amazonaws.com"]
      }
      actions = [
        "kms:DescribeKey",
        "kms:GetPublicKey",
        "kms:Sign",
      ]
      resources = ["*"]
    }
  }

  dynamic "statement" {
    for_each = var.enable_route53_dnssec ? [1] : []
    content {
      sid    = "Allow Route 53 DNSSEC Service to CreateGrant"
      effect = "Allow"
      principals {
        type        = "Service"
        identifiers = ["dnssec-route53.amazonaws.com"]
      }
      actions   = ["kms:CreateGrant"]
      resources = ["*"]
      condition {
        test     = "Bool"
        variable = "kms:GrantIsForAWSResource"
        values   = ["true"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.enable_route53_dnssec ? var.route53_dnssec_sources : []
    content {
      sid    = "Allow Route 53 DNSSEC Customer Account(s) ${statement.key}"
      effect = "Allow"
      principals {
        type        = "AWS"
        identifiers = try(statement.value.account_ids, ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"])
      }
      actions = [
        "kms:DescribeKey",
        "kms:GetPublicKey",
        "kms:Sign",
        "kms:CreateGrant",
      ]
      resources = ["*"]
      condition {
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values   = try(statement.value.account_ids, [data.aws_caller_identity.current.account_id])
      }
      dynamic "condition" {
        for_each = try([statement.value.hosted_zone_arn], [])
        content {
          test     = "ArnEquals"
          variable = "aws:SourceArn"
          values   = [condition.value]
        }
      }
    }
  }
}
