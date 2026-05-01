#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

source "$SCRIPT_DIR/ops_common.sh"

ENV_FILE="$(resolve_trip_env_file || true)"
if [[ -z "${ENV_FILE:-}" ]]; then
  echo "send_daily_ops_digest: .env not found" >&2
  exit 1
fi

BASE_URL="$(env_value "$ENV_FILE" "TRIP_PUBLIC_BASE_URL")"
BASE_URL="${BASE_URL:-https://splyto.eu}"
BASE_URL="${BASE_URL%/}"

DB_NAME="$(env_value "$ENV_FILE" "TRIP_DB_NAME")"
DB_USER="$(env_value "$ENV_FILE" "TRIP_DB_USER")"
DB_PASS="$(env_value "$ENV_FILE" "TRIP_DB_PASS")"
DB_HOST="$(env_value "$ENV_FILE" "TRIP_DB_HOST")"
DB_HOST="${DB_HOST:-localhost}"

BACKUP_ROOT="$(env_value "$ENV_FILE" "TRIP_BACKUP_ROOT_DIR")"
BACKUP_ROOT="${BACKUP_ROOT:-/var/backups/splyto}"

PENDING_WARN="$(env_value "$ENV_FILE" "TRIP_PUSH_MONITOR_PENDING_WARN")"
FAILED_WARN="$(env_value "$ENV_FILE" "TRIP_PUSH_MONITOR_FAILED_WARN")"
STALE_WARN_MIN="$(env_value "$ENV_FILE" "TRIP_PUSH_MONITOR_STALE_MIN")"
FAILED_WINDOW_MIN="$(env_value "$ENV_FILE" "TRIP_PUSH_MONITOR_FAILED_WINDOW_MIN")"
PENDING_WARN="$(int_or_default "$PENDING_WARN" 20)"
FAILED_WARN="$(int_or_default "$FAILED_WARN" 5)"
STALE_WARN_MIN="$(int_or_default "$STALE_WARN_MIN" 10)"
FAILED_WINDOW_MIN="$(int_or_default "$FAILED_WINDOW_MIN" 30)"

HOSTNAME_SHORT="$(hostname -s 2>/dev/null || hostname)"
GENERATED_AT="$(date -u +%F' '%T' UTC')"

check_status_code() {
  local url="$1"
  curl -sS --max-time 12 -o /dev/null -w '%{http_code}' "$url" || printf '000'
}

describe_file_age() {
  local path="$1"
  local now mtime age size name

  if [[ -z "$path" || ! -f "$path" ]]; then
    printf 'missing'
    return 0
  fi

  now="$(date +%s)"
  mtime="$(stat -c %Y "$path" 2>/dev/null || printf '0')"
  if ! [[ "$mtime" =~ ^[0-9]+$ ]]; then
    mtime=0
  fi

  age=$((now - mtime))
  size="$(du -h "$path" 2>/dev/null | awk '{print $1}')"
  name="$(basename "$path")"
  printf '%s, %s ago (%s)' "${size:-unknown size}" "$(format_duration "$age")" "$name"
}

api_unknown_status="$(check_status_code "$BASE_URL/api/api.php?action=unknown")"
api_me_status="$(check_status_code "$BASE_URL/api/api.php?action=me")"
api_summary="OK"
if [[ "$api_unknown_status" != "404" || "$api_me_status" != "401" ]]; then
  api_summary="FAIL"
fi

push_summary="unavailable"
push_status="unknown"
if [[ -n "$DB_NAME" && -n "$DB_USER" ]]; then
  MYSQL_AUTH=(-h"$DB_HOST" -u"$DB_USER")
  if [[ -n "$DB_PASS" ]]; then
    MYSQL_AUTH+=(-p"$DB_PASS")
  fi

  push_query="$(mysql "${MYSQL_AUTH[@]}" -N -B "$DB_NAME" -e "
SELECT
  SUM(status='pending') AS pending_count,
  SUM(status='failed' AND updated_at >= UTC_TIMESTAMP() - INTERVAL ${FAILED_WINDOW_MIN} MINUTE) AS failed_recent_count,
  COALESCE(MAX(CASE WHEN status='pending' THEN TIMESTAMPDIFF(MINUTE, created_at, UTC_TIMESTAMP()) ELSE NULL END), 0) AS oldest_pending_min
FROM trip_push_queue;
" 2>/dev/null || true)"

  if [[ -n "$push_query" ]]; then
    read -r pending_count failed_recent_count oldest_pending_min <<<"$push_query"
    pending_count="$(int_or_default "$pending_count" 0)"
    failed_recent_count="$(int_or_default "$failed_recent_count" 0)"
    oldest_pending_min="$(int_or_default "$oldest_pending_min" 0)"
    push_status="OK"
    if (( pending_count >= PENDING_WARN || failed_recent_count >= FAILED_WARN || oldest_pending_min >= STALE_WARN_MIN )); then
      push_status="WARN"
    fi
    push_summary="${push_status} (pending=${pending_count}, failed_${FAILED_WINDOW_MIN}m=${failed_recent_count}, oldest=${oldest_pending_min}m)"
  fi
fi

mapfile -t UPGRADABLE_LINES < <(apt list --upgradable 2>/dev/null | tail -n +2 | sed '/^\s*$/d' || true)
total_updates="${#UPGRADABLE_LINES[@]}"
security_updates=0
for line in "${UPGRADABLE_LINES[@]}"; do
  if [[ "$line" == *"-security"* ]]; then
    security_updates=$((security_updates + 1))
  fi
done

reboot_required="no"
reboot_reason=""
if [[ -f /var/run/reboot-required ]]; then
  reboot_required="yes"
  if [[ -f /var/run/reboot-required.pkgs ]]; then
    reboot_reason="$(tr '\n' ',' < /var/run/reboot-required.pkgs | sed 's/,$//')"
  fi
fi

SERVICES_RAW="$(env_value "$ENV_FILE" "TRIP_SYSTEM_MONITOR_SERVICES")"
SERVICES=()
if [[ -n "$SERVICES_RAW" ]]; then
  IFS=',' read -r -a SERVICES <<<"$SERVICES_RAW"
else
  SERVICES=(nginx mysql)
  PHP_FPM_UNIT="$(systemctl list-unit-files "php*-fpm.service" --no-legend 2>/dev/null | awk 'NR==1 {print $1}')"
  if [[ -n "${PHP_FPM_UNIT:-}" ]]; then
    SERVICES+=("$PHP_FPM_UNIT")
  fi
fi

UNHEALTHY_SERVICES=()
for svc in "${SERVICES[@]}"; do
  svc="$(echo "$svc" | xargs)"
  [[ -z "$svc" ]] && continue
  if ! systemctl is-active --quiet "$svc"; then
    state="$(systemctl is-active "$svc" 2>/dev/null || echo "unknown")"
    UNHEALTHY_SERVICES+=("${svc}=${state}")
  fi
done

services_summary="OK"
if [[ "${#UNHEALTHY_SERVICES[@]}" -gt 0 ]]; then
  services_summary="${UNHEALTHY_SERVICES[*]}"
fi

latest_db_backup="$(ls -1t "${BACKUP_ROOT}/db"/*.sql.gz 2>/dev/null | head -1 || true)"
latest_app_backup="$(ls -1t "${BACKUP_ROOT}/app_state"/*.tar.gz 2>/dev/null | head -1 || true)"
latest_backup_status="$(tail -n 1 /var/log/splyto_backup.log 2>/dev/null || true)"
latest_restore_status="$(tail -n 1 /var/log/splyto_backup_restore_check.log 2>/dev/null || true)"
latest_maintenance_status="$(tail -n 1 /var/log/splyto_weekly_maintenance.log 2>/dev/null || true)"

disk_summary="$(df -h / 2>/dev/null | awk 'NR==2 {print $5 " used, " $4 " free"}')"
load_summary="$(cut -d' ' -f1-3 /proc/loadavg 2>/dev/null || true)"

MESSAGE="SPLYTO DAILY OPS
Host: ${HOSTNAME_SHORT}
Generated: ${GENERATED_AT}

Health:
- API: ${api_summary} (unknown=${api_unknown_status}, me=${api_me_status})
- Push queue: ${push_summary}
- Services: ${services_summary}

System:
- Pending updates: ${total_updates}
- Security updates: ${security_updates}
- Reboot required: ${reboot_required}
- Disk /: ${disk_summary:-unknown}
- Load avg: ${load_summary:-unknown}

Backups:
- DB: $(describe_file_age "$latest_db_backup")
- App state: $(describe_file_age "$latest_app_backup")"

if [[ -n "$reboot_reason" ]]; then
  MESSAGE="${MESSAGE}
- Reboot packages: ${reboot_reason}"
fi

if [[ -n "$latest_backup_status" || -n "$latest_restore_status" || -n "$latest_maintenance_status" ]]; then
  MESSAGE="${MESSAGE}

Recent jobs:"
  if [[ -n "$latest_backup_status" ]]; then
    MESSAGE="${MESSAGE}
- Backup: ${latest_backup_status}"
  fi
  if [[ -n "$latest_restore_status" ]]; then
    MESSAGE="${MESSAGE}
- Restore check: ${latest_restore_status}"
  fi
  if [[ -n "$latest_maintenance_status" ]]; then
    MESSAGE="${MESSAGE}
- Weekly maintenance: ${latest_maintenance_status}"
  fi
fi

send_alert_now "$MESSAGE" "$ENV_FILE"
echo "[SPLYTO][DAILY_DIGEST][OK] sent"
