#!/usr/bin/env bash
set -euo pipefail
CTX="${1:-dev-spoke}"
NS="bgd-rollouts-demo"

if oc --context "$CTX" argo rollouts version >/dev/null 2>&1; then
  oc --context "$CTX" argo rollouts promote bgd -n "$NS"
elif command -v kubectl >/dev/null 2>&1 && kubectl argo rollouts version >/dev/null 2>&1; then
  kubectl --context "$CTX" argo rollouts promote bgd -n "$NS"
else
  cat >&2 <<MSG
Argo Rollouts CLI plugin was not found.
Install/use the OpenShift GitOps CLI plugin, then run:
  oc --context $CTX argo rollouts promote bgd -n $NS

You can also promote from the OpenShift/Argo Rollouts UI.
MSG
  exit 1
fi
