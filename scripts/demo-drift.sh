#!/usr/bin/env bash
set -euo pipefail

CONTEXT=${1:-}

if [[ -z "$CONTEXT" ]]; then
  echo "Usage: $0 <managed-cluster-kubecontext>"
  echo "Example: $0 dev-spoke-admin"
  exit 1
fi

echo "Deleting day2-standard namespace on managed cluster context: $CONTEXT"
oc --context "$CONTEXT" delete ns day2-standard --ignore-not-found

echo "Now watch RHACM policy compliance from the hub:"
echo "  watch 'oc get policy -n rhacm-policies policy-day2-standard-namespace -o wide'"
