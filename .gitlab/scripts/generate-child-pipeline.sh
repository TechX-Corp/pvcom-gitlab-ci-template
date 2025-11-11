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

if [ ! -f "${CHANGED_TARGETS_FILE}" ]; then
  echo "ERROR: Changed targets file not found: ${CHANGED_TARGETS_FILE}"
  exit 1
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
  echo "ERROR: jq is required but not installed"
  exit 1
fi

# Read targets from JSON file
TARGETS=$(jq -r '.changed_targets[]' "${CHANGED_TARGETS_FILE}" 2>/dev/null || echo "")

if [ -z "${TARGETS}" ] || [ "${TARGETS}" = "null" ]; then
  echo "No targets found in ${CHANGED_TARGETS_FILE}"
  # Generate a valid empty pipeline YAML
  cat > child-pipeline.yml <<EOF
stages: []
variables:
  PIPELINE_MODE: "${PIPELINE_MODE}"
  ENVIRONMENT: "${ENVIRONMENT}"

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
TARGET_COUNT=$(echo "${TARGETS}" | wc -l)
echo "Generating child pipeline for ${TARGET_COUNT} targets"

# Start building the child pipeline YAML
cat > child-pipeline.yml <<EOF
include:
  - local: '.gitlab/ci/jobs/lint.yml'
  - local: '.gitlab/ci/jobs/security.yml'
  - local: '.gitlab/ci/jobs/plan_apply.yml'
  - local: '.gitlab/ci/templates/terraform-base.yml'

stages:
  - lint
  - security
  - plan
  - approve
  - apply

variables:
  PIPELINE_MODE: "${PIPELINE_MODE}"
  ENVIRONMENT: "${ENVIRONMENT}"

workflow:
  rules:
    - if: '\$CI_PIPELINE_SOURCE == "parent_pipeline"'
      when: always
    - when: never

EOF

# Build matrix array for YAML
MATRIX_TARGETS=""
while IFS= read -r target; do
  if [ -n "${target}" ]; then
    if [ -z "${MATRIX_TARGETS}" ]; then
      MATRIX_TARGETS="        - ${target}"
    else
      MATRIX_TARGETS="${MATRIX_TARGETS}
        - ${target}"
    fi
  fi
done <<EOF
${TARGETS}
EOF

# Generate lint jobs
cat >> child-pipeline.yml <<EOF
# Lint jobs with parallel matrix
terraform_lint:
  extends: .terraform_lint_job
  stage: lint
  parallel:
    matrix:
      - TARGET:
${MATRIX_TARGETS}
  rules:
    - if: \$PIPELINE_MODE == "ci"
      when: on_success
    - when: never

# Security scan jobs with parallel matrix
terraform_security:
  extends: .terraform_security_job
  stage: security
  needs:
    - job: terraform_lint
      optional: true
  parallel:
    matrix:
      - TARGET:
${MATRIX_TARGETS}
  rules:
    - if: \$PIPELINE_MODE == "ci"
      when: on_success
    - when: never

# Plan jobs with parallel matrix
# Runs in both CI and CD modes
terraform_plan:
  extends: .terraform_plan_job
  stage: plan
  needs:
    - job: terraform_lint
      optional: true
    - job: terraform_security
      optional: true
  parallel:
    matrix:
      - TARGET:
${MATRIX_TARGETS}
  rules:
    - if: \$PIPELINE_MODE == "ci"
      when: on_success
    - if: \$PIPELINE_MODE == "cd"
      when: on_success
    - when: never

# Approval gate
approve_apply:
  stage: approve
  image: alpine:latest
  tags:
    - linux
    - self-hosted
  needs:
    - job: terraform_plan
      artifacts: false
  before_script:
    - apk add --no-cache bash jq
  script:
    - |
      echo "=========================================="
      echo "Approval Gate for \${ENVIRONMENT} Environment"
      echo "=========================================="
      echo ""
      echo "Please review the Terraform plans before approving apply."
      echo ""
      echo "Targets to be applied:"
EOF

# Add targets list to approval script
while IFS= read -r target; do
  if [ -n "${target}" ]; then
    echo "      echo \"      - ${target}\"" >> child-pipeline.yml
  fi
done <<EOF
${TARGETS}
EOF

cat >> child-pipeline.yml <<EOF
      echo ""
      echo "After approval, the apply stage will execute Terraform apply"
      echo "for all planned targets in the \${ENVIRONMENT} environment."
  rules:
    - if: \$PIPELINE_MODE == "cd" && \$CI_COMMIT_BRANCH == "production"
      when: manual
      allow_failure: false
    - if: \$PIPELINE_MODE == "cd" && \$CI_COMMIT_BRANCH =~ /^(development|staging)$/
      when: manual
      allow_failure: false
    - when: never

# Apply jobs with parallel matrix
terraform_apply:
  extends: .terraform_apply_job
  stage: apply
  needs:
    - job: terraform_plan
      artifacts: true
    - job: approve_apply
  parallel:
    matrix:
      - TARGET:
${MATRIX_TARGETS}
  environment:
    name: \${ENVIRONMENT}
    action: start
  rules:
    - if: \$PIPELINE_MODE == "cd"
      when: manual
      allow_failure: false
EOF

echo "Child pipeline generated successfully with ${TARGET_COUNT} targets"
