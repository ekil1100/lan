#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

OUT="$(zig test src/agent.zig --test-filter "tool exec non-zero" 2>&1 || true)"

echo "$OUT" | grep -Eq "All [0-9]+ tests passed" || {
  echo "[tools-fail-nonzero] FAIL: regression test did not pass"
  echo "$OUT"
  exit 1
}

echo "[tools-fail-nonzero] PASS"
