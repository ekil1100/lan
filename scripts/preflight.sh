#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-$HOME/.local/bin}"

fail() {
  local reason="$1" next="$2"
  echo "[preflight] FAIL reason=${reason}"
  echo "next: ${next}"
  exit 1
}

# 1) shell
if [[ -z "${SHELL:-}" ]]; then
  fail "shell_missing" "set SHELL environment variable and retry"
fi

# 2) target path sanity
if [[ -e "$TARGET_DIR" && ! -d "$TARGET_DIR" ]]; then
  fail "target_not_directory" "choose a directory path, e.g. ~/.local/bin"
fi

# 3) writable check
if ! mkdir -p "$TARGET_DIR" 2>/dev/null; then
  fail "target_create_failed" "use a writable install path or fix permissions"
fi
if [[ ! -w "$TARGET_DIR" ]]; then
  fail "target_not_writable" "grant write permission or use another path"
fi

# 4) sha tool availability
if ! command -v shasum >/dev/null 2>&1 && ! command -v sha256sum >/dev/null 2>&1; then
  fail "sha_tool_missing" "install shasum/sha256sum and retry"
fi

echo "[preflight] PASS target=${TARGET_DIR}"
