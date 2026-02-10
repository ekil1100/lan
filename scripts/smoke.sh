#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT

export HOME="$TMP_HOME"
export XDG_CONFIG_HOME="$TMP_HOME/.config"

cd "$ROOT_DIR"

echo "[smoke] building..."
zig build >/dev/null

echo "[smoke] boot + clean exit..."
printf '/exit\n' | ./zig-out/bin/lan >/dev/null

HISTORY_FILE="$XDG_CONFIG_HOME/lan/history.json"
if [[ ! -f "$HISTORY_FILE" ]]; then
  echo "[smoke] FAIL: history file not created: $HISTORY_FILE"
  exit 1
fi

if ! grep -q '"role": "system"' "$HISTORY_FILE"; then
  echo "[smoke] FAIL: history file missing system message"
  exit 1
fi

echo "[smoke] history write OK"

if [[ -n "${MOONSHOT_API_KEY:-}" || -n "${OPENAI_API_KEY:-}" || -n "${ANTHROPIC_API_KEY:-}" ]]; then
  echo "[smoke] chat path (with API key) ..."
  printf 'hello\n/exit\n' | ./zig-out/bin/lan >/dev/null
  if ! grep -q '"role": "user"' "$HISTORY_FILE"; then
    echo "[smoke] FAIL: chat run did not persist user message"
    exit 1
  fi
  echo "[smoke] chat persistence OK"
else
  echo "[smoke] SKIP chat path (no API key in env)"
fi

echo "[smoke] PASS"
