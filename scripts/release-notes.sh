#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

RANGE="${1:-HEAD~20..HEAD}"
OUT="${2:-dist/release-notes.md}"
VERSION="${VERSION:-${3:-}}"
RELEASE_DATE="${RELEASE_DATE:-${4:-}}"
RELEASE_COMMIT="${RELEASE_COMMIT:-${5:-}}"

if [[ -z "$VERSION" || -z "$RELEASE_DATE" || -z "$RELEASE_COMMIT" ]]; then
  echo "[release-notes] FAIL reason=missing_required_metadata"
  echo "next: provide VERSION, RELEASE_DATE, RELEASE_COMMIT (env or args 3/4/5)"
  exit 1
fi

mkdir -p "$(dirname "$OUT")"

logs="$(git log --pretty=format:'- %h %s' "$RANGE" 2>/dev/null || true)"
if [[ -z "$logs" ]]; then
  logs="- (no commits in range)"
fi

cat > "$OUT" <<EOF
# Release Notes (stub)

- Version: ${VERSION}
- Date: ${RELEASE_DATE}
- Commit: ${RELEASE_COMMIT}

## New
- TODO: summarize new features

## Fixes
- TODO: summarize bug fixes

## Known Issues
- TODO: list known issues / follow-ups

## Commit Summary (${RANGE})
${logs}
EOF

echo "[release-notes] PASS output=${OUT} version=${VERSION} date=${RELEASE_DATE} commit=${RELEASE_COMMIT}"