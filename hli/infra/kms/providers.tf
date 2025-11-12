terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.1.0, < 6.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  dynamic "assume_role" {
    for_each = var.assume_role != null && var.assume_role != "" ? ["role"] : []
    content {
      role_arn = var.assume_role
    }
  }

  default_tags {
    tags = var.tags
  }
}
