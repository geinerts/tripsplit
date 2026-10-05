#!/usr/bin/env bash
set -euo pipefail
umask 077

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
[[ "$DB_NAME" =~ ^[A-Za-z0-9_]+$ ]] || { echo "Invalid database name" >&2; exit 1; }

BACKUP_ROOT="$(env_value "$ENV_FILE" "TRIP_BACKUP_ROOT_DIR")"
RETENTION_DAYS="$(env_value "$ENV_FILE" "TRIP_BACKUP_RETENTION_DAYS")"
ALERT_COOLDOWN_SEC="$(env_value "$ENV_FILE" "TRIP_BACKUP_ALERT_COOLDOWN_SEC")"

if [[ -z "$BACKUP_ROOT" ]]; then BACKUP_ROOT="/var/backups/splyto"; fi
if [[ -z "$RETENTION_DAYS" ]]; then RETENTION_DAYS=14; fi
if [[ -z "$ALERT_COOLDOWN_SEC" ]]; then ALERT_COOLDOWN_SEC=3600; fi

TIMESTAMP="$(date -u +%Y%m%d_%H%M%S)"
DB_DIR="${BACKUP_ROOT}/db"
APP_DIR="${BACKUP_ROOT}/app_state"
META_DIR="${BACKUP_ROOT}/meta"

install -d -m 700 "$BACKUP_ROOT" "$DB_DIR" "$APP_DIR" "$META_DIR"

DB_FILE="${DB_DIR}/${DB_NAME}_${TIMESTAMP}.sql.gz"
APP_FILE="${APP_DIR}/splyto_app_${TIMESTAMP}.tar.gz"
META_FILE="${META_DIR}/backup_${TIMESTAMP}.sha256"

on_error() {
  local line="$1"
  local msg="[SPLYTO][BACKUP][FAIL] line=${line} ts=${TIMESTAMP}"
  echo "$msg" >&2
  send_alert_with_cooldown "backup_vps" "$msg" "$ENV_FILE" "$ALERT_COOLDOWN_SEC"
}
trap 'on_error $LINENO' ERR

php "$SCRIPT_DIR/backup_database.php" | gzip -c > "${DB_FILE}.partial"
mv "${DB_FILE}.partial" "$DB_FILE"

include_paths=()
for p in ".env" "api/.env" "uploads" "keys"; do
  if [[ -e "$p" ]]; then
    include_paths+=("$p")
  fi
done

if (( ${#include_paths[@]} == 0 )); then
  echo "No app state paths found to archive (expected one of .env, api/.env, uploads, keys)." >&2
  exit 1
fi

tar -czf "$APP_FILE" "${include_paths[@]}"

{
  sha256sum "$DB_FILE"
  sha256sum "$APP_FILE"
} > "$META_FILE"

find "$DB_DIR" -type f -name "*.sql.gz" -mtime +"$RETENTION_DAYS" -delete
find "$APP_DIR" -type f -name "*.tar.gz" -mtime +"$RETENTION_DAYS" -delete
find "$META_DIR" -type f -name "*.sha256" -mtime +"$RETENTION_DAYS" -delete

echo "[SPLYTO][BACKUP][OK] db=${DB_FILE} app=${APP_FILE} retention_days=${RETENTION_DAYS}"
