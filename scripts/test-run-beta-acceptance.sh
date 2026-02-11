#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

tmp_dir=".lan_beta_acceptance_test_$(date +%s)"
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir"

pkg_out="$(./scripts/package-release.sh 2>&1 || true)"
echo "$pkg_out" | grep -q "\[package\] PASS artifact=" || { echo "[beta-acceptance-test] FAIL reason=package-failed"; echo "$pkg_out"; exit 1; }
pkg="$(echo "$pkg_out" | sed -n 's/^\[package\] PASS artifact=\([^ ]*\).*/\1/p')"

ok="$(./scripts/run-beta-acceptance.sh "$pkg" "$tmp_dir/bin" "$tmp_dir/report.md" 2>&1 || true)"
echo "$ok" | grep -q "\[beta-acceptance\] PASS" || { echo "[beta-acceptance-test] FAIL reason=pass-missing"; echo "$ok"; exit 1; }
[[ -f "$tmp_dir/report.md" ]] || { echo "[beta-acceptance-test] FAIL reason=report-missing"; exit 1; }

echo "[beta-acceptance-test] PASS reason=e2e-acceptance-entry-covered"