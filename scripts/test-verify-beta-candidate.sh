#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

tmp_dir=".lan_beta_candidate_verify_test_$(date +%s)"
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir"

pkg_out="$(./scripts/package-release.sh 2>&1 || true)"
echo "$pkg_out" | grep -q "\[package\] PASS artifact=" || { echo "[beta-candidate-verify-test] FAIL reason=package-failed"; echo "$pkg_out"; exit 1; }
pkg="$(echo "$pkg_out" | sed -n 's/^\[package\] PASS artifact=\([^ ]*\).*/\1/p')"

ok="$(./scripts/verify-beta-candidate.sh "$pkg" "$tmp_dir/bin" 2>&1 || true)"
echo "$ok" | grep -q "\[beta-candidate-verify\] PASS" || { echo "[beta-candidate-verify-test] FAIL reason=pass-missing"; echo "$ok"; exit 1; }

bad="$(./scripts/verify-beta-candidate.sh "$tmp_dir/missing.tar.gz" "$tmp_dir/bin" 2>&1 || true)"
echo "$bad" | grep -q "\[beta-candidate-verify\] FAIL" || { echo "[beta-candidate-verify-test] FAIL reason=fail-missing"; echo "$bad"; exit 1; }
echo "$bad" | grep -q "next:" || { echo "[beta-candidate-verify-test] FAIL reason=next-missing"; echo "$bad"; exit 1; }

echo "[beta-candidate-verify-test] PASS reason=aggregated-check-covered"
