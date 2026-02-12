#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

current_case=""
on_error() {
  echo "[r21-ux-suite] FAIL case=${current_case:-unknown} exit=$?"
  exit 1
}
trap on_error ERR

current_case="config-init"
./scripts/test-config-init.sh

current_case="doctor"
./scripts/test-lan-doctor.sh

current_case="support-bundle"
./scripts/test-support-bundle.sh

echo "[r21-ux-suite] PASS"