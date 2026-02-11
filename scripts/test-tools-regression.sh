#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

zig test src/agent.zig --test-filter "tool regression v1" >/dev/null

echo "[tools-regression] PASS"
