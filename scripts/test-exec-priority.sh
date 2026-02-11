#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

OUT="$(zig test src/agent.zig --test-filter "tool exec" 2>&1 || true)"

echo "$OUT" | grep -Eq "All [0-9]+ tests passed" || {
  echo "[exec-priority] FAIL: expected exec tests to pass"
  echo "$OUT"
  exit 1
}

echo "[exec-priority] PASS"
