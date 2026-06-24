#!/usr/bin/env bash
set -euo pipefail

PROD_CLUSTER=${1:-prod-spoke}

echo "Temporarily relabeling prod as dev so the existing dev Placement selects it for the hello-openshift demo app."
oc label managedcluster "$PROD_CLUSTER" environment=dev --overwrite

echo "ApplicationSet should create an app for $PROD_CLUSTER within ~30 seconds."
oc get placementdecision -n openshift-gitops -l cluster.open-cluster-management.io/placement=placement-hello-openshift-dev -o yaml
