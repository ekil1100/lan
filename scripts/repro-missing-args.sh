#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

zig test src/agent.zig --test-filter "tool missing-argument" >/dev/null

echo "[missing-args] PASS"
