#!/usr/bin/env bash
set -euo pipefail

CTX="${1:-dev-spoke}"
NS="${NAMESPACE:-bgd-rollouts-demo}"
ROLLOUT="${ROLLOUT:-bgd}"

# Use the standalone Argo Rollouts plugin binary. This avoids the kubectl/oc
# plugin parser issue: "flags cannot be placed before plugin name: --context".
if command -v kubectl-argo-rollouts >/dev/null 2>&1; then
  kubectl-argo-rollouts --context "$CTX" promote "$ROLLOUT" -n "$NS"
  exit 0
fi

# Fallback for environments where only kubectl plugin invocation works.
# Important: --context must come after the plugin command, not before it.
if command -v kubectl >/dev/null 2>&1 && kubectl argo rollouts version --client >/dev/null 2>&1; then
  kubectl argo rollouts promote "$ROLLOUT" -n "$NS" --context "$CTX"
  exit 0
fi

cat >&2 <<MSG
Argo Rollouts CLI plugin was not found.

Install it on macOS with:
  brew install argoproj/tap/kubectl-argo-rollouts

Then run:
  ./scripts/promote-bgd-rollout-step.sh $CTX

Direct command:
  kubectl-argo-rollouts --context $CTX promote $ROLLOUT -n $NS
MSG
exit 1
