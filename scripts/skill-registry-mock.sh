#!/usr/bin/env bash
# Skill registry mock for testing
# Serves a local JSON index for `lan skill search` testing

set -euo pipefail

REGISTRY_FILE="${1:-/tmp/lan-skill-registry.json}"
PORT="${2:-8765}"

cat > "$REGISTRY_FILE" <<'EOF'
{
  "version": "1.0.0",
  "updated_at": "2026-02-12T14:00:00Z",
  "skills": [
    {
      "name": "hello-world",
      "version": "0.1.0",
      "description": "A minimal example skill for Lan",
      "author": "lan-team",
      "url": "https://github.com/ekil1100/lan/tree/main/skills/hello-world",
      "download_url": "https://github.com/ekil1100/lan/releases/download/v0.1.0-beta/hello-world-0.1.0.tar.gz",
      "sha256": "0000000000000000000000000000000000000000000000000000000000000000",
      "tools": ["exec"],
      "permissions": ["read", "write"],
      "tags": ["example", "demo", "minimal"]
    },
    {
      "name": "file-utils",
      "version": "0.2.0",
      "description": "File manipulation utilities",
      "author": "community",
      "url": "https://github.com/example/lan-file-utils",
      "download_url": "https://example.com/lan-skills/file-utils-0.2.0.tar.gz",
      "sha256": "1111111111111111111111111111111111111111111111111111111111111111",
      "tools": ["read_file", "write_file", "list_directory"],
      "permissions": ["read", "write"],
      "tags": ["files", "utils"]
    }
  ]
}
EOF

echo "[skill-registry-mock] Registry file: $REGISTRY_FILE"
echo "[skill-registry-mock] Start HTTP server on port $PORT:"
echo "  python3 -m http.server $PORT --directory $(dirname $REGISTRY_FILE)"
echo ""
echo "Test with:"
echo "  curl http://localhost:$PORT/$(basename $REGISTRY_FILE)"
