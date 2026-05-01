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
ALERT_COOLDOWN_SEC="$(int_or_default "$ALERT_COOLDOWN_SEC" 3600)"

NONSEC_WARN="$(env_value "$ENV_FILE" "TRIP_SYSTEM_MONITOR_NONSEC_WARN")"
NONSEC_WARN="$(int_or_default "$NONSEC_WARN" 20)"

MAX_UPDATE_LINES="$(env_value "$ENV_FILE" "TRIP_SYSTEM_MONITOR_MAX_UPDATE_LINES")"
MAX_UPDATE_LINES="$(int_or_default "$MAX_UPDATE_LINES" 30)"

SERVICES_RAW="$(env_value "$ENV_FILE" "TRIP_SYSTEM_MONITOR_SERVICES")"

TOTAL_UPDATES=0
SECURITY_UPDATES=0
SECURITY_UPDATE_DETAILS=()
OTHER_UPDATE_DETAILS=()

format_update_line() {
  local line="$1"
  local package_name source_part version_part old_version

  package_name="${line%%/*}"
  source_part="${line#*/}"
  source_part="${source_part%% *}"
  version_part="$(awk '{print $2}' <<<"$line")"
  old_version="$(sed -n 's/.*\[upgradable from: \([^]]*\)\].*/\1/p' <<<"$line")"

  if [[ -n "$old_version" && -n "$version_part" ]]; then
    printf '%s (%s -> %s, %s)' "$package_name" "$old_version" "$version_part" "$source_part"
  elif [[ -n "$version_part" ]]; then
    printf '%s (%s, %s)' "$package_name" "$version_part" "$source_part"
  else
    printf '%s' "$package_name"
  fi
}

mapfile -t UPGRADABLE_LINES < <(apt list --upgradable 2>/dev/null | tail -n +2 | sed '/^\s*$/d' || true)
TOTAL_UPDATES="${#UPGRADABLE_LINES[@]}"
for line in "${UPGRADABLE_LINES[@]}"; do
  if [[ "$line" == *"-security"* ]]; then
    SECURITY_UPDATES=$((SECURITY_UPDATES + 1))
    SECURITY_UPDATE_DETAILS+=("$(format_update_line "$line")")
  else
    OTHER_UPDATE_DETAILS+=("$(format_update_line "$line")")
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
  MESSAGE="SPLYTO VPS ALERT
Host: ${HOSTNAME_SHORT}

Summary:
- Pending updates: ${TOTAL_UPDATES}
- Security updates: ${SECURITY_UPDATES}
- Reboot required: ${REBOOT_REQUIRED}"

  if [[ "${#UNHEALTHY_SERVICES[@]}" -gt 0 ]]; then
    MESSAGE="${MESSAGE}
- Services: ${UNHEALTHY_SERVICES[*]}"
  else
    MESSAGE="${MESSAGE}
- Services: OK"
  fi

  if [[ "${#SECURITY_UPDATE_DETAILS[@]}" -gt 0 ]]; then
    MESSAGE="${MESSAGE}

Security updates:"
    count=0
    for detail in "${SECURITY_UPDATE_DETAILS[@]}"; do
      count=$((count + 1))
      if (( count > MAX_UPDATE_LINES )); then
        MESSAGE="${MESSAGE}
- ... and $((${#SECURITY_UPDATE_DETAILS[@]} - MAX_UPDATE_LINES)) more"
        break
      fi
      MESSAGE="${MESSAGE}
- ${detail}"
    done
  fi

  if [[ "${#OTHER_UPDATE_DETAILS[@]}" -gt 0 ]]; then
    MESSAGE="${MESSAGE}

Other updates:"
    count=0
    for detail in "${OTHER_UPDATE_DETAILS[@]}"; do
      count=$((count + 1))
      if (( count > MAX_UPDATE_LINES )); then
        MESSAGE="${MESSAGE}
- ... and $((${#OTHER_UPDATE_DETAILS[@]} - MAX_UPDATE_LINES)) more"
        break
      fi
      MESSAGE="${MESSAGE}
- ${detail}"
    done
  fi

  if [[ "$REBOOT_REQUIRED" -eq 1 && -n "$REBOOT_REASON" ]]; then
    MESSAGE="${MESSAGE}

Reboot packages:
- ${REBOOT_REASON}"
  fi

  send_alert_with_cooldown "system_updates" "$MESSAGE" "$ENV_FILE" "$ALERT_COOLDOWN_SEC"
fi
