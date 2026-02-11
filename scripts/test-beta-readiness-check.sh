#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

out="$(./scripts/check-beta-readiness.sh 2>&1 || true)"
echo "$out" | grep -q "\[beta-check\] PASS summary=all_items_passed" || {
  echo "[beta-check-test] FAIL reason=runner-not-pass"
  echo "$out"
  exit 1
}

echo "[beta-check-test] PASS reason=runner-covered"
