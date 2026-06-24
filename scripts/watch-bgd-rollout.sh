#!/usr/bin/env bash
set -euo pipefail

CTX="${1:-dev-spoke}"
NS="${NAMESPACE:-bgd-rollouts-demo}"
ROLLOUT="${ROLLOUT:-bgd}"

# Prefer the Argo Rollouts CLI because it shows pause/promote/canary status clearly.
if command -v kubectl-argo-rollouts >/dev/null 2>&1; then
  kubectl-argo-rollouts --context "$CTX" get rollout "$ROLLOUT" -n "$NS" --watch
  exit 0
fi

# Fallback to a simple OpenShift watch if the CLI plugin is not installed.
while true; do
  clear
  echo "===== $CTX / $NS ====="
  echo
  oc --context "$CTX" -n "$NS" get rollout "$ROLLOUT" 2>/dev/null || true
  echo
  oc --context "$CTX" -n "$NS" get pods -l app=bgd -o wide 2>/dev/null || true
  echo
  echo "Route weights:"
  oc --context "$CTX" -n "$NS" get route bgd -o jsonpath='stable={.spec.to.name}:{.spec.to.weight}{"\n"}canary={.spec.alternateBackends[0].name}:{.spec.alternateBackends[0].weight}{"\n"}' 2>/dev/null || true
  echo
  echo "Route URL:"
  oc --context "$CTX" -n "$NS" get route bgd -o jsonpath='https://{.spec.host}{"\n"}' 2>/dev/null || true
  echo
  echo "Tip: promote with ./scripts/promote-bgd-rollout-step.sh $CTX"
  sleep 5
done
