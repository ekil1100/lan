#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

current_case=""
on_error() {
  echo "[r24-prerelease-suite] FAIL case=${current_case:-unknown} exit=$?"
  exit 1
}
trap on_error ERR

current_case="version-enhanced"
./scripts/test-version-enhanced.sh

current_case="release-checklist"
[[ -f docs/release/release-checklist.md ]]
rg -q "版本号确认" docs/release/release-checklist.md

current_case="verify-tag-release"
./scripts/test-verify-tag-release.sh

echo "[r24-prerelease-suite] PASS"