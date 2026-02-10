#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_HOME="$(mktemp -d)"
trap 'if [[ -n "${SERVER_PID:-}" ]]; then kill "$SERVER_PID" >/dev/null 2>&1 || true; wait "$SERVER_PID" 2>/dev/null || true; fi; rm -rf "$TMP_HOME"' EXIT

export HOME="$TMP_HOME"
export XDG_CONFIG_HOME="$TMP_HOME/.config"
mkdir -p "$XDG_CONFIG_HOME/lan"

unset MOONSHOT_API_KEY OPENAI_API_KEY ANTHROPIC_API_KEY || true

cd "$ROOT_DIR"
zig build >/dev/null

# Case 1: network error (connection refused)
cat > "$XDG_CONFIG_HOME/lan/config.json" <<'EOF'
{"provider":"openai","model":"gpt-4o-mini","base_url":"http://127.0.0.1:9/v1","api_key":"sk-dummy"}
EOF

OUT_NET="$(printf 'hello\n/exit\n' | ./zig-out/bin/lan || true)"
echo "$OUT_NET" | grep -q "\[error:network\]" || { echo "[error-repro] FAIL: network label missing"; exit 1; }

# Case 2: provider error (reachable server returns non-2xx)
PORT=18081
python3 -m http.server "$PORT" --bind 127.0.0.1 >/dev/null 2>&1 &
SERVER_PID=$!
sleep 0.4

cat > "$XDG_CONFIG_HOME/lan/config.json" <<EOF
{"provider":"openai","model":"gpt-4o-mini","base_url":"http://127.0.0.1:${PORT}","api_key":"sk-dummy"}
EOF

OUT_PROVIDER="$(printf 'hello\n/exit\n' | ./zig-out/bin/lan || true)"
echo "$OUT_PROVIDER" | grep -q "\[error:provider\]" || { echo "[error-repro] FAIL: provider label missing"; exit 1; }

kill "$SERVER_PID" >/dev/null 2>&1 || true
wait "$SERVER_PID" 2>/dev/null || true
SERVER_PID=""

echo "[error-repro] PASS"
