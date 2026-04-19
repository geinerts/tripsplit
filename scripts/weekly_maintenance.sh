#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

source "$SCRIPT_DIR/ops_common.sh"

ENV_FILE="$(resolve_trip_env_file || true)"
if [[ -z "${ENV_FILE:-}" ]]; then
  echo "weekly_maintenance: .env not found" >&2
  exit 1
fi

ALERT_COOLDOWN_SEC="$(env_value "$ENV_FILE" "TRIP_WEEKLY_MAINTENANCE_ALERT_COOLDOWN_SEC")"
if [[ -z "$ALERT_COOLDOWN_SEC" ]]; then ALERT_COOLDOWN_SEC=3600; fi

MODE="${1:-apply}"
if [[ "$MODE" != "apply" && "$MODE" != "--dry-run" ]]; then
  echo "Usage: scripts/weekly_maintenance.sh [apply|--dry-run]" >&2
  exit 1
fi

on_error() {
  local line="$1"
  local msg="[SPLYTO][MAINTENANCE][FAIL] line=${line}"
  echo "$msg" >&2
  send_alert_with_cooldown "weekly_maintenance_fail" "$msg" "$ENV_FILE" "$ALERT_COOLDOWN_SEC"
}
trap 'on_error $LINENO' ERR

echo "[SPLYTO][MAINTENANCE] mode=${MODE} started_at=$(date -u +%F_%T)"

if [[ "$MODE" == "--dry-run" ]]; then
  apt-get update -y
  apt-get -s upgrade | sed -n '1,120p'
  apt-get -s autoremove --purge | sed -n '1,120p'
  echo "[SPLYTO][MAINTENANCE][DRY_RUN_OK]"
  exit 0
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get -y upgrade
apt-get -y autoremove --purge
apt-get -y autoclean

UPGRADABLE_LEFT="$(apt list --upgradable 2>/dev/null | sed -n '2,$p' | sed '/^\s*$/d' | wc -l | tr -d ' ')"

SUMMARY="[SPLYTO][MAINTENANCE][OK] upgradable_left=${UPGRADABLE_LEFT}"
if [[ -f /var/run/reboot-required ]]; then
  SUMMARY="${SUMMARY} reboot_required=1"
  send_alert_with_cooldown "weekly_maintenance_reboot" "${SUMMARY}" "$ENV_FILE" "$ALERT_COOLDOWN_SEC"
else
  SUMMARY="${SUMMARY} reboot_required=0"
fi

echo "$SUMMARY"
