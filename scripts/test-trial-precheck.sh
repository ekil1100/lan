#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

tmp_dir=".lan_trial_precheck_test_$(date +%s)"
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir"

pkg_out="$(./scripts/package-release.sh 2>&1 || true)"
echo "$pkg_out" | grep -q "\[package\] PASS artifact=" || { echo "[trial-precheck-test] FAIL reason=package-failed"; echo "$pkg_out"; exit 1; }
pkg="$(echo "$pkg_out" | sed -n 's/^\[package\] PASS artifact=\([^ ]*\).*/\1/p')"

ok="$(./scripts/trial-precheck.sh "$pkg" "$tmp_dir/bin" 2>&1 || true)"
echo "$ok" | grep -q "\[trial-precheck\] SUMMARY" || { echo "[trial-precheck-test] FAIL reason=summary-missing"; echo "$ok"; exit 1; }
echo "$ok" | grep -q '"case":"package_exists","status":"PASS"' || { echo "[trial-precheck-test] FAIL reason=json-pass-missing"; echo "$ok"; exit 1; }
echo "$ok" | grep -q "\[trial-precheck\] PASS summary=all_checks_passed" || { echo "[trial-precheck-test] FAIL reason=overall-pass-missing"; echo "$ok"; exit 1; }

bad="$(./scripts/trial-precheck.sh "$tmp_dir/missing.tgz" "$tmp_dir/bin" 2>&1 || true)"
echo "$bad" | grep -q "\[trial-precheck\] FAIL case=package_exists" || { echo "[trial-precheck-test] FAIL reason=fail-case-missing"; echo "$bad"; exit 1; }
echo "$bad" | grep -q "next:" || { echo "[trial-precheck-test] FAIL reason=next-missing"; echo "$bad"; exit 1; }

echo "[trial-precheck-test] PASS reason=machine-human-output-covered"