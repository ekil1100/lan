#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

PKG_PATH="${1:-}"
TARGET_DIR_INPUT="${2:-}"

platform_name() {
  local os="${PLATFORM_OVERRIDE:-$(uname -s)}"
  case "$os" in
    Darwin) echo "macos" ;;
    Linux) echo "linux" ;;
    *) echo "unknown" ;;
  esac
}

default_target_dir() {
  case "$(platform_name)" in
    macos) echo "$HOME/bin" ;;
    linux) echo "$HOME/.local/bin" ;;
    *) echo "$HOME/.local/bin" ;;
  esac
}

TARGET_DIR="${TARGET_DIR_INPUT:-$(default_target_dir)}"

started_at=$(date +%s)

log_event() {
  local phase="$1" action="$2" target="$3" result="$4" reason="$5"
  local now=$(date +%s)
  local duration_ms=$(( (now - started_at) * 1000 ))
  echo "install_event phase=${phase} action=${action} target=${target} result=${result} reason=${reason} duration_ms=${duration_ms}"
}

if [[ -z "$PKG_PATH" ]]; then
  log_event "end" "install" "-" "fail" "missing_package_path"
  echo "Install failed: missing package path"
  echo "next: run ./scripts/install.sh <local-tarball> [target-dir]"
  exit 1
fi

if [[ ! -f "$PKG_PATH" ]]; then
  log_event "end" "install" "$PKG_PATH" "fail" "package_not_found"
  echo "Install failed: package not found ($PKG_PATH)"
  echo "next: run ./scripts/package-release.sh then retry with the generated tarball path"
  exit 1
fi

tmp_dir=".lan_install_tmp_$(date +%s)"
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir"

if ! tar -xzf "$PKG_PATH" -C "$tmp_dir"; then
  log_event "end" "install" "$PKG_PATH" "fail" "invalid_tarball"
  echo "Install failed: invalid tarball"
  echo "next: regenerate package via ./scripts/package-release.sh and retry"
  exit 1
fi

bin_path="$(find "$tmp_dir" -name lan -type f | head -n 1)"
if [[ -z "$bin_path" ]]; then
  log_event "end" "install" "$PKG_PATH" "fail" "binary_missing"
  echo "Install failed: binary lan not found in package"
  echo "next: ensure package includes lan binary and retry"
  exit 1
fi

if [[ -e "$TARGET_DIR" && ! -d "$TARGET_DIR" ]]; then
  echo "Install failed: target path is a file ($TARGET_DIR)"
  echo "next: choose a directory path, e.g. ~/.local/bin"
  exit 1
fi

if ! mkdir -p "$TARGET_DIR" 2>/dev/null; then
  echo "Install failed: cannot create target directory ($TARGET_DIR)"
  echo "next: check path permissions or use a writable directory"
  exit 1
fi

if [[ ! -w "$TARGET_DIR" ]]; then
  echo "Install failed: target directory not writable ($TARGET_DIR)"
  echo "next: grant write permission or use another install path"
  exit 1
fi

if [[ -d "$TARGET_DIR/lan" ]]; then
  echo "Install failed: conflict at $TARGET_DIR/lan (is directory)"
  echo "next: remove/rename that directory then retry install"
  exit 1
fi

cp "$bin_path" "$TARGET_DIR/lan"
chmod +x "$TARGET_DIR/lan"

log_event "end" "install" "$TARGET_DIR/lan" "success" "install_completed"
echo "Install success: $TARGET_DIR/lan"
echo "platform: $(platform_name)"
