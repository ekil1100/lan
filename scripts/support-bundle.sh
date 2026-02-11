#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

OUT_DIR="${1:-dist}"
CONFIG_DIR="${2:-$HOME/.config/lan}"
LOG_FILE="${3:-$HOME/.local/state/lan/history.log}"

platform="$(uname -s | tr '[:upper:]' '[:lower:]')"
ts="$(date +%Y%m%d-%H%M%S)"
bundle_name="lan-support-${platform}-${ts}.tar.gz"
work_dir=".lan_support_bundle_${ts}"
out_path="${OUT_DIR}/${bundle_name}"

mkdir -p "$OUT_DIR" "$work_dir"
trap 'rm -rf "$work_dir"' EXIT

# version
version="unknown"
if [[ -x "./zig-out/bin/lan" ]]; then
  version="$(./zig-out/bin/lan --version 2>/dev/null || echo unknown)"
elif command -v lan >/dev/null 2>&1; then
  version="$(lan --version 2>/dev/null || echo unknown)"
fi
printf 'version=%s\nplatform=%s\ntimestamp=%s\n' "$version" "$platform" "$ts" > "$work_dir/version.txt"

# config summary (redacted)
config_summary="$work_dir/config-summary.txt"
echo "config_dir=${CONFIG_DIR}" > "$config_summary"
if [[ -d "$CONFIG_DIR" ]]; then
  while IFS= read -r -d '' f; do
    rel="${f#$CONFIG_DIR/}"
    echo "--- file: $rel" >> "$config_summary"
    sed -E 's/(api[_-]?key|token|secret|password)\s*[:=]\s*.*/\1=***REDACTED***/Ig' "$f" 2>/dev/null | head -n 80 >> "$config_summary" || true
  done < <(find "$CONFIG_DIR" -maxdepth 2 -type f -print0)
else
  echo "config_status=missing" >> "$config_summary"
fi

# recent logs
recent_log="$work_dir/recent.log"
if [[ -f "$LOG_FILE" ]]; then
  tail -n 200 "$LOG_FILE" > "$recent_log"
else
  echo "log_status=missing path=${LOG_FILE}" > "$recent_log"
fi

# manifest
cat > "$work_dir/manifest.txt" <<EOF
bundle=${bundle_name}
version=${version}
platform=${platform}
timestamp=${ts}
config_dir=${CONFIG_DIR}
log_file=${LOG_FILE}
EOF

tar -czf "$out_path" -C "$work_dir" .

echo "[support-bundle] PASS output=${out_path}"