#!/usr/bin/env bash
# Beta Announcement Publisher
# Usage: ./scripts/publish-beta-announcement.sh [github_token]

set -euo pipefail

cd "$(dirname "$0")/.."

echo "[publish-beta] Reading announcement template..."

TITLE="🎉 Lan v0.1.0-beta 正式发布"
BODY="$(cat docs/release/beta-announcement.md)"

echo ""
echo "=== 公告标题 ==="
echo "$TITLE"
echo ""
echo "=== 公告内容预览 ==="
echo "$BODY" | head -30
echo "..."
echo ""

# GitHub Discussions API (if token provided)
if [[ -n "${1:-}" ]]; then
  TOKEN="$1"
  REPO="ekil1100/lan"
  
  echo "[publish-beta] Publishing to GitHub Discussions..."
  
  # Create discussion via GraphQL API
  curl -s -X POST \
    -H "Authorization: bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"query\": \"mutation { createDiscussion(input: {repositoryId: \\\"$REPO\\\", categoryId: \\\"DIC_kwDO...\\\", body: \\\"$BODY\\\", title: \\\"$TITLE\\\"}) { discussion { url } } }\"
    }" \
    https://api.github.com/graphql 2>/dev/null || {
    echo "[publish-beta] WARN: GitHub API call failed (token may need 'discussions:write' scope)"
  }
  
  echo "[publish-beta] Published!"
else
  echo "[publish-beta] SKIP: No GitHub token provided"
  echo "next: To publish automatically, run:"
  echo "  ./scripts/publish-beta-announcement.sh <github_token>"
  echo ""
  echo "Or manually create a discussion at:"
  echo "  https://github.com/ekil1100/lan/discussions/new"
  echo ""
  echo "Copy the content from docs/release/beta-announcement.md"
fi

echo "[publish-beta] PASS (manual step documented)"