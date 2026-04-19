#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/ops_common.sh"
cd "$SCRIPT_DIR/.."

ENV_FILE="$(resolve_trip_env_file || true)"
if [[ -z "${ENV_FILE:-}" ]]; then
  echo "monitor_system_updates: .env not found" >&2
  exit 1
fi

ALERT_COOLDOWN_SEC="$(env_value "$ENV_FILE" "TRIP_SYSTEM_MONITOR_ALERT_COOLDOWN_SEC")"
ALERT_COOLDOWN_SEC="${ALERT_COOLDOWN_SEC:-3600}"

NONSEC_WARN="$(env_value "$ENV_FILE" "TRIP_SYSTEM_MONITOR_NONSEC_WARN")"
NONSEC_WARN="${NONSEC_WARN:-20}"

SERVICES_RAW="$(env_value "$ENV_FILE" "TRIP_SYSTEM_MONITOR_SERVICES")"

TOTAL_UPDATES=0
SECURITY_UPDATES=0
mapfile -t UPGRADABLE_LINES < <(apt list --upgradable 2>/dev/null | tail -n +2 | sed '/^\s*$/d' || true)
TOTAL_UPDATES="${#UPGRADABLE_LINES[@]}"
for line in "${UPGRADABLE_LINES[@]}"; do
  if [[ "$line" == *"-security"* ]]; then
    SECURITY_UPDATES=$((SECURITY_UPDATES + 1))
  fi
done

REBOOT_REQUIRED=0
REBOOT_REASON=""
if [[ -f /var/run/reboot-required ]]; then
  REBOOT_REQUIRED=1
  if [[ -f /var/run/reboot-required.pkgs ]]; then
    REBOOT_REASON="$(tr '\n' ',' < /var/run/reboot-required.pkgs | sed 's/,$//')"
  fi
fi

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

SUMMARY="system_updates total=${TOTAL_UPDATES} security=${SECURITY_UPDATES} reboot_required=${REBOOT_REQUIRED}"
if [[ "${#UNHEALTHY_SERVICES[@]}" -gt 0 ]]; then
  SUMMARY="${SUMMARY} unhealthy_services=${UNHEALTHY_SERVICES[*]}"
else
  SUMMARY="${SUMMARY} unhealthy_services=none"
fi
echo "$SUMMARY"

ISSUES=()
if (( SECURITY_UPDATES > 0 )); then
  ISSUES+=("security_updates=${SECURITY_UPDATES}")
fi
if (( REBOOT_REQUIRED == 1 )); then
  if [[ -n "$REBOOT_REASON" ]]; then
    ISSUES+=("reboot_required pkgs=${REBOOT_REASON}")
  else
    ISSUES+=("reboot_required")
  fi
fi
if [[ "${#UNHEALTHY_SERVICES[@]}" -gt 0 ]]; then
  ISSUES+=("services_down=${UNHEALTHY_SERVICES[*]}")
fi

if (( TOTAL_UPDATES >= NONSEC_WARN )); then
  ISSUES+=("high_pending_updates=${TOTAL_UPDATES}")
fi

if [[ "${#ISSUES[@]}" -gt 0 ]]; then
  HOSTNAME_SHORT="$(hostname -s 2>/dev/null || hostname)"
  MESSAGE="SPLYTO VPS ALERT: ${HOSTNAME_SHORT}
${SUMMARY}
$(printf '%s\n' "${ISSUES[@]}")"
  send_alert_with_cooldown "system_updates" "$MESSAGE" "$ENV_FILE" "$ALERT_COOLDOWN_SEC"
fi
