#!/bin/sh
# Xcode archives must not silently ship the Natural Earth/OSM fallback.
# Generated.xcconfig can lose app defines after unrelated Flutter commands.
set -eu
case "${CONFIGURATION:-}" in
  *Release*|*Profile*)
    if ! printf '%s' "${DART_DEFINES:-}" | tr ',' '\n' | while IFS= read -r value || [ -n "$value" ]; do
      printf '%s' "$value" | /usr/bin/base64 -D 2>/dev/null || true
      printf '\n'
    done | /usr/bin/grep -q '^MAPBOX_ACCESS_TOKEN=pk\..'; then
      echo 'error: Mapbox configuration is missing. From mobile/, run: flutter build ios --config-only --release --dart-define-from-file=config/env/testflight.local.json' >&2
      exit 1
    fi
    ;;
esac
exec /bin/sh "$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh" build
