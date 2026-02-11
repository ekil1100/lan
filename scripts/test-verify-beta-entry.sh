#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

out="$(./scripts/verify-beta-entry.sh 2>&1 || true)"
echo "$out" | grep -q "\[beta-entry\] SUMMARY" || { echo "[verify-beta-entry-test] FAIL reason=summary-missing"; echo "$out"; exit 1; }
echo "$out" | grep -q "pass_rate=" || { echo "[verify-beta-entry-test] FAIL reason=pass-rate-missing"; echo "$out"; exit 1; }
# at minimum the doc checks should pass
echo "$out" | grep -q "\[beta-entry\] PASS gate=release-support" || { echo "[verify-beta-entry-test] FAIL reason=release-support-fail"; echo "$out"; exit 1; }

echo "[verify-beta-entry-test] PASS reason=entry-verification-covered"