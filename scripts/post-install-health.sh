#!/usr/bin/env bash
set -euo pipefail

BIN_PATH="${1:-$HOME/.local/bin/lan}"
EXPECT_VERSION_PREFIX="${EXPECT_VERSION_PREFIX:-lan version=}"

if [[ ! -x "$BIN_PATH" ]]; then
  echo "[post-install-health] FAIL case=binary reason=not_executable path=$BIN_PATH"
  echo "next: install lan binary first (or chmod +x), then rerun health check"
  exit 1
fi

if [[ ! -r "$BIN_PATH" ]]; then
  echo "[post-install-health] FAIL case=binary reason=not_readable path=$BIN_PATH"
  echo "next: grant read permission on binary and rerun health check"
  exit 1
fi

fail_count=0

run_check() {
  local case_name="$1" cmd="$2" next_step="$3"
  if eval "$cmd" >/tmp/lan-post-health.$$ 2>&1; then
    echo "[post-install-health] PASS case=${case_name}"
  else
    fail_count=$((fail_count + 1))
    echo "[post-install-health] FAIL case=${case_name} reason=command_failed"
    sed -n '1,5p' /tmp/lan-post-health.$$ | sed 's/^/[post-install-health] detail: /'
    echo "next: ${next_step}"
  fi
}

run_check "version-readable" "\"$BIN_PATH\" --version | grep -q \"$EXPECT_VERSION_PREFIX\"" "check binary integrity/version output, then reinstall if needed"
run_check "core-command-exec" "printf '/exit\n' | \"$BIN_PATH\" >/dev/null 2>&1" "verify binary startup path and terminal environment"
run_check "dependency-shell" "command -v shasum >/dev/null 2>&1 || command -v sha256sum >/dev/null 2>&1" "install shasum/sha256sum and retry"

rm -f /tmp/lan-post-health.$$ || true

if [[ "$fail_count" -gt 0 ]]; then
  echo "[post-install-health] FAIL summary=${fail_count}_case(s)_failed"
  exit 1
fi

echo "[post-install-health] PASS summary=all_checks_passed"