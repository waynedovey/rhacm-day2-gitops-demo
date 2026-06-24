#!/usr/bin/env bash
set -euo pipefail

REPO_URL=${1:-}
TARGET_REVISION=${2:-main}
CLUSTERSET=${3:-global}

if [[ -z "$REPO_URL" ]]; then
  echo "Usage: $0 <git-repo-url> [target-revision] [managed-clusterset]"
  echo "Example: $0 https://github.com/wdovey/rhacm-day2-gitops-demo.git main global"
  exit 1
fi

command -v oc >/dev/null || { echo "oc CLI not found"; exit 1; }
command -v envsubst >/dev/null || { echo "envsubst not found. Install gettext or render templates manually."; exit 1; }

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd "$SCRIPT_DIR/.." && pwd)

printf "\n[1/5] Checking hub access...\n"
oc whoami >/dev/null
oc get ns openshift-gitops >/dev/null

printf "\n[2/5] Applying namespaces, ApplicationSet generator config, and RBAC...\n"
oc apply -f "$ROOT_DIR/bootstrap/00-prereqs.yaml"
oc apply -f "$ROOT_DIR/bootstrap/10-argocd-rbac.yaml"

printf "\n[3/5] Binding ManagedClusterSet '%s' to demo namespaces...\n" "$CLUSTERSET"
export CLUSTERSET

envsubst < "$ROOT_DIR/bootstrap/20-managedclustersetbindings.yaml.tpl" | oc apply -f -

printf "\n[4/5] Creating Argo CD Applications that sync policies and ApplicationSets...\n"
export REPO_URL TARGET_REVISION

envsubst < "$ROOT_DIR/bootstrap/30-argocd-applications.yaml.tpl" | oc apply -f -

printf "\n[5/5] Done. Useful checks:\n"
cat <<CHECKS

oc get applications -n openshift-gitops
oc get applicationsets -n openshift-gitops
oc get gitopscluster -n openshift-gitops
oc get placement,placementdecision -n openshift-gitops
oc get policies -n rhacm-policies

CHECKS
