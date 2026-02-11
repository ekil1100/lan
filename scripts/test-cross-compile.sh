#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

# Cross-compile to Linux x86_64 from any host
echo "[cross-compile] target=x86_64-linux"
zig build -Dtarget=x86_64-linux -Dversion=0.1.0 -Dcommit="$(git rev-parse --short HEAD 2>/dev/null || echo dev)" -Dbuild-time="$(date -u +%Y-%m-%dT%H:%M:%SZ)" 2>&1

binary="zig-out/bin/lan"
[[ -f "$binary" ]] || { echo "[cross-compile] FAIL reason=binary_missing"; exit 1; }

# Verify it's an ELF x86-64 binary
file_out="$(file "$binary")"
echo "$file_out" | grep -q "ELF 64-bit" || { echo "[cross-compile] FAIL reason=not_elf64"; echo "$file_out"; exit 1; }
echo "$file_out" | grep -q "x86-64" || { echo "[cross-compile] FAIL reason=not_x86_64"; echo "$file_out"; exit 1; }

echo "[cross-compile] PASS binary=$binary"

# Rebuild native for subsequent tests
zig build -Dversion=0.1.0 -Dcommit="$(git rev-parse --short HEAD 2>/dev/null || echo dev)" -Dbuild-time="$(date -u +%Y-%m-%dT%H:%M:%SZ)" 2>&1