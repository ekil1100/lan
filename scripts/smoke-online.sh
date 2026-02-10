#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT

if [[ -z "${MOONSHOT_API_KEY:-}" && -z "${OPENAI_API_KEY:-}" && -z "${ANTHROPIC_API_KEY:-}" ]]; then
  echo "[smoke-online] FAIL: no API key set (MOONSHOT_API_KEY/OPENAI_API_KEY/ANTHROPIC_API_KEY)"
  exit 1
fi

export HOME="$TMP_HOME"
export XDG_CONFIG_HOME="$TMP_HOME/.config"

cd "$ROOT_DIR"

echo "[smoke-online] building..."
zig build >/dev/null

echo "[smoke-online] run chat..."
printf 'hello\n/exit\n' | ./zig-out/bin/lan >/dev/null

HISTORY_FILE="$XDG_CONFIG_HOME/lan/history.json"
if [[ ! -f "$HISTORY_FILE" ]]; then
  echo "[smoke-online] FAIL: history file not created"
  exit 1
fi

if ! grep -q '"role": "user"' "$HISTORY_FILE"; then
  echo "[smoke-online] FAIL: user message not persisted"
  exit 1
fi

if ! grep -q '"role": "assistant"' "$HISTORY_FILE"; then
  echo "[smoke-online] FAIL: assistant response not persisted"
  exit 1
fi

echo "[smoke-online] PASS"
