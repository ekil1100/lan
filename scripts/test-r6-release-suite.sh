#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

current_case=""
on_error() {
  local exit_code="$?"
  if [[ -n "$current_case" ]]; then
    echo "[r6-release-suite] FAIL case=${current_case} exit=${exit_code}"
  else
    echo "[r6-release-suite] FAIL case=<unknown> exit=${exit_code}"
  fi
  exit "$exit_code"
}
trap on_error ERR

current_case="version"
./scripts/test-version.sh

current_case="package"
./scripts/test-package-release.sh

current_case="install"
./scripts/test-install-local.sh

current_case="upgrade"
./scripts/test-upgrade-local.sh

echo "[r6-release-suite] PASS"
