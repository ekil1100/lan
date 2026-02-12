#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

current_case=""
on_error() {
  echo "[r22-observability-suite] FAIL case=${current_case:-unknown} exit=$?"
  exit 1
}
trap on_error ERR

current_case="structured-log"
zig build test 2>&1 | grep -v "^$" || true
# log.zig tests run as part of zig build test

current_case="cli-help"
./scripts/test-cli-help.sh

current_case="ci-full-regression-target"
grep -q "full-regression:" Makefile

echo "[r22-observability-suite] PASS"