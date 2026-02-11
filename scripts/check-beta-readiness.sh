#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

checklist_doc="docs/beta-checklist.md"
if [[ ! -f "$checklist_doc" ]]; then
  echo "[beta-check] FAIL item=checklist_doc reason=missing"
  echo "next: add $checklist_doc (or sync from docs/release/beta-entry-checklist.md)"
  exit 1
fi

fail_count=0

run_check() {
  local item="$1" cmd="$2" next_step="$3"
  if eval "$cmd" >/tmp/lan-beta-check.$$ 2>&1; then
    echo "[beta-check] PASS item=${item}"
  else
    fail_count=$((fail_count + 1))
    echo "[beta-check] FAIL item=${item} reason=command_failed"
    sed -n '1,6p' /tmp/lan-beta-check.$$ | sed 's/^/[beta-check] detail: /'
    echo "next: ${next_step}"
  fi
}

run_check "preflight_json" "./scripts/test-preflight-json.sh" "fix preflight failures, then rerun ./scripts/test-preflight-json.sh"
run_check "release_notes" "./scripts/test-release-notes.sh" "fix release notes metadata/format issues, then rerun ./scripts/test-release-notes.sh"
run_check "support_bundle" "./scripts/test-support-bundle.sh" "fix support bundle artifact content, then rerun ./scripts/test-support-bundle.sh"
run_check "ops_regression_entry" "make r9-ops-readiness-regression" "fix failed R9 suite case(s), then rerun make r9-ops-readiness-regression"

rm -f /tmp/lan-beta-check.$$ || true

if [[ "$fail_count" -gt 0 ]]; then
  echo "[beta-check] FAIL summary=${fail_count}_item(s)_failed"
  exit 1
fi

echo "[beta-check] PASS summary=all_items_passed"