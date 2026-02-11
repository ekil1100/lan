#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

PKG_PATH="${1:-}"
BIN_DIR="${2:-$HOME/.local/bin}"
CONFIG_DIR="${3:-$HOME/.config/lan}"

started_at=$(date +%s)
log_event() {
  local phase="$1" action="$2" target="$3" result="$4" reason="$5"
  local now=$(date +%s)
  local duration_ms=$(( (now - started_at) * 1000 ))
  echo "install_event phase=${phase} action=${action} target=${target} result=${result} reason=${reason} duration_ms=${duration_ms}"
}

if ! ./scripts/preflight.sh "$BIN_DIR" >/dev/null 2>&1; then
  log_event "end" "upgrade" "$BIN_DIR" "fail" "preflight_failed"
  ./scripts/preflight.sh "$BIN_DIR" || true
  echo "next: fix preflight issues then retry upgrade"
  exit 1
fi

if [[ -z "$PKG_PATH" ]]; then
  log_event "end" "upgrade" "-" "fail" "missing_package_path"
  echo "Upgrade failed: missing package path"
  echo "next: run ./scripts/upgrade.sh <local-tarball> [bin-dir] [config-dir]"
  exit 1
fi

if [[ ! -f "$PKG_PATH" ]]; then
  log_event "end" "upgrade" "$PKG_PATH" "fail" "package_not_found"
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
  log_event "end" "upgrade" "$PKG_PATH" "fail" "invalid_tarball"
  echo "Upgrade failed: invalid tarball"
  echo "next: regenerate package via ./scripts/package-release.sh and retry"
  exit 1
fi

new_bin="$(find "$tmp_dir" -name lan -type f | head -n 1)"
if [[ -z "$new_bin" ]]; then
  log_event "end" "upgrade" "$PKG_PATH" "fail" "binary_missing"
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
    log_event "end" "rollback" "$BIN_DIR/lan" "success" "copy_failed_restored_backup"
    echo "Upgrade rollback: restored previous binary"
    echo "next: check disk permissions and retry upgrade"
  else
    log_event "end" "rollback" "$BIN_DIR/lan" "fail" "copy_failed_no_backup"
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
    log_event "end" "rollback" "$BIN_DIR/lan" "success" "post_upgrade_exec_check_failed_restored_backup"
    echo "Upgrade rollback: restored previous binary"
    echo "next: package may be corrupted; rebuild package and retry"
  else
    log_event "end" "rollback" "$BIN_DIR/lan" "fail" "post_upgrade_exec_check_failed_no_backup"
    echo "Upgrade rollback: no previous binary to restore"
    echo "next: run install script with a valid package"
  fi
  exit 1
fi

if [[ ! -x "$BIN_DIR/lan" ]]; then
  log_event "end" "upgrade" "$BIN_DIR/lan" "fail" "binary_not_executable"
  echo "Upgrade failed: binary is not executable"
  echo "next: run chmod +x on the binary or rerun upgrade"
  exit 1
fi

log_event "end" "upgrade" "$BIN_DIR/lan" "success" "upgrade_completed"
echo "Upgrade success: bin=$BIN_DIR/lan"
echo "version_before: $before_version"
echo "version_after: $after_version"
echo "config_preserved: $CONFIG_DIR"
if [[ -n "$backup_path" && -f "$backup_path" ]]; then
  echo "rollback_backup: $backup_path"
fi
