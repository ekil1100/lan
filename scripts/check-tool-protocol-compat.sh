#!/usr/bin/env bash
set -euo pipefail

# Offline compatibility checker for tool response protocol v1
# Format: ok=<bool>;code=<...>;detail=<...>;next=<...>;meta=<...>

samples=(
  "read|ok=true;code=read_ok;detail=hello;next=-;meta=tool=read_file"
  "write|ok=true;code=write_ok;detail=wrote file: /tmp/a;next=-;meta=tool=write_file"
  "list|ok=true;code=list_ok;detail=sample.txt;next=-;meta=tool=list_dir"
  "exec|ok=true;code=exec_ok;detail=lan_exec_ok;next=-;meta=tool=exec"
  "exec_fail|ok=false;code=process_nonzero_exit;detail=command failed with exit code 2;next=check command and retry;meta=-"
)

fail=0

audit_line() {
  local name="$1"
  local line="$2"

  local parsed
  parsed="$(printf '%s' "$line" | awk -F';' '
    BEGIN { ok=""; code=""; detail=""; nextv=""; meta="" }
    {
      for (i=1; i<=NF; i++) {
        split($i, kv, "=")
        key=kv[1]
        val=substr($i, length(key)+2)
        if (key=="ok") ok=val
        else if (key=="code") code=val
        else if (key=="detail") detail=val
        else if (key=="next") nextv=val
        else if (key=="meta") meta=val
      }
    }
    END {
      printf("ok=%s\ncode=%s\ndetail=%s\nnext=%s\nmeta=%s\n", ok, code, detail, nextv, meta)
    }
  ')"

  local ok code detail next meta
  ok="$(printf '%s\n' "$parsed" | sed -n 's/^ok=//p')"
  code="$(printf '%s\n' "$parsed" | sed -n 's/^code=//p')"
  detail="$(printf '%s\n' "$parsed" | sed -n 's/^detail=//p')"
  next="$(printf '%s\n' "$parsed" | sed -n 's/^next=//p')"
  meta="$(printf '%s\n' "$parsed" | sed -n 's/^meta=//p')"

  local missing=""
  [[ -n "$ok" ]] || missing="${missing}ok,"
  [[ -n "$code" ]] || missing="${missing}code,"
  [[ -n "$detail" ]] || missing="${missing}detail,"
  [[ -n "$next" ]] || missing="${missing}next,"
  [[ -n "$meta" ]] || missing="${missing}meta,"

  if [[ -n "$missing" ]]; then
    missing="${missing%,}"
    echo "[tool-protocol-compat] FAIL case=${name} reason=missing_fields fields=${missing}"
    fail=1
    return
  fi

  # compatibility constraints
  # 1) ok=true => next must be '-'
  if [[ "$ok" == "true" && "$next" != "-" ]]; then
    echo "[tool-protocol-compat] FAIL case=${name} reason=incompatible_next_for_success expected=- actual=${next}"
    fail=1
    return
  fi

  # 2) ok=false => code cannot end with _ok and next cannot be '-'
  if [[ "$ok" == "false" ]]; then
    if [[ "$code" == *_ok ]]; then
      echo "[tool-protocol-compat] FAIL case=${name} reason=incompatible_code_for_failure code=${code}"
      fail=1
      return
    fi
    if [[ "$next" == "-" ]]; then
      echo "[tool-protocol-compat] FAIL case=${name} reason=missing_next_for_failure fields=next"
      fail=1
      return
    fi
  fi

  echo "[tool-protocol-compat] PASS case=${name}"
}

for item in "${samples[@]}"; do
  name="${item%%|*}"
  line="${item#*|}"
  audit_line "$name" "$line"
done

if [[ "$fail" -ne 0 ]]; then
  exit 1
fi

echo "[tool-protocol-compat] PASS reason=all-cases-compatible"
