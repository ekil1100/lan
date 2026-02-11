#!/usr/bin/env bash
set -euo pipefail

FILE="${1:-docs/release/beta-go-no-go-template.md}"

if [[ ! -f "$FILE" ]]; then
  echo "[go-no-go-validate] FAIL reason=file_not_found path=$FILE"
  echo "next: provide a valid go/no-go report file"
  exit 1
fi

missing=0
check_field() {
  local name="$1" pattern="$2" next="$3"
  if ! rg -q "$pattern" "$FILE"; then
    missing=$((missing+1))
    echo "[go-no-go-validate] FAIL field=$name"
    echo "next: $next"
  fi
}

# required presence
check_field "pass_rate" "pass_rate" "add pass_rate from summarize-beta-trial output"
check_field "failed_items" "failed_items" "add failed_items from summarize-beta-trial output"
check_field "pending_items" "pending_items" "add pending_items from summarize-beta-trial output"
check_field "owner" "Owner" "fill owner for each risk row"
check_field "mitigation" "Mitigation Action" "fill mitigation action for each risk row"
check_field "due_time" "Due Time" "fill due time for each risk row"

# sanity: should not remain placeholder-only in decision line
if rg -q "<why>|<risk>|<owner>|<action>|<YYYY-MM-DD" "$FILE"; then
  missing=$((missing+1))
  echo "[go-no-go-validate] FAIL field=placeholders"
  echo "next: replace template placeholders with concrete values"
fi

if [[ "$missing" -gt 0 ]]; then
  echo "[go-no-go-validate] FAIL summary=${missing}_issue(s)"
  exit 1
fi

echo "[go-no-go-validate] PASS file=$FILE"