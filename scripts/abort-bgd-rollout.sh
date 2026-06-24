#!/usr/bin/env bash
set -euo pipefail
CTX="${1:-dev-spoke}"
NS="bgd-rollouts-demo"

if oc --context "$CTX" argo rollouts version >/dev/null 2>&1; then
  oc --context "$CTX" argo rollouts abort bgd -n "$NS"
elif command -v kubectl >/dev/null 2>&1 && kubectl argo rollouts version >/dev/null 2>&1; then
  kubectl --context "$CTX" argo rollouts abort bgd -n "$NS"
else
  echo "Argo Rollouts CLI plugin not found. Abort from the UI or install the CLI plugin." >&2
  exit 1
fi
