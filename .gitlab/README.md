# GitLab CI Pipeline Documentation

## Overview

Automated Terraform deployment pipeline with change detection, security scanning, and approval gates.

## Pipeline Flow

### CI Mode (Merge Requests)
```
Detect Changes → Lint → Security Scan → Plan → (Save Artifacts)
```
- **Triggers:** Merge request to `development`, `staging`, or `production`
- **Purpose:** Validate and generate plan for review
- **Output:** Plan artifacts saved for CD deployment

### CD Mode (Deployment)
```
Detect Changes → Show Plan → Approve → Apply
```
- **Triggers:** Push to `development`, `staging`, or `production` branches
- **Purpose:** Deploy approved changes
- **Uses:** Plan artifacts from merge request (no re-planning)

## Branch-Based Environments

| Branch | Environment |
|--------|-------------|
| `development` | Development |
| `staging` | Staging |
| `production` | Production |
| `main` | Development (default) |

## Configuration

### GitLab CI/CD Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `AWS_REGION` | No | `ap-southeast-1` | AWS region |
| `TF_MODULES_TOKEN` | No | - | Token for private Terraform modules |
| `TERRAFORM_VERSION` | No | `1.12.1` | Terraform version |

### AWS Authentication

**Runner IAM Role** - The GitLab runner uses its IAM instance profile for AWS authentication.

Required permissions:
- S3 (Terraform backend)
- DynamoDB (state locking)
- KMS (encryption)
- Resource management permissions

## Change Detection

Automatically detects changed Terraform modules:
- Monitors `.tf`, `.tfvars`, `.json` files in `hli/` and `services/` directories
- Excludes `env/` directories (tfvars only) and `.terraform/` cache
- Runs parallel jobs for each changed module

## Artifacts

| Type | Files | Retention |
|------|-------|-----------|
| **Plan** | `tfplan`, `plan.txt`, `plan.log` | 1 week |
| **Security** | `checkov.sarif`, `checkov.json` | 1 week |
| **Apply** | `apply.log` | 90 days |

## Approval Gates

| Environment | Approval Required | Notes |
|-------------|-------------------|-------|
| Development | Manual | After plan review |
| Staging | Manual | After plan review |
| Production | Manual | After plan review + CODEOWNERS |

## Directory Structure

```
hli/       
  infra/                   # Division-specific modules
    iam/                        # IAM module
      main.tf
      variables.tf
      terraform.tfvars          # Module-specific vars
    env/                      # Division-level env vars
      development/
        terraform.tfvars
      staging/
        terraform.tfvars
      production/
        terraform.tfvars

services/                     # Shared services modules
  storage-layer/
    s3-data-lake/
      main.tf

env/                          # Root-level env vars (shared)
  development/
    terraform.tfvars
  staging/
    terraform.tfvars
  production/
    terraform.tfvars
```

## Variable Loading Order

Terraform loads variables in this order (later overrides earlier):
1. Module directory: `hli/infra/iam/terraform.tfvars`
2. Division-level env: `hli/iam/env/development/terraform.tfvars`
3. Root-level env: `env/development/terraform.tfvars`

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **No changes detected** | Ensure `.tf` files are in `hli/` or `services/` directories |
| **Plan fails** | Check AWS credentials, backend config, and module sources |
| **Apply fails** | Verify plan artifacts exist and state is not locked |
| **CD missing artifacts** | Ensure merge request CI pipeline completed successfully |

## Security

- **TFLint** - Terraform code quality
- **Checkov** - IaC security scanning
- Results in GitLab Security Dashboard

