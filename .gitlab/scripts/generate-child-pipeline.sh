#!/bin/bash
# ============================================
# Generate Child Pipeline for Terraform Jobs
# ============================================
# This script generates a GitLab CI child pipeline YAML
# with parallel matrix jobs for each changed Terraform target
# ============================================

set -euo pipefail

CHANGED_TARGETS_FILE="${1:-changed-targets.json}"
PIPELINE_MODE="${2:-ci}"
ENVIRONMENT="${3:-dev}"

if [ ! -f "$CHANGED_TARGETS_FILE" ]; then
  echo "ERROR: Changed targets file not found: $CHANGED_TARGETS_FILE"
  exit 1
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
  echo "ERROR: jq is required but not installed"
  exit 1
fi

# Read targets from JSON file
TARGETS=$(jq -r '.changed_targets[]' "$CHANGED_TARGETS_FILE" 2>/dev/null || echo "")

if [ -z "$TARGETS" ] || [ "$TARGETS" = "null" ]; then
  echo "No targets found in $CHANGED_TARGETS_FILE"
  # Generate a valid empty pipeline YAML
  cat > child-pipeline.yml <<EOF
stages: []
variables:
  PIPELINE_MODE: "$PIPELINE_MODE"
  ENVIRONMENT: "$ENVIRONMENT"

workflow:
  rules:
    - if: '\$CI_PIPELINE_SOURCE == "parent_pipeline"'
      when: always
    - when: never

# No jobs - no targets changed
EOF
  exit 0
fi

# Count targets
TARGET_COUNT=$(echo "$TARGETS" | wc -l)
echo "Generating child pipeline for $TARGET_COUNT targets"

# Start building the child pipeline YAML
cat > child-pipeline.yml <<EOF
include:
  - local: '.gitlab/ci/jobs/lint.yml'
  - local: '.gitlab/ci/jobs/security.yml'
  - local: '.gitlab/ci/jobs/plan_apply.yml'
  - local: '.gitlab/ci/templates/terraform-base.yml'

stages:
  - lint_and_security
  - plan
  - approve
  - apply

variables:
  PIPELINE_MODE: "$PIPELINE_MODE"
  ENVIRONMENT: "$ENVIRONMENT"

workflow:
  rules:
    - if: '\$CI_PIPELINE_SOURCE == "parent_pipeline"'
      when: always
    - when: never

EOF

# Build matrix array for YAML
MATRIX_TARGETS=""
while IFS= read -r target; do
  if [ -n "$target" ]; then
    if [ -z "$MATRIX_TARGETS" ]; then
      MATRIX_TARGETS="        - $target"
    else
      MATRIX_TARGETS="$MATRIX_TARGETS
        - $target"
    fi
  fi
done <<EOF
$TARGETS
EOF

# Generate lint jobs
cat >> child-pipeline.yml <<EOF
# Lint jobs with parallel matrix
terraform_lint:
  extends: .terraform_lint_job
  stage: lint_and_security
  parallel:
    matrix:
      - TARGET:
$MATRIX_TARGETS
  rules:
    - if: \$PIPELINE_MODE == "ci"
      when: on_success
    - when: never

# Security scan jobs with parallel matrix
terraform_security:
  extends: .terraform_security_job
  stage: lint_and_security
  parallel:
    matrix:
      - TARGET:
$MATRIX_TARGETS
  rules:
    - if: \$PIPELINE_MODE == "ci"
      when: on_success
    - when: never

# Plan jobs with parallel matrix (CI only)
# Non-prod environments (dev, stg)
terraform_plan_nonprod:
  extends: .terraform_plan_job
  stage: plan
  tags:
    - aws
    - \$RUNNER_TAG_NONPROD
  needs:
    - job: terraform_lint
      optional: true
    - job: terraform_security
      optional: true
  parallel:
    matrix:
      - TARGET:
$MATRIX_TARGETS
  variables:
    BACKEND_IAM_ROLE_NAME: \$BACKEND_ROLE_NONPROD

  rules:
    - if: \$PIPELINE_MODE == "ci" && \$ENVIRONMENT =~ /^(dev|stg)$/
      when: on_success
    - when: never

# Plan jobs for prod environment
terraform_plan_prod:
  extends: .terraform_plan_job
  stage: plan
  tags:
    - aws
    - \$RUNNER_TAG_PROD
  needs:
    - job: terraform_lint
      optional: true
    - job: terraform_security
      optional: true
  parallel:
    matrix:
      - TARGET:
$MATRIX_TARGETS
  variables:
    BACKEND_IAM_ROLE_NAME: \$BACKEND_ROLE_PROD
    # Fargate
    FARGATE_TASK_DEFINITION: \$TASK_DEF_PROD
  rules:
    - if: \$PIPELINE_MODE == "ci" && \$ENVIRONMENT == "prod"
      when: on_success
    - when: never

# Apply jobs with parallel matrix (CD only, auto-approve)
# Non-prod environments (dev, stg)
terraform_apply_nonprod:
  extends: .terraform_apply_job
  stage: apply
  tags:
    - aws
    - \$RUNNER_TAG_NONPROD
  parallel:
    matrix:
      - TARGET:
$MATRIX_TARGETS
  variables:
    BACKEND_IAM_ROLE_NAME: \$BACKEND_ROLE_NONPROD
  environment:
    name: \$ENVIRONMENT
    action: start
  rules:
    - if: \$PIPELINE_MODE == "cd" && \$ENVIRONMENT =~ /^(dev|stg)$/
      when: on_success
      allow_failure: false
    - when: never

# Apply jobs for prod environment
terraform_apply_prod:
  extends: .terraform_apply_job
  stage: apply
  tags:
    - aws
    - \$RUNNER_TAG_PROD
  parallel:
    matrix:
      - TARGET:
$MATRIX_TARGETS
  variables:
    BACKEND_IAM_ROLE_NAME: \$BACKEND_ROLE_PROD
    # Fargate
    FARGATE_TASK_DEFINITION: \$TASK_DEF_PROD
  environment:
    name: \$ENVIRONMENT
    action: start
  rules:
    - if: \$PIPELINE_MODE == "cd" && \$ENVIRONMENT == "prod"
      when: on_success
      allow_failure: false
    - when: never
EOF

echo "Child pipeline generated successfully with $TARGET_COUNT targets"
