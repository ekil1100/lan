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

protocol_observability_cases=(
  "./scripts/parse-tool-log-sample.sh"
  "./scripts/test-tool-protocol-structure.sh"
)

current_case=""

on_error() {
  local exit_code="$?"
  if [[ -n "$current_case" ]]; then
    echo "[regression-suite] FAIL case=${current_case} exit=${exit_code}"
  else
    echo "[regression-suite] FAIL case=<unknown> exit=${exit_code}"
  fi
  exit "$exit_code"
}
trap on_error ERR

# For local reproducible failure demo:
#   REGRESSION_FAIL_AT=./scripts/test-commands.sh ./scripts/test-regression-suite.sh
for c in "${cases[@]}"; do
  current_case="$c"
  echo "[regression] running: $c"

  if [[ "${REGRESSION_FAIL_AT:-}" == "$c" ]]; then
    echo "[regression] injected failure at: $c"
    false
  fi

  "$c"
done

echo "[regression-suite] PASS"

for c in "${protocol_observability_cases[@]}"; do
  current_case="$c"
  echo "[protocol-observability] running: $c"

  if [[ "${REGRESSION_FAIL_AT:-}" == "$c" ]]; then
    echo "[protocol-observability] injected failure at: $c"
    false
  fi

  "$c"
done

echo "[protocol-observability-suite] PASS"
