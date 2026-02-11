#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

current_case=""
on_error() {
  local exit_code="$?"
  if [[ -n "$current_case" ]]; then
    echo "[r8-release-experience-suite] FAIL case=${current_case} exit=${exit_code}"
  else
    echo "[r8-release-experience-suite] FAIL case=<unknown> exit=${exit_code}"
  fi
  exit "$exit_code"
}
trap on_error ERR

current_case="install-platform"
./scripts/test-install-platform-path.sh

current_case="upgrade-rollback"
./scripts/test-upgrade-local.sh

current_case="preflight"
./scripts/test-preflight.sh

current_case="release-notes"
./scripts/test-release-notes.sh

echo "[r8-release-experience-suite] PASS"
