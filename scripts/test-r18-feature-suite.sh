#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

current_case=""
on_error() {
  echo "[r18-feature-suite] FAIL case=${current_case:-unknown} exit=$?"
  exit 1
}
trap on_error ERR

current_case="skill-example"
[[ -f skills/hello-world/manifest.json ]]
[[ -f docs/skills/creating-skills.md ]]
# verify skill add/remove roundtrip
./zig-out/bin/lan skill add ./skills/hello-world 2>&1 | grep -q "Skill installed"
./zig-out/bin/lan skill remove hello-world 2>&1 | grep -q "Skill removed"

current_case="provider-health"
./scripts/test-provider-health.sh

current_case="history-export"
./scripts/test-history-export.sh

echo "[r18-feature-suite] PASS"