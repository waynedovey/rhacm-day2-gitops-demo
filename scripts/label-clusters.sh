#!/usr/bin/env bash
set -euo pipefail

DEV_CLUSTER=${1:-dev-spoke}
PROD_CLUSTER=${2:-prod-spoke}

echo "Labeling managed clusters for the RHACM Day 2 demo"
echo "  dev:  ${DEV_CLUSTER}"
echo "  prod: ${PROD_CLUSTER}"

oc label managedcluster "$DEV_CLUSTER" demo=day2 environment=dev --overwrite

if [[ -n "$PROD_CLUSTER" ]]; then
  oc label managedcluster "$PROD_CLUSTER" demo=day2 environment=prod --overwrite
fi

oc get managedclusters -l demo=day2 --show-labels
