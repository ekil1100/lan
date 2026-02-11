#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

current_case=""
on_error() {
  echo "[r17-quality-suite] FAIL case=${current_case:-unknown} exit=$?"
  exit 1
}
trap on_error ERR

current_case="e2e-release"
./scripts/test-e2e-release.sh

current_case="known-issues-doc"
[[ -f docs/release/known-issues.md ]]
rg -q "KI-001" docs/release/known-issues.md

current_case="ci-macos-matrix"
rg -q "macos-latest" .github/workflows/ci.yml

echo "[r17-quality-suite] PASS"