#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

current_case=""
on_error() {
  local exit_code="$?"
  if [[ -n "$current_case" ]]; then
    echo "[r5-routing-suite] FAIL case=${current_case} exit=${exit_code}"
  else
    echo "[r5-routing-suite] FAIL case=<unknown> exit=${exit_code}"
  fi
  exit "$exit_code"
}
trap on_error ERR

current_case="route-schema"
zig test src/config.zig --test-filter "provider route schema v1"

current_case="route-mode"
zig test src/config.zig --test-filter "route mode string parsing"

current_case="provider-fallback"
./scripts/test-provider-fallback.sh

current_case="route-log-parse"
./scripts/parse-route-log-sample.sh

echo "[r5-routing-suite] PASS"
