#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT

export HOME="$TMP_HOME"
export XDG_CONFIG_HOME="$TMP_HOME/.config"
unset MOONSHOT_API_KEY OPENAI_API_KEY ANTHROPIC_API_KEY || true

cd "$ROOT_DIR"
zig build >/dev/null

OUT="$(printf 'hello\n/exit\n' | ./zig-out/bin/lan || true)"

echo "$OUT" | grep -q "\[error:config\]" || { echo "[error-class] FAIL: config class not shown"; exit 1; }
echo "$OUT" | grep -q "set MOONSHOT_API_KEY / OPENAI_API_KEY / ANTHROPIC_API_KEY" || { echo "[error-class] FAIL: actionable hint missing"; exit 1; }

echo "[error-class] PASS"
