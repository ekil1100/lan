#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

current_case=""
on_error() {
  echo "[r23-features-suite] FAIL case=${current_case:-unknown} exit=$?"
  exit 1
}
trap on_error ERR

current_case="multi-provider"
./scripts/test-multi-provider.sh

current_case="skill-info"
./scripts/test-skill-info.sh

current_case="history-stats"
./scripts/test-history-stats.sh

echo "[r23-features-suite] PASS"