#!/usr/bin/env bash
set -euo pipefail

# Check provider endpoint reachability and latency.
# Usage: ./scripts/check-provider-health.sh [endpoint] [timeout_s]
#   endpoint: provider API base URL (default: from LAN_PROVIDER_URL or https://api.openai.com)
#   timeout_s: connection timeout in seconds (default: 5)

ENDPOINT="${1:-${LAN_PROVIDER_URL:-https://api.openai.com}}"
TIMEOUT="${2:-5}"

# Strip trailing slash, ensure /v1/models endpoint
base="${ENDPOINT%/}"
health_url="$base/v1/models"

echo "[provider-health] endpoint=$base timeout=${TIMEOUT}s"

get_ms() { python3 -c 'import time; print(int(time.time()*1000))'; }
start_ms="$(get_ms)"

http_code="$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout "$TIMEOUT" --max-time "$((TIMEOUT*2))" "$health_url" 2>/dev/null || true)"
http_code="${http_code:0:3}"
[[ -z "$http_code" || "$http_code" == "000" ]] && http_code="000"

end_ms="$(get_ms)"
latency_ms=$((end_ms - start_ms))

echo "{\"endpoint\":\"$base\",\"http_code\":\"$http_code\",\"latency_ms\":$latency_ms}"

if [[ "$http_code" == "000" ]]; then
  echo "[provider-health] FAIL reason=unreachable endpoint=$base latency=${latency_ms}ms"
  echo "next: check network connectivity and provider URL"
  exit 1
elif [[ "$http_code" =~ ^[45] ]]; then
  # 401/403 means reachable but auth needed — that's fine for health check
  if [[ "$http_code" == "401" || "$http_code" == "403" ]]; then
    echo "[provider-health] PASS endpoint=$base http=$http_code latency=${latency_ms}ms note=auth_required_but_reachable"
    exit 0
  fi
  echo "[provider-health] FAIL reason=http_error endpoint=$base http=$http_code latency=${latency_ms}ms"
  echo "next: verify provider URL and API key configuration"
  exit 1
fi

echo "[provider-health] PASS endpoint=$base http=$http_code latency=${latency_ms}ms"