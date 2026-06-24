#!/usr/bin/env bash
set -euo pipefail

FILE="applicationsets/10-placements.yaml"
PLACEMENT="placement-postgres-frontend-dev"

python3 - <<'PY'
from pathlib import Path
path = Path("applicationsets/10-placements.yaml")
text = path.read_text()
needle = "  name: placement-postgres-frontend-dev"
start = text.find(needle)
if start == -1:
    raise SystemExit("Could not find placement-postgres-frontend-dev")
# Work only on the placement block after the needle until the next YAML document.
block_start = text.rfind('---', 0, start)
block_start = 0 if block_start == -1 else block_start
next_doc = text.find('\n---', start)
block_end = len(text) if next_doc == -1 else next_doc
block = text[block_start:block_end]
if "          - prod" not in block:
    block = block.replace("          - dev\n", "          - dev\n          - prod\n")
    text = text[:block_start] + block + text[block_end:]
path.write_text(text)
print("Updated placement-postgres-frontend-dev to include prod")
PY

echo "Next steps:"
echo "  git add applicationsets/10-placements.yaml"
echo "  git commit -m 'Promote PostgreSQL frontend sync wave demo to prod'"
echo "  git push"
echo "  oc -n openshift-gitops annotate applications.argoproj.io/rhacm-day2-applicationsets argocd.argoproj.io/refresh=hard --overwrite"
