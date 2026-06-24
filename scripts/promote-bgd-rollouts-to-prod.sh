#!/usr/bin/env bash
set -euo pipefail
FILE="applicationsets/10-placements.yaml"

if [[ ! -f "$FILE" ]]; then
  echo "Run this from the repo root. Missing $FILE" >&2
  exit 1
fi

python3 - <<'PY'
from pathlib import Path
p = Path('applicationsets/10-placements.yaml')
s = p.read_text()
old = '''metadata:\n  name: placement-bgd-rollouts-dev\n  namespace: openshift-gitops'''
if old not in s:
    print('Could not find placement-bgd-rollouts-dev metadata block; leaving file unchanged')
else:
    # Keep the placement name stable, but allow both dev and prod values in the environment selector.
    s = s.replace('''        - key: environment\n          operator: In\n          values:\n          - dev\n  tolerations:\n  - key: cluster.open-cluster-management.io/unavailable''', '''        - key: environment\n          operator: In\n          values:\n          - dev\n          - prod\n  tolerations:\n  - key: cluster.open-cluster-management.io/unavailable''', 1)
    p.write_text(s)
    print('Updated BGD Rollouts placement to include prod')
PY

echo
cat <<MSG
Next:
  git add applicationsets/10-placements.yaml
  git commit -m "Promote BGD Rollouts demo to prod"
  git push

Then refresh ApplicationSets:
  oc -n openshift-gitops annotate applications.argoproj.io/rhacm-day2-applicationsets \
    argocd.argoproj.io/refresh=hard --overwrite
MSG
