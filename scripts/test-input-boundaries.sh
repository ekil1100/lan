#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT

export HOME="$TMP_HOME"
export XDG_CONFIG_HOME="$TMP_HOME/.config"

cd "$ROOT_DIR"

zig build >/dev/null

# 1) Empty input should not trigger model call / user message append
printf '\n\n/exit\n' | ./zig-out/bin/lan >/dev/null || true
HISTORY_FILE="$XDG_CONFIG_HOME/lan/history.json"
if grep -q '"role": "user"' "$HISTORY_FILE"; then
  echo "[input-boundary] FAIL: empty input produced user message"
  exit 1
fi

# 2) Multiline input should be preserved as one user message
printf '"""\nline 1\nline 2\n"""\n/exit\n' | ./zig-out/bin/lan >/dev/null || true
if ! grep -q 'line 1\\nline 2' "$HISTORY_FILE"; then
  echo "[input-boundary] FAIL: multiline content not preserved"
  exit 1
fi

echo "[input-boundary] PASS"
