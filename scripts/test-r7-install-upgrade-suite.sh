#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

current_case=""
on_error() {
  local exit_code="$?"
  if [[ -n "$current_case" ]]; then
    echo "[r7-install-upgrade-suite] FAIL case=${current_case} exit=${exit_code}"
  else
    echo "[r7-install-upgrade-suite] FAIL case=<unknown> exit=${exit_code}"
  fi
  exit "$exit_code"
}
trap on_error ERR

current_case="install-conflict"
./scripts/test-install-path-conflict.sh

current_case="upgrade-rollback"
./scripts/test-upgrade-local.sh

current_case="package-verify"
./scripts/test-package-release.sh

current_case="install-upgrade-log-parse"
./scripts/parse-install-upgrade-log-sample.sh

echo "[r7-install-upgrade-suite] PASS"
