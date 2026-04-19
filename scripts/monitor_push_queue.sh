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

DB_NAME="$(env_value "$ENV_FILE" "TRIP_DB_NAME")"
DB_USER="$(env_value "$ENV_FILE" "TRIP_DB_USER")"
DB_PASS="$(env_value "$ENV_FILE" "TRIP_DB_PASS")"
DB_HOST="$(env_value "$ENV_FILE" "TRIP_DB_HOST")"
if [[ -z "$DB_HOST" ]]; then
  DB_HOST="localhost"
fi

PENDING_WARN="$(env_value "$ENV_FILE" "TRIP_PUSH_MONITOR_PENDING_WARN")"
FAILED_WARN="$(env_value "$ENV_FILE" "TRIP_PUSH_MONITOR_FAILED_WARN")"
STALE_WARN_MIN="$(env_value "$ENV_FILE" "TRIP_PUSH_MONITOR_STALE_MIN")"
FAILED_WINDOW_MIN="$(env_value "$ENV_FILE" "TRIP_PUSH_MONITOR_FAILED_WINDOW_MIN")"
ALERT_COOLDOWN_SEC="$(env_value "$ENV_FILE" "TRIP_PUSH_MONITOR_ALERT_COOLDOWN_SEC")"

if [[ -z "$PENDING_WARN" ]]; then PENDING_WARN=20; fi
if [[ -z "$FAILED_WARN" ]]; then FAILED_WARN=5; fi
if [[ -z "$STALE_WARN_MIN" ]]; then STALE_WARN_MIN=10; fi
if [[ -z "$FAILED_WINDOW_MIN" ]]; then FAILED_WINDOW_MIN=30; fi
if [[ -z "$ALERT_COOLDOWN_SEC" ]]; then ALERT_COOLDOWN_SEC=900; fi

MYSQL_AUTH=(-h"$DB_HOST" -u"$DB_USER")
if [[ -n "$DB_PASS" ]]; then
  MYSQL_AUTH+=(-p"$DB_PASS")
fi

read -r pending_count failed_recent_count oldest_pending_min <<<"$(mysql "${MYSQL_AUTH[@]}" -N -B "$DB_NAME" -e "
SELECT
  SUM(status='pending') AS pending_count,
  SUM(status='failed' AND updated_at >= UTC_TIMESTAMP() - INTERVAL ${FAILED_WINDOW_MIN} MINUTE) AS failed_recent_count,
  COALESCE(MAX(CASE WHEN status='pending' THEN TIMESTAMPDIFF(MINUTE, created_at, UTC_TIMESTAMP()) ELSE NULL END), 0) AS oldest_pending_min
FROM trip_push_queue;
")"

pending_count="${pending_count:-0}"
failed_recent_count="${failed_recent_count:-0}"
oldest_pending_min="${oldest_pending_min:-0}"

echo "[SPLYTO][PUSH_QUEUE] pending=${pending_count} failed_recent_${FAILED_WINDOW_MIN}m=${failed_recent_count} oldest_pending_min=${oldest_pending_min}"

problems=()
if (( pending_count >= PENDING_WARN )); then
  problems+=("pending=${pending_count}>=${PENDING_WARN}")
fi
if (( failed_recent_count >= FAILED_WARN )); then
  problems+=("failed_recent_${FAILED_WINDOW_MIN}m=${failed_recent_count}>=${FAILED_WARN}")
fi
if (( oldest_pending_min >= STALE_WARN_MIN )); then
  problems+=("oldest_pending_min=${oldest_pending_min}>=${STALE_WARN_MIN}")
fi

if (( ${#problems[@]} > 0 )); then
  msg="[SPLYTO][PUSH_QUEUE][WARN] ${problems[*]}"
  echo "$msg" >&2
  send_alert_with_cooldown "push_queue" "$msg" "$ENV_FILE" "$ALERT_COOLDOWN_SEC"
  exit 2
fi

exit 0

