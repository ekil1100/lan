#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

PKG_PATH="${1:-}"
BIN_DIR="${2:-$HOME/.local/bin}"
CONFIG_DIR="${3:-$HOME/.config/lan}"

if [[ -z "$PKG_PATH" ]]; then
  echo "Upgrade failed: missing package path"
  echo "next: run ./scripts/upgrade.sh <local-tarball> [bin-dir] [config-dir]"
  exit 1
fi

if [[ ! -f "$PKG_PATH" ]]; then
  echo "Upgrade failed: package not found ($PKG_PATH)"
  echo "next: run ./scripts/package-release.sh then retry with generated artifact"
  exit 1
fi

mkdir -p "$BIN_DIR" "$CONFIG_DIR"

before_version="unknown"
if [[ -x "$BIN_DIR/lan" ]]; then
  before_version="$($BIN_DIR/lan --version 2>/dev/null || echo unknown)"
fi

tmp_dir=".lan_upgrade_tmp_$(date +%s)"
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir"

if ! tar -xzf "$PKG_PATH" -C "$tmp_dir"; then
  echo "Upgrade failed: invalid tarball"
  echo "next: regenerate package via ./scripts/package-release.sh and retry"
  exit 1
fi

new_bin="$(find "$tmp_dir" -name lan -type f | head -n 1)"
if [[ -z "$new_bin" ]]; then
  echo "Upgrade failed: binary lan not found in package"
  echo "next: ensure package includes lan binary and retry"
  exit 1
fi

backup_path=""
if [[ -x "$BIN_DIR/lan" ]]; then
  backup_path="$BIN_DIR/lan.bak"
  cp "$BIN_DIR/lan" "$backup_path"
fi

if ! cp "$new_bin" "$BIN_DIR/lan"; then
  if [[ -n "$backup_path" && -f "$backup_path" ]]; then
    cp "$backup_path" "$BIN_DIR/lan"
    echo "Upgrade rollback: restored previous binary"
    echo "next: check disk permissions and retry upgrade"
  else
    echo "Upgrade rollback: no previous binary to restore"
    echo "next: run install script to recover binary"
  fi
  exit 1
fi

chmod +x "$BIN_DIR/lan"

after_version="$($BIN_DIR/lan --version 2>/dev/null || echo unknown)"

if [[ "$after_version" == "unknown" ]]; then
  if [[ -n "$backup_path" && -f "$backup_path" ]]; then
    cp "$backup_path" "$BIN_DIR/lan"
    chmod +x "$BIN_DIR/lan"
    echo "Upgrade rollback: restored previous binary"
    echo "next: package may be corrupted; rebuild package and retry"
  else
    echo "Upgrade rollback: no previous binary to restore"
    echo "next: run install script with a valid package"
  fi
  exit 1
fi

echo "Upgrade success: bin=$BIN_DIR/lan"
echo "version_before: $before_version"
echo "version_after: $after_version"
echo "config_preserved: $CONFIG_DIR"
if [[ -n "$backup_path" && -f "$backup_path" ]]; then
  echo "rollback_backup: $backup_path"
fi
