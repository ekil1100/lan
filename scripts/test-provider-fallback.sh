#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

out="$(zig test src/llm.zig --test-filter "provider fallback" 2>&1 || true)"

echo "$out" | grep -Eq "All [0-9]+ tests passed" || {
  echo "[provider-fallback] FAIL reason=fallback-tests-not-passed"
  echo "$out"
  exit 1
}

echo "[provider-fallback] PASS reason=fallback-tests-passed"
