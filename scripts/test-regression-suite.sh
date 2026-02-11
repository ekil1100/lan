#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

cases=(
  "./scripts/test-commands.sh"
  "./scripts/test-input-boundaries.sh"
  "./scripts/test-error-classification.sh"
  "./scripts/test-error-network-provider.sh"
  "./scripts/repro-exec-timeout.sh"
  "./scripts/repro-missing-args.sh"
  "./scripts/test-tools-fail-nonzero.sh"
  "./scripts/test-exec-priority.sh"
  "./scripts/test-tools-regression.sh"
)

for c in "${cases[@]}"; do
  echo "[regression] running: $c"
  "$c"
done

echo "[regression-suite] PASS"
