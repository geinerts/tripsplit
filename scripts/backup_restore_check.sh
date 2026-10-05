#!/usr/bin/env bash
set -euo pipefail
umask 077

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

source "$SCRIPT_DIR/ops_common.sh"

ENV_FILE="$(resolve_trip_env_file || true)"
if [[ -z "${ENV_FILE:-}" ]]; then
  echo "backup_restore_check: .env not found" >&2
  exit 1
fi

DB_NAME="$(env_value "$ENV_FILE" "TRIP_DB_NAME")"
DB_TABLE_PREFIX="$(env_value "$ENV_FILE" "TRIP_DB_TABLE_PREFIX")"
if [[ -z "$DB_TABLE_PREFIX" ]]; then DB_TABLE_PREFIX="trip_"; fi
[[ "$DB_NAME" =~ ^[A-Za-z0-9_]+$ && "$DB_TABLE_PREFIX" =~ ^[A-Za-z0-9_]+$ ]] || exit 1

BACKUP_ROOT="$(env_value "$ENV_FILE" "TRIP_BACKUP_ROOT_DIR")"
if [[ -z "$BACKUP_ROOT" ]]; then BACKUP_ROOT="/var/backups/splyto"; fi

ALERT_COOLDOWN_SEC="$(env_value "$ENV_FILE" "TRIP_BACKUP_RESTORE_ALERT_COOLDOWN_SEC")"
if [[ -z "$ALERT_COOLDOWN_SEC" ]]; then ALERT_COOLDOWN_SEC=21600; fi

DB_DIR="${BACKUP_ROOT}/db"
LATEST_DB_BACKUP="$(ls -1t "${DB_DIR}"/*.sql.gz 2>/dev/null | head -1 || true)"
if [[ -z "${LATEST_DB_BACKUP:-}" ]]; then
  echo "backup_restore_check: no DB backup found in ${DB_DIR}" >&2
  exit 1
fi

# Restore is an explicit local administrative operation, never a runtime/backup fallback.
if [[ "$(id -u)" -ne 0 ]]; then
  echo "backup_restore_check requires the local root socket administrator." >&2
  exit 1
fi
MYSQL_RESTORE_AUTH=(--no-defaults --protocol=SOCKET --socket=/var/run/mysqld/mysqld.sock -u root)
mysql "${MYSQL_RESTORE_AUTH[@]}" -e "SELECT 1;" >/dev/null

TS="$(date -u +%Y%m%d_%H%M%S)"
RESTORE_DB="${DB_NAME}_restore_smoke_${TS}"

cleanup() {
  mysql "${MYSQL_RESTORE_AUTH[@]}" -e "DROP DATABASE IF EXISTS \`${RESTORE_DB}\`;" >/dev/null 2>&1 || true
}

on_error() {
  local line="$1"
  local msg="[SPLYTO][BACKUP_RESTORE][FAIL] line=${line} backup=${LATEST_DB_BACKUP}"
  echo "$msg" >&2
  send_alert_with_cooldown "backup_restore_check" "$msg" "$ENV_FILE" "$ALERT_COOLDOWN_SEC"
}
trap 'cleanup' EXIT
trap 'on_error $LINENO' ERR

gzip -t "$LATEST_DB_BACKUP"
mysql "${MYSQL_RESTORE_AUTH[@]}" -e "CREATE DATABASE \`${RESTORE_DB}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
gunzip -c "$LATEST_DB_BACKUP" | mysql "${MYSQL_RESTORE_AUTH[@]}" "$RESTORE_DB"

TABLE_COUNT="$(mysql "${MYSQL_RESTORE_AUTH[@]}" -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${RESTORE_DB}' AND table_name LIKE '${DB_TABLE_PREFIX}%';")"
if [[ -z "$TABLE_COUNT" || "$TABLE_COUNT" -lt 5 ]]; then
  echo "backup_restore_check: restored table count too low (${TABLE_COUNT})" >&2
  exit 1
fi

cleanup

echo "[SPLYTO][BACKUP_RESTORE][OK] backup=${LATEST_DB_BACKUP} restore_db=${RESTORE_DB} table_count=${TABLE_COUNT}"
