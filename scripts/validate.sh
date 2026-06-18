#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../terraform"

terraform fmt -check
terraform validate

if command -v tflint >/dev/null 2>&1; then
  tflint --init
  tflint
else
  echo "tflint not installed; skipping."
fi

if command -v tfsec >/dev/null 2>&1; then
  tfsec .
else
  echo "tfsec not installed; skipping."
fi

if command -v checkov >/dev/null 2>&1; then
  checkov -d .
else
  echo "checkov not installed; skipping."
fi
