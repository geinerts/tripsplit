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
HEALTH_CHECK_ATTEMPTS="$(int_or_default "$(env_value "$ENV_FILE" "TRIP_HEALTH_CHECK_ATTEMPTS")" 3)"
HEALTH_CHECK_RETRY_DELAY_SEC="$(int_or_default "$(env_value "$ENV_FILE" "TRIP_HEALTH_CHECK_RETRY_DELAY_SEC")" 2)"
if (( HEALTH_CHECK_ATTEMPTS < 1 )); then
  HEALTH_CHECK_ATTEMPTS=1
fi

log_line() {
  printf '[%s] %s\n' "$(date -Is)" "$*"
}

check_status_once() {
  local url="$1"
  local expected="$2"
  local got
  local curl_error
  local curl_status
  local error_file

  error_file="$(mktemp)"
  got="$(curl -sS --connect-timeout 5 --max-time 15 -o /dev/null -w '%{http_code}' "$url" 2>"$error_file")"
  curl_status=$?
  curl_error="$(tr '\n' ' ' < "$error_file" | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//')"
  rm -f "$error_file"

  if (( curl_status != 0 )); then
    if [[ -z "$got" ]]; then
      got="000"
    fi
    echo "FAIL $url expected=$expected got=$got curl_exit=$curl_status error=${curl_error:-curl failed}"
    return 1
  fi

  if [[ "$got" != "$expected" ]]; then
    echo "FAIL $url expected=$expected got=$got"
    return 1
  fi
  echo "OK   $url status=$got"
}

check_status() {
  local url="$1"
  local expected="$2"
  local attempt
  local out
  local last_out

  for (( attempt = 1; attempt <= HEALTH_CHECK_ATTEMPTS; attempt++ )); do
    if out="$(check_status_once "$url" "$expected")"; then
      if (( attempt > 1 )); then
        echo "$out recovered_after_attempt=$attempt"
      else
        echo "$out"
      fi
      return 0
    fi

    last_out="$out"
    if (( attempt < HEALTH_CHECK_ATTEMPTS )); then
      sleep "$HEALTH_CHECK_RETRY_DELAY_SEC"
    fi
  done

  echo "$last_out attempts=$HEALTH_CHECK_ATTEMPTS"
  return 1
}

HOSTNAME_SHORT="$(hostname -s 2>/dev/null || hostname)"
failures=()
if ! out="$(check_status "$BASE_URL/api/api.php?action=unknown" "404")"; then
  failures+=("$out")
else
  log_line "$out"
fi
if ! out="$(check_status "$BASE_URL/api/api.php?action=me" "401")"; then
  failures+=("$out")
else
  log_line "$out"
fi

if (( ${#failures[@]} > 0 )); then
  msg="SPLYTO API ALERT
Host: ${HOSTNAME_SHORT}

Summary:
- Status: FAIL
- Base URL: ${BASE_URL}
- Failed checks: ${#failures[@]}

Checks:"
  for failure in "${failures[@]}"; do
    msg="${msg}
- ${failure}"
  done
  log_line "$msg" >&2
  mark_alert_unhealthy "health_api"
  send_alert_with_cooldown "health_api" "$msg" "$ENV_FILE" "$ALERT_COOLDOWN_SEC"
  if [[ -n "$HC_PING_FAIL_URL" ]]; then
    curl -fsS --max-time 10 "$HC_PING_FAIL_URL" >/dev/null || true
  fi
  exit 2
fi

if [[ -n "$HC_PING_URL" ]]; then
  curl -fsS --max-time 10 "$HC_PING_URL" >/dev/null || true
fi
send_recovery_alert_if_needed "health_api" "SPLYTO API RECOVERED
Host: ${HOSTNAME_SHORT}

Summary:
- Status: OK
- Base URL: ${BASE_URL}
- Checks passed: 2" "$ENV_FILE"
log_line "[SPLYTO][HEALTH][OK] ${BASE_URL}"
