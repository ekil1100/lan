#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

tmp_dir=".lan_beta_snapshot_test_$(date +%s)"
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir"

pkg_out="$(./scripts/package-release.sh 2>&1 || true)"
echo "$pkg_out" | grep -q "\[package\] PASS artifact=" || { echo "[beta-snapshot-test] FAIL reason=package-failed"; echo "$pkg_out"; exit 1; }
pkg="$(echo "$pkg_out" | sed -n 's/^\[package\] PASS artifact=\([^ ]*\).*/\1/p')"

out="$(./scripts/snapshot-beta-acceptance.sh "$pkg" "$tmp_dir/bin" "$tmp_dir/out" 2>&1 || true)"
echo "$out" | grep -q "\[beta-snapshot\] PASS" || { echo "[beta-snapshot-test] FAIL reason=snapshot-not-pass"; echo "$out"; exit 1; }

snap_dir="$(echo "$out" | sed -n 's/^\[beta-snapshot\] PASS out=\([^ ]*\).*/\1/p')"
[[ -f "$snap_dir/results.jsonl" ]] || { echo "[beta-snapshot-test] FAIL reason=results-jsonl-missing"; exit 1; }
[[ -f "$snap_dir/summary.txt" ]] || { echo "[beta-snapshot-test] FAIL reason=summary-missing"; exit 1; }
grep -q '"case":"checklist"' "$snap_dir/results.jsonl" || { echo "[beta-snapshot-test] FAIL reason=case-missing"; exit 1; }
grep -q 'Human Summary' "$snap_dir/summary.txt" || { echo "[beta-snapshot-test] FAIL reason=human-summary-missing"; exit 1; }

echo "[beta-snapshot-test] PASS reason=snapshot-machine-human-output-covered"