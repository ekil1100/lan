#!/usr/bin/env bash
set -euo pipefail

JSON_MODE=0
if [[ "${1:-}" == "--json" ]]; then
  JSON_MODE=1
  shift
fi

TARGET_DIR="${1:-$HOME/.local/bin}"

emit_fail() {
  local reason="$1" next="$2"
  if [[ "$JSON_MODE" -eq 1 ]]; then
    printf '{"ok":false,"reason":"%s","target":"%s","next":"%s"}\n' "$reason" "$TARGET_DIR" "$next"
  else
    echo "[preflight] FAIL reason=${reason}"
    echo "next: ${next}"
  fi
  exit 1
}

emit_pass() {
  if [[ "$JSON_MODE" -eq 1 ]]; then
    printf '{"ok":true,"reason":"ok","target":"%s","next":"-"}\n' "$TARGET_DIR"
  else
    echo "[preflight] PASS target=${TARGET_DIR}"
  fi
}

# 1) shell
if [[ -z "${SHELL:-}" ]]; then
  emit_fail "shell_missing" "set SHELL environment variable and retry"
fi

# 2) target path sanity
if [[ -e "$TARGET_DIR" && ! -d "$TARGET_DIR" ]]; then
  emit_fail "target_not_directory" "choose a directory path, e.g. ~/.local/bin"
fi

# 3) writable check
if ! mkdir -p "$TARGET_DIR" 2>/dev/null; then
  emit_fail "target_create_failed" "use a writable install path or fix permissions"
fi
if [[ ! -w "$TARGET_DIR" ]]; then
  emit_fail "target_not_writable" "grant write permission or use another path"
fi

# 4) sha tool availability
if ! command -v shasum >/dev/null 2>&1 && ! command -v sha256sum >/dev/null 2>&1; then
  emit_fail "sha_tool_missing" "install shasum/sha256sum and retry"
fi

emit_pass
