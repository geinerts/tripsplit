#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  scripts/vps_run_migrations.sh [apply|dry-run|baseline] [--limit=N]

Environment variables:
  VPS_HOST      required (example: 204.168.239.179)
  VPS_USER      optional, default: root
  VPS_PORT      optional, default: 22
  VPS_APP_DIR   optional, default: /var/www/splyto

Examples:
  VPS_HOST=204.168.239.179 VPS_USER=root scripts/vps_run_migrations.sh dry-run
  VPS_HOST=204.168.239.179 VPS_USER=root scripts/vps_run_migrations.sh baseline
  VPS_HOST=204.168.239.179 VPS_USER=root scripts/vps_run_migrations.sh apply --limit=1
EOF
}

MODE="${1:-apply}"
LIMIT_FLAG="${2:-}"

if [[ "$MODE" == "--help" || "$MODE" == "-h" ]]; then
  usage
  exit 0
fi

case "$MODE" in
  apply|dry-run|baseline) ;;
  *)
    echo "Unknown mode: $MODE" >&2
    usage
    exit 1
    ;;
esac

if [[ -n "$LIMIT_FLAG" && "$LIMIT_FLAG" != --limit=* ]]; then
  echo "Invalid second argument. Use --limit=N" >&2
  usage
  exit 1
fi

if [[ "${VPS_HOST:-}" == "" ]]; then
  echo "Missing VPS_HOST environment variable." >&2
  usage
  exit 1
fi

VPS_USER="${VPS_USER:-root}"
VPS_PORT="${VPS_PORT:-22}"
VPS_APP_DIR="${VPS_APP_DIR:-/var/www/splyto}"

echo "Running migrations on $VPS_USER@$VPS_HOST:$VPS_APP_DIR (mode=$MODE)..."

ssh \
  -o StrictHostKeyChecking=accept-new \
  -p "$VPS_PORT" \
  "$VPS_USER@$VPS_HOST" \
  "APP_DIR=$(printf '%q' "$VPS_APP_DIR") MODE=$(printf '%q' "$MODE") LIMIT_FLAG=$(printf '%q' "$LIMIT_FLAG") bash -s" <<'EOF'
set -euo pipefail
cd "$APP_DIR"

CMD=(php scripts/run_migrations.php)

if [[ "$MODE" == "dry-run" ]]; then
  CMD+=(--dry-run)
elif [[ "$MODE" == "baseline" ]]; then
  CMD+=(--baseline)
fi

if [[ -n "$LIMIT_FLAG" ]]; then
  CMD+=("$LIMIT_FLAG")
fi

echo "Command: ${CMD[*]}"
"${CMD[@]}"
EOF
