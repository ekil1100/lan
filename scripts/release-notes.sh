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

# Collect commits and auto-categorize by conventional commit prefix
feats="" fixes="" docs="" ci="" other=""

while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  sha="${line%% *}"
  msg="${line#* }"
  entry="- ${sha} ${msg}"
  case "$msg" in
    feat*|Feature*|add*|Add*) feats+="${entry}"$'\n' ;;
    fix*|Fix*|bugfix*) fixes+="${entry}"$'\n' ;;
    docs*|doc*|Docs*|Doc*) docs+="${entry}"$'\n' ;;
    ci*|build*|CI*|Build*) ci+="${entry}"$'\n' ;;
    *) other+="${entry}"$'\n' ;;
  esac
done < <(git log --pretty=format:'%h %s' "$RANGE" 2>/dev/null || true)

section() {
  local title="$1" content="$2"
  if [[ -n "$content" ]]; then
    printf "## %s\n%s\n" "$title" "$content"
  fi
}

{
  cat <<EOF
# Release Notes — ${VERSION}

- **Version**: ${VERSION}
- **Date**: ${RELEASE_DATE}
- **Commit**: ${RELEASE_COMMIT}

EOF

  section "✨ Features" "$feats"
  section "🐛 Fixes" "$fixes"
  section "📝 Documentation" "$docs"
  section "🔧 CI / Build" "$ci"
  section "📦 Other" "$other"

  if [[ -z "$feats$fixes$docs$ci$other" ]]; then
    echo "_(no commits in range)_"
  fi
} > "$OUT"

echo "[release-notes] PASS output=${OUT} version=${VERSION} date=${RELEASE_DATE} commit=${RELEASE_COMMIT}"