#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT

export HOME="$TMP_HOME"
export XDG_CONFIG_HOME="$TMP_HOME/.config"

cd "$ROOT_DIR"

zig build >/dev/null

OUT="$(printf '/help\n/help\n/clear\n/exit\n' | ./zig-out/bin/lan || true)"

echo "$OUT" | grep -q "Commands:" || { echo "[commands] FAIL: /help did not show help"; exit 1; }
echo "$OUT" | grep -q "Help hidden." || { echo "[commands] FAIL: /help toggle hide missing"; exit 1; }
echo "$OUT" | grep -q "History cleared (system message kept)." || { echo "[commands] FAIL: /clear output missing"; exit 1; }
echo "$OUT" | grep -q "Thanks for using Lan! Goodbye!" || { echo "[commands] FAIL: /exit flow missing"; exit 1; }

echo "[commands] PASS"
