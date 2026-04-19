#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

source "$SCRIPT_DIR/ops_common.sh"

ENV_FILE="$(resolve_trip_env_file || true)"
if [[ -z "$ENV_FILE" ]]; then
  echo "Could not find .env or api/.env" >&2
  exit 1
fi

BASE_URL="$(env_value "$ENV_FILE" "TRIP_PUBLIC_BASE_URL")"
if [[ -z "$BASE_URL" ]]; then
  BASE_URL="https://splyto.eu"
fi
BASE_URL="${BASE_URL%/}"

HC_PING_URL="$(env_value "$ENV_FILE" "TRIP_HEALTHCHECK_PING_URL")"
HC_PING_FAIL_URL="$(env_value "$ENV_FILE" "TRIP_HEALTHCHECK_PING_FAIL_URL")"
ALERT_COOLDOWN_SEC="$(env_value "$ENV_FILE" "TRIP_HEALTH_ALERT_COOLDOWN_SEC")"
if [[ -z "$ALERT_COOLDOWN_SEC" ]]; then
  ALERT_COOLDOWN_SEC=900
fi

check_status() {
  local url="$1"
  local expected="$2"
  local got
  got="$(curl -sS --max-time 12 -o /dev/null -w '%{http_code}' "$url" || printf '000')"
  if [[ "$got" != "$expected" ]]; then
    echo "FAIL $url expected=$expected got=$got"
    return 1
  fi
  echo "OK   $url status=$got"
}

failures=()
if ! out="$(check_status "$BASE_URL/api/api.php?action=unknown" "404")"; then
  failures+=("$out")
else
  echo "$out"
fi
if ! out="$(check_status "$BASE_URL/api/api.php?action=me" "401")"; then
  failures+=("$out")
else
  echo "$out"
fi

if (( ${#failures[@]} > 0 )); then
  msg="[SPLYTO][HEALTH][FAIL] ${BASE_URL} :: ${failures[*]}"
  echo "$msg" >&2
  send_alert_with_cooldown "health_api" "$msg" "$ENV_FILE" "$ALERT_COOLDOWN_SEC"
  if [[ -n "$HC_PING_FAIL_URL" ]]; then
    curl -fsS --max-time 10 "$HC_PING_FAIL_URL" >/dev/null || true
  fi
  exit 2
fi

if [[ -n "$HC_PING_URL" ]]; then
  curl -fsS --max-time 10 "$HC_PING_URL" >/dev/null || true
fi
echo "[SPLYTO][HEALTH][OK] ${BASE_URL}"

