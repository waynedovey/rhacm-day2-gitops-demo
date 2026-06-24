#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${OLS_API_TOKEN:-}" ]]; then
  echo "ERROR: Set OLS_API_TOKEN first, for example:" >&2
  echo "  export OLS_API_TOKEN='sk-...'" >&2
  exit 1
fi

OLS_MODEL="${OLS_MODEL:-gpt-4o-mini}"
POLICY_NS="${POLICY_NS:-rhacm-policies}"

oc get namespace "${POLICY_NS}" >/dev/null 2>&1 || oc create namespace "${POLICY_NS}"

oc -n "${POLICY_NS}" create secret generic ols-openai \
  --from-literal=apitoken="${OLS_API_TOKEN}" \
  --dry-run=client -o yaml | oc apply -f -

oc -n "${POLICY_NS}" create configmap ols-openai-config \
  --from-literal=model="${OLS_MODEL}" \
  --dry-run=client -o yaml | oc apply -f -

echo "Created ${POLICY_NS}/ols-openai and ${POLICY_NS}/ols-openai-config on the hub."
echo "Model: ${OLS_MODEL}"
echo

echo "Refreshing Argo CD policy app if present..."
oc -n openshift-gitops annotate applications.argoproj.io/rhacm-day2-policies \
  argocd.argoproj.io/refresh=hard --overwrite >/dev/null 2>&1 || true
