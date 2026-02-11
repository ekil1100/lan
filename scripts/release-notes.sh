#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

RANGE="${1:-HEAD~20..HEAD}"
OUT="${2:-dist/release-notes.md}"

mkdir -p "$(dirname "$OUT")"

logs="$(git log --pretty=format:'- %h %s' "$RANGE" 2>/dev/null || true)"
if [[ -z "$logs" ]]; then
  logs="- (no commits in range)"
fi

cat > "$OUT" <<EOF
# Release Notes (stub)

## New
- TODO: summarize new features

## Fixes
- TODO: summarize bug fixes

## Known Issues
- TODO: list known issues / follow-ups

## Commit Summary (${RANGE})
${logs}
EOF

echo "[release-notes] PASS output=${OUT}"