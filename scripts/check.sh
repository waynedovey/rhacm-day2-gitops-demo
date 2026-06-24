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

echo "== OLMv1 Pipelines ClusterExtension status on spokes =="
for c in "$DEV_CLUSTER" "$PROD_CLUSTER"; do
  echo "-- ${c} --"
  oc --context "${c}" get clusterextension pipelines-operator 2>/dev/null || true
  oc --context "${c}" get clusterextension pipelines-operator -o jsonpath='{range .status.conditions[*]}{.type}{"="}{.status}{" reason="}{.reason}{"\n"}{end}' 2>/dev/null || true
  echo
done

echo "== Pipelines console plugin status on spokes =="
for c in "$DEV_CLUSTER" "$PROD_CLUSTER"; do
  echo "-- ${c} --"
  oc --context "${c}" get consoleplugin pipelines-console-plugin 2>/dev/null || true
  oc --context "${c}" get consoles.operator.openshift.io cluster -o jsonpath='{.spec.plugins}{"\n"}' 2>/dev/null || true
  oc --context "${c}" -n openshift-pipelines get svc,endpoints,pods 2>/dev/null | egrep "console-plugin|NAME" || true
  echo
done


echo
print_header "PostgreSQL frontend sync-wave demo"
oc -n openshift-gitops get applications.argoproj.io | grep postgres-frontend || true
for c in dev-spoke prod-spoke; do
  echo "===== $c ====="
  oc --context "$c" -n postgres-frontend-demo get pods,svc,route,jobs 2>/dev/null || true
done

echo
for c in dev-spoke prod-spoke; do
  echo "===== BGD Rollouts demo on $c ====="
  oc --context "$c" -n bgd-rollouts-demo get rollout,svc,route,pods 2>/dev/null || true
  oc --context "$c" -n bgd-rollouts-demo get route bgd -o jsonpath='route=https://{.spec.host}{"\n"}stable={.spec.to.name}:{.spec.to.weight}{"\n"}canary={.spec.alternateBackends[0].name}:{.spec.alternateBackends[0].weight}{"\n"}' 2>/dev/null || true
  echo
 done
