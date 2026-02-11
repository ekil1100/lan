#!/usr/bin/env bash
set -euo pipefail

CONFIG="${1:-$HOME/.config/lan/config.json}"

if [[ ! -f "$CONFIG" ]]; then
  echo "[validate-config] FAIL reason=file_not_found path=$CONFIG"
  echo "next: copy docs/config/config.template.json to $CONFIG and fill in values"
  exit 1
fi

# Validate JSON syntax
if ! python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$CONFIG" 2>/dev/null; then
  echo "[validate-config] FAIL reason=invalid_json path=$CONFIG"
  echo "next: fix JSON syntax (try: python3 -m json.tool $CONFIG)"
  exit 1
fi

missing=0
issues=""

check_field() {
  local path="$1" next="$2"
  if ! python3 -c "
import json,sys
d=json.load(open(sys.argv[1]))
keys=sys.argv[2].split('.')
v=d
for k in keys:
    v=v.get(k) if isinstance(v,dict) else None
    if v is None: sys.exit(1)
if isinstance(v,str) and v=='': sys.exit(1)
" "$CONFIG" "$path" 2>/dev/null; then
    missing=$((missing+1))
    issues+="$path;"
    echo "[validate-config] FAIL field=$path"
    echo "next: $next"
  fi
}

check_field "provider.url" "set provider.url (e.g., https://api.openai.com)"
check_field "provider.model" "set provider.model (e.g., gpt-4)"

if [[ "$missing" -gt 0 ]]; then
  echo "[validate-config] FAIL summary=${missing}_missing_field(s) issues=$issues"
  exit 1
fi

echo "[validate-config] PASS path=$CONFIG"