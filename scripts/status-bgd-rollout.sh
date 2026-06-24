#!/usr/bin/env bash
set -euo pipefail

CTX="${1:-dev-spoke}"
NS="${NAMESPACE:-bgd-rollouts-demo}"
ROLLOUT="${ROLLOUT:-bgd}"

echo "===== $CTX / $NS ====="
echo
oc --context "$CTX" -n "$NS" get rollout "$ROLLOUT" || true
echo
oc --context "$CTX" -n "$NS" get pods -l app=bgd -o wide || true
echo
echo "Route weights:"
oc --context "$CTX" -n "$NS" get route bgd -o jsonpath='stable={.spec.to.name}:{.spec.to.weight}{"\n"}canary={.spec.alternateBackends[0].name}:{.spec.alternateBackends[0].weight}{"\n"}' 2>/dev/null || true
echo
echo "Route URL:"
oc --context "$CTX" -n "$NS" get route bgd -o jsonpath='https://{.spec.host}{"\n"}' 2>/dev/null || true
