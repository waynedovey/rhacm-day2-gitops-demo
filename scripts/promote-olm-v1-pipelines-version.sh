#!/usr/bin/env bash
set -euo pipefail

VERSION_RANGE="${1:->=1.14.0, <2.1.0}"
POLICY_FILE="policies/policy-olm-v1-pipelines-version-control.yaml"

if [[ ! -f "${POLICY_FILE}" ]]; then
  echo "Run this from the repo root. Could not find ${POLICY_FILE}" >&2
  exit 1
fi

python3 - "${VERSION_RANGE}" "${POLICY_FILE}" <<'PY'
from pathlib import Path
import re
import sys
version = sys.argv[1]
path = Path(sys.argv[2])
text = path.read_text()
new = re.sub(r'(\n\s*version:\s*)"[^"]+"', rf'\1"{version}"', text, count=1)
if new == text:
    raise SystemExit('No version field was updated')
path.write_text(new)
print(f'Updated {path} to version range: {version}')
PY

echo
echo "Next steps:"
echo "  git add ${POLICY_FILE}"
echo "  git commit -m 'Promote OLMv1 Pipelines operator version range'"
echo "  git push"
echo "  oc -n openshift-gitops annotate applications.argoproj.io/rhacm-day2-policies argocd.argoproj.io/refresh=hard --overwrite"
