#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

target_dir="${1:-$HOME/.local/bin}"

pkg_out="$(./scripts/package-release.sh 2>&1 || true)"
pkg="$(echo "$pkg_out" | sed -n 's/^\[package\] PASS artifact=\([^ ]*\).*/\1/p')"
if [[ -z "$pkg" ]]; then
  echo "[runbook-check] FAIL case=package reason=artifact_missing"
  echo "$pkg_out"
  echo "next: fix package-release first, then rerun this check"
  exit 1
fi

pass=0
fail=0
failed_cases=()

run_case() {
  local name="$1" cmd="$2" next_step="$3"
  local log="/tmp/lan-runbook-check-${name}-$$.log"
  if bash -lc "$cmd" >"$log" 2>&1; then
    pass=$((pass+1))
    echo "[runbook-check] PASS case=$name"
  else
    fail=$((fail+1))
    failed_cases+=("$name")
    echo "[runbook-check] FAIL case=$name"
    sed -n '1,5p' "$log" | sed 's/^/[runbook-check] detail: /'
    echo "next: $next_step"
  fi
  rm -f "$log" || true
}

run_case "verify-beta-candidate" "./scripts/verify-beta-candidate.sh '$pkg' '$target_dir'" "fix verify/preflight/install failure, then rerun verify-beta-candidate"
run_case "run-beta-acceptance" "./scripts/run-beta-acceptance.sh '$pkg' '$target_dir' dist/beta-acceptance-report.md" "fix failed acceptance step from logs, then rerun run-beta-acceptance"
run_case "post-install-health" "./scripts/post-install-health.sh '$target_dir/lan'" "fix binary/dependency issue, then rerun post-install-health"
run_case "feedback-template" "test -f docs/release/beta-feedback-template.md" "add beta feedback template file and retry"

printf '[runbook-check] SUMMARY pass=%s total=%s pass_rate=%s%%\n' "$pass" "$((pass+fail))" "$(( (pass*100)/((pass+fail)==0?1:(pass+fail)) ))"
if [[ "$fail" -gt 0 ]]; then
  echo "[runbook-check] FAILED_CASES ${failed_cases[*]}"
  echo "next: resolve failed cases and rerun ./scripts/check-beta-runbook-commands.sh"
  exit 1
fi

echo "[runbook-check] PASS all_cases_passed"