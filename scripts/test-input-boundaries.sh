#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

zig build >/dev/null

run_case() {
  local input="$1"
  local out_file="$2"
  local history_file="$3"

  local tmp_home
  tmp_home="$(mktemp -d)"
  mkdir -p "$tmp_home/.config/lan"
  cat >"$tmp_home/.config/lan/config.json" <<'EOF'
{"provider":"openai","model":"gpt-4o-mini","base_url":"http://127.0.0.1:9/v1","api_key":"sk-dummy"}
EOF

  HOME="$tmp_home" XDG_CONFIG_HOME="$tmp_home/.config" \
    ./zig-out/bin/lan <<<"$input" >"$out_file" 2>&1 || true

  cp "$tmp_home/.config/lan/history.json" "$history_file"
  rm -rf "$tmp_home"
}

OUT1="$(mktemp)"; HIS1="$(mktemp)"
OUT2="$(mktemp)"; HIS2="$(mktemp)"
OUT3="$(mktemp)"; HIS3="$(mktemp)"
trap 'rm -f "$OUT1" "$HIS1" "$OUT2" "$HIS2" "$OUT3" "$HIS3"' EXIT

# 1) Empty input should not trigger model call / user message append
run_case $'\n\n/exit\n' "$OUT1" "$HIS1"
if grep -q '"role": "user"' "$HIS1"; then
  echo "[input-boundary] FAIL: empty input produced user message"
  exit 1
fi

# 2) Multiline input should be preserved as one user message
run_case $'"""\nline 1\nline 2\n"""\n/exit\n' "$OUT2" "$HIS2"
if ! grep -q 'line 1\\nline 2' "$HIS2"; then
  echo "[input-boundary] FAIL: multiline content not preserved"
  exit 1
fi

# 3) Empty multiline block should be ignored
run_case $'"""\n"""\n/exit\n' "$OUT3" "$HIS3"
if ! grep -q 'Empty multiline input ignored\.' "$OUT3"; then
  echo "[input-boundary] FAIL: empty multiline block hint missing"
  exit 1
fi
if grep -q '"role": "user"' "$HIS3"; then
  echo "[input-boundary] FAIL: empty multiline block produced user message"
  exit 1
fi

# 4) Unclosed multiline block should not crash and should show hint
if ! run_case $'"""\nunterminated\n' "$OUT3" "$HIS3"; then
  true
fi
if ! grep -Fq 'Multiline input not closed (missing """). Input discarded.' "$OUT3"; then
  echo "[input-boundary] FAIL: unclosed multiline hint missing"
  exit 1
fi
if grep -q '"role": "user"' "$HIS3"; then
  echo "[input-boundary] FAIL: unclosed multiline produced user message"
  exit 1
fi

echo "[input-boundary] PASS"
