#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

current_case=""
on_error() {
  local exit_code="$?"
  if [[ -n "$current_case" ]]; then
    echo "[r9-ops-readiness-suite] FAIL case=${current_case} exit=${exit_code}"
  else
    echo "[r9-ops-readiness-suite] FAIL case=<unknown> exit=${exit_code}"
  fi
  exit "$exit_code"
}
trap on_error ERR

current_case="preflight-json"
./scripts/test-preflight-json.sh

current_case="release-notes"
./scripts/test-release-notes.sh

current_case="support-bundle"
./scripts/test-support-bundle.sh

current_case="ops-docs"
./scripts/preflight.sh --json "$HOME/.local/bin" >/dev/null
pkg_out="$(./scripts/package-release.sh 2>&1)"
pkg="$(echo "$pkg_out" | sed -n 's/^\[package\] PASS artifact=\([^ ]*\).*/\1/p')"
if [[ -z "$pkg" ]]; then
  echo "[r9-ops-readiness-suite] FAIL case=ops-docs exit=1"
  echo "$pkg_out"
  exit 1
fi
./scripts/verify-package.sh "$pkg" >/dev/null

echo "[r9-ops-readiness-suite] PASS"
