#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

current_case=""
on_error() {
  echo "[r19-stability-suite] FAIL case=${current_case:-unknown} exit=$?"
  exit 1
}
trap on_error ERR

current_case="history-search"
./scripts/test-history-search.sh

current_case="preflight-provider"
./scripts/test-preflight-provider.sh

current_case="error-codes-doc"
[[ -f docs/errors.md ]]
rg -q "E101" docs/errors.md
rg -q "E301" docs/errors.md
rg -q "E401" docs/errors.md

echo "[r19-stability-suite] PASS"