#!/usr/bin/env bash
set -euo pipefail

echo "== Argo CD Applications =="
oc get applications -n openshift-gitops || true

echo
echo "== ApplicationSets =="
oc get applicationsets -n openshift-gitops || true

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
