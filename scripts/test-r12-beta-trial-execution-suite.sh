#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

current_case=""
on_error() {
  local exit_code="$?"
  if [[ -n "$current_case" ]]; then
    echo "[r12-beta-trial-execution-suite] FAIL case=${current_case} exit=${exit_code}"
  else
    echo "[r12-beta-trial-execution-suite] FAIL case=<unknown> exit=${exit_code}"
  fi
  exit "$exit_code"
}
trap on_error ERR

current_case="trial-precheck"
./scripts/test-trial-precheck.sh

current_case="trial-tracker-template"
[[ -f docs/release/beta-trial-tracker-template.md ]]
rg -q "Batch|Device ID|Status|Issue Severity" docs/release/beta-trial-tracker-template.md

current_case="trial-summary"
./scripts/test-summarize-beta-trial.sh

current_case="go-no-go-template"
[[ -f docs/release/beta-go-no-go-template.md ]]
rg -q "GO|NO-GO|pass_rate|failed_items|pending_items" docs/release/beta-go-no-go-template.md

echo "[r12-beta-trial-execution-suite] PASS"