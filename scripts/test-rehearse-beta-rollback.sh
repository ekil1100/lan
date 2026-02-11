#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

tmp_dir=".lan_beta_rollback_test_$(date +%s)"
trap 'rm -rf "$tmp_dir"' EXIT

ok="$(./scripts/rehearse-beta-rollback.sh success "$tmp_dir/success" 2>&1 || true)"
echo "$ok" | grep -q "\[beta-rollback-rehearsal\] PASS case=success-path" || {
  echo "[beta-rollback-test] FAIL reason=success-branch-failed"
  echo "$ok"
  exit 1
}

bad="$(./scripts/rehearse-beta-rollback.sh fail "$tmp_dir/fail" 2>&1 || true)"
echo "$bad" | grep -q "\[beta-rollback-rehearsal\] PASS case=fail-path" || {
  echo "[beta-rollback-test] FAIL reason=fail-branch-failed"
  echo "$bad"
  exit 1
}

echo "[beta-rollback-test] PASS reason=success-fail-branches-covered"