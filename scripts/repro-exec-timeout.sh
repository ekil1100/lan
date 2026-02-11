#!/usr/bin/env bash
set -euo pipefail

# Reproduces the same timeout policy used by toolExec (10s default).
WRAP='sh -c "$1" & pid=$!; (sleep 10; kill -TERM $pid 2>/dev/null) & killer=$!; wait $pid; status=$?; kill $killer 2>/dev/null; wait $killer 2>/dev/null; if [ $status -eq 143 ] || [ $status -eq 137 ]; then exit 124; fi; exit $status'

set +e
sh -c "$WRAP" sh 'sleep 11'
CODE=$?
set -e

if [[ "$CODE" -ne 124 ]]; then
  echo "[exec-timeout] FAIL: expected 124, got $CODE"
  exit 1
fi

echo "[exec-timeout] PASS"
