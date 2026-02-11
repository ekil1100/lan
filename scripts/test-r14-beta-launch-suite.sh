#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

current_case=""
on_error() {
  local exit_code="$?"
  echo "[r14-beta-launch-suite] FAIL case=${current_case:-unknown} exit=${exit_code}"
  exit "$exit_code"
}
trap on_error ERR

current_case="changelog"
[[ -f docs/release/CHANGELOG.md ]]
rg -q "0.1.0-beta" docs/release/CHANGELOG.md

current_case="announcement"
[[ -f docs/release/beta-announcement.md ]]
rg -q "反馈渠道|feedback" docs/release/beta-announcement.md

current_case="entry-verification"
./scripts/test-verify-beta-entry.sh

current_case="roadmap-beta-milestone"
rg -q "Beta（当前" docs/ROADMAP.md
rg -q "MVP（已完成" docs/ROADMAP.md

echo "[r14-beta-launch-suite] PASS"