#!/usr/bin/env bash
set -euo pipefail

resolve_trip_env_file() {
  if [[ -n "${TRIP_ENV_FILE:-}" && -f "${TRIP_ENV_FILE}" ]]; then
    printf '%s\n' "${TRIP_ENV_FILE}"
    return 0
  fi
  if [[ -f ".env" ]]; then
    printf '%s\n' ".env"
    return 0
  fi
  if [[ -f "api/.env" ]]; then
    printf '%s\n' "api/.env"
    return 0
  fi
  return 1
}

env_value() {
  local env_file="$1"
  local key="$2"
  local value
  value="$(grep -E "^${key}=" "$env_file" | tail -1 | cut -d= -f2- || true)"
  printf '%s' "$value"
}

json_escape() {
  local input="$1"
  input="${input//\\/\\\\}"
  input="${input//\"/\\\"}"
  input="${input//$'\n'/\\n}"
  input="${input//$'\r'/\\r}"
  input="${input//$'\t'/\\t}"
  printf '%s' "$input"
}

send_alert_now() {
  local message="$1"
  local env_file="$2"
  local webhook_url
  local tg_token
  local tg_chat_id

  webhook_url="$(env_value "$env_file" "TRIP_ALERT_WEBHOOK_URL")"
  tg_token="$(env_value "$env_file" "TRIP_ALERT_TELEGRAM_BOT_TOKEN")"
  tg_chat_id="$(env_value "$env_file" "TRIP_ALERT_TELEGRAM_CHAT_ID")"

  if [[ -n "$webhook_url" ]]; then
    local escaped
    escaped="$(json_escape "$message")"
    curl -fsS --max-time 12 \
      -H "Content-Type: application/json" \
      -d "{\"text\":\"$escaped\",\"content\":\"$escaped\"}" \
      "$webhook_url" >/dev/null || true
  fi

  if [[ -n "$tg_token" && -n "$tg_chat_id" ]]; then
    curl -fsS --max-time 12 \
      -X POST \
      "https://api.telegram.org/bot${tg_token}/sendMessage" \
      --data-urlencode "chat_id=${tg_chat_id}" \
      --data-urlencode "text=${message}" >/dev/null || true
  fi
}

send_alert_with_cooldown() {
  local key="$1"
  local message="$2"
  local env_file="$3"
  local cooldown_seconds="${4:-900}"
  local state_file="/tmp/splyto_alert_${key}.stamp"
  local now epoch_last delta

  now="$(date +%s)"
  if [[ -f "$state_file" ]]; then
    epoch_last="$(cat "$state_file" 2>/dev/null || printf '0')"
    if [[ "$epoch_last" =~ ^[0-9]+$ ]]; then
      delta=$((now - epoch_last))
      if (( delta < cooldown_seconds )); then
        return 0
      fi
    fi
  fi

  printf '%s' "$now" > "$state_file"
  send_alert_now "$message" "$env_file"
}

