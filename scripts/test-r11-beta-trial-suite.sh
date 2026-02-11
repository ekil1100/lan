#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

current_case=""
on_error() {
  local exit_code="$?"
  if [[ -n "$current_case" ]]; then
    echo "[r11-beta-trial-suite] FAIL case=${current_case} exit=${exit_code}"
  else
    echo "[r11-beta-trial-suite] FAIL case=<unknown> exit=${exit_code}"
  fi
  exit "$exit_code"
}
trap on_error ERR

current_case="snapshot"
./scripts/test-snapshot-beta-acceptance.sh

current_case="feedback-template"
[[ -f docs/release/beta-feedback-template.md ]]

current_case="rollback-rehearsal"
./scripts/test-rehearse-beta-rollback.sh

current_case="runbook"
[[ -f docs/release/beta-trial-runbook.md ]]
rg -q "安装（Install）|验证（Verify）|反馈（Feedback）" docs/release/beta-trial-runbook.md

echo "[r11-beta-trial-suite] PASS"