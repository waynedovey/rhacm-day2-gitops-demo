#!/usr/bin/env bash
set -euo pipefail

COLOR="${1:-green}"
FILE="apps/bgd-rollouts/04-rollout.yaml"

if [[ ! -f "$FILE" ]]; then
  echo "Run this from the repo root. Missing $FILE" >&2
  exit 1
fi

python3 - "$FILE" "$COLOR" <<'PY'
from pathlib import Path
import sys, re
path = Path(sys.argv[1])
color = sys.argv[2]
s = path.read_text()
s2 = re.sub(r'(name:\s*COLOR\n\s*value:\s*)"[^"]+"', rf'\1"{color}"', s, count=1)
if s2 == s:
    raise SystemExit('Could not find COLOR env var to update')
path.write_text(s2)
PY

echo "Updated BGD rollout color to: $COLOR"
echo
sed -n '/name: COLOR/,+1p' "$FILE"
echo
cat <<MSG
Next:
  git add $FILE
  git commit -m "Update BGD rollout color to $COLOR"
  git push

Then watch the canary rollout and promote each pause:
  ./scripts/watch-bgd-rollout.sh dev-spoke
  ./scripts/promote-bgd-rollout-step.sh dev-spoke
MSG
