#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

tmp_dir=".lan_runbook_check_test_$(date +%s)"
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir"

out="$(./scripts/check-beta-runbook-commands.sh "$tmp_dir/bin" 2>&1 || true)"
echo "$out" | grep -q "\[runbook-check\] SUMMARY" || { echo "[runbook-check-test] FAIL reason=summary-missing"; echo "$out"; exit 1; }
echo "$out" | grep -q "pass_rate=" || { echo "[runbook-check-test] FAIL reason=pass-rate-missing"; echo "$out"; exit 1; }
echo "$out" | grep -q "\[runbook-check\] PASS all_cases_passed" || { echo "[runbook-check-test] FAIL reason=overall-pass-missing"; echo "$out"; exit 1; }

echo "[runbook-check-test] PASS reason=runbook-command-check-covered"