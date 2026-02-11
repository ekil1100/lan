#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

OUT="$(zig test src/agent.zig --test-filter "tool regression v1" 2>&1 || true)"

echo "$OUT" | grep -Eq "All [0-9]+ tests passed" || {
  echo "[tools-regression] FAIL reason=regression-tests-not-passed"
  echo "$OUT"
  exit 1
}

echo "[tools-regression] PASS reason=regression-tests-passed"
