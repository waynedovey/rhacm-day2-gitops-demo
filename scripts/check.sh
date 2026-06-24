#!/usr/bin/env bash
set -euo pipefail

DEV_CLUSTER="${DEV_CLUSTER:-dev-spoke}"
PROD_CLUSTER="${PROD_CLUSTER:-prod-spoke}"

echo "== Argo CD Applications =="
oc get applications.argoproj.io -n openshift-gitops || true

echo
echo "== ApplicationSets =="
oc get applicationsets.argoproj.io -n openshift-gitops || true

echo
echo "== GitOpsCluster =="
oc get gitopscluster -n openshift-gitops || true

echo
echo "== App Placements =="
oc get placement,placementdecision -n openshift-gitops || true

echo
echo "== RHACM Policies =="
oc get policy -n rhacm-policies || true

echo
echo "== RHACM PolicySet =="
oc get policyset -n rhacm-policies || true

echo
echo "== OpenShift Lightspeed status on spokes =="
for c in "$DEV_CLUSTER" "$PROD_CLUSTER"; do
  echo "-- ${c} --"
  oc --context "${c}" -n openshift-lightspeed get pods,deploy,olsconfig 2>/dev/null || true
  echo
done
