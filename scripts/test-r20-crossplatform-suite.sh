#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

current_case=""
on_error() {
  echo "[r20-crossplatform-suite] FAIL case=${current_case:-unknown} exit=$?"
  exit 1
}
trap on_error ERR

current_case="cross-compile"
./scripts/test-cross-compile.sh

current_case="config-validation"
./scripts/test-validate-config.sh

current_case="history-clear"
./scripts/test-history-clear.sh

echo "[r20-crossplatform-suite] PASS"