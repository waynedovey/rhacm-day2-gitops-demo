#!/usr/bin/env bash
set -euo pipefail

DEV_CLUSTER="${DEV_CLUSTER:-dev-spoke}"
PROD_CLUSTER="${PROD_CLUSTER:-prod-spoke}"
PLUGIN="${PLUGIN:-pipelines-console-plugin}"

for c in "$DEV_CLUSTER" "$PROD_CLUSTER"; do
  echo "===== ${c} ====="

  if ! oc --context "$c" get consoleplugin "$PLUGIN" >/dev/null 2>&1; then
    echo "ConsolePlugin/${PLUGIN} does not exist yet. Wait for Pipelines to finish installing."
    continue
  fi

  plugins=$(oc --context "$c" get consoles.operator.openshift.io cluster -o json \
    | jq -c --arg plugin "$PLUGIN" '.spec.plugins // [] | if index($plugin) then . else . + [$plugin] end')

  oc --context "$c" patch consoles.operator.openshift.io cluster \
    --type=merge \
    -p "{\"spec\":{\"plugins\":$plugins}}"

  echo "Enabled plugins:"
  oc --context "$c" get consoles.operator.openshift.io cluster -o jsonpath='{.spec.plugins}{"\n"}'
  echo

done
