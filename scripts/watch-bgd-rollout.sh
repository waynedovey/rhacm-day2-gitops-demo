#!/usr/bin/env bash
set -euo pipefail
CTX="${1:-dev-spoke}"
NS="bgd-rollouts-demo"

while true; do
  clear
  echo "===== $CTX / $NS ====="
  echo
  oc --context "$CTX" -n "$NS" get rollout bgd 2>/dev/null || true
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
