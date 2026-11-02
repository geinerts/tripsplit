# Group trip live map

Optional live sharing belongs to an **active group trip**, separate from the private
visited-city map. Opening the map does not request GPS. Each member confirms 15, 60,
240 or 480 minutes before the OS permission request. Accepted members can view shares
without sharing themselves. Pending invitations, friendships, other trips and solo trips
do not grant access. Group sharing is visible to every accepted member of that trip.

## API

All routes use authenticated `api.php?action=...` requests. List/start/update require
`X-Trip-Id`, active group membership and an active account. Bodies are ordinary bounded
JSON; all location fields and tokens are redacted from diagnostics.

- GET `list_trip_live_locations`: server epoch, members' latest fresh location, own expiry.
  No sharing tokens, routes or history; no response caching in the app.
- POST `start_trip_live_location`: `minutes`, `latitude`, `longitude`, `accuracy_m`,
  `observed_at` (UTC epoch seconds). Returns private random `session_token`, server expiry
  and server epoch. One row per account/trip; a new opt-in replaces the previous token.
- POST `update_trip_live_location`: fix fields plus `session_token`. Updates never extend
  the consent deadline. Older fixes cannot overwrite newer ones. Wrong, stopped and expired
  sessions return 409. Incoming fixes must be within 120 seconds of server time, allowing
  at most 60 seconds future clock skew. Coordinates are finite and range-checked.
- POST `stop_trip_live_location`: `trip_id`; idempotently removes only the caller's row,
  including after they have left or the trip has closed.

Start/update lock account, authenticated session, active trip and membership. Logout,
account revocation and finishing the trip remove shares. Membership deletion cascades
through a composite FK. Reads recheck both viewer/sharer memberships and active accounts.
The normal global API limiter plus 180 live requests/min/user and 20 starts/15 min/user
apply. Typical mobile polling/publication is once every 10 seconds, not WebSocket streaming.

## Retention and disconnects

Only the latest fix is stored. Points older than 120 seconds are never returned, even if
cleanup is late. The minute cleanup task clears stale coordinates and deletes expired
consents; list requests also clean them. A fix can therefore remain in the active DB up to
about three minutes after its observation, while map visibility ends after two minutes.
Access-restricted server backups retain their existing 14-day recovery window.

On-device consent tokens/fixes are memory-only, account-session scoped. Navigation away
keeps explicit sharing active; restarting the app never resumes GPS automatically. The
map can still stop an existing server consent. Stop cancels native updates immediately;
if offline, it retries removal while the app is running, and other clients discard the
last point after two minutes regardless. Background OS suspension, lost connectivity or
force-close can interrupt updates; this is not a safety/emergency tracking service.

## Native integration

- iOS: When In Use permission; `UIBackgroundModes=location`, foreground-started native
  continuous location updates with the visible iOS location indicator. No Always request.
- Android: coarse/fine location and location foreground-service permissions; geolocator's
  foreground notification remains visible. No automatic boot tracking or background
  permission request. The service is started while the consent screen is foregrounded.
- The controller sends on native fixes as well as a foreground timer so iOS wakeups
  respect expiry/throttling even when Dart timers have been suspended.
- Expiry is server-authoritative. App local deadlines use the server-reported remaining
  duration; expired native tracking stops on the next execution opportunity.

Before store release, update App Store Connect App Privacy and Google Play Data Safety
for optional **precise location linked to the user's account**, app functionality and
explicit sharing with trip members. These console declarations are not changed by code.
The bundled EN/LV/ES policies and website describe this separate feature.

## Basemap

Configured iOS/Android builds use the official `mapbox_maps_flutter` SDK and Mapbox
Standard, with day/night lighting following the app theme. Markers remain native map
annotations with profile photos/initials and a selected member's accuracy area. The
Mapbox location puck is disabled: GPS access, consent, expiry and server polling stay
in the existing Splyto live-location controller.

Pass a public `pk.` token via `MAPBOX_ACCESS_TOKEN` in an ignored
`mobile/config/env/*.local.json` and `--dart-define-from-file`. Never commit tokens.
Before a direct Xcode archive, run `flutter build ios --config-only --release` with
that same define file. No secret/download token is required by the current SDK.
Without configuration (and for offline widget tests), the existing flutter_map/OSM
renderer remains available. `LIVE_MAP_TILE_URL` applies only to that fallback.

Keep the native Mapbox logo and attribution control unobstructed: the control also
provides the SDK's telemetry opt-out. Participant identifiers/photos are not uploaded
to Mapbox; marker images/coordinates are supplied locally to the native renderer.
Map requests expose IP/network metadata and the viewed area, and SDK telemetry is
subject to Mapbox's privacy policy. Updated EN/LV/ES policies explain both providers.

Verified on iPhone 17 Pro simulator with a local public token (2026-10-28): actual
Mapbox Standard tile loading, live day/night theme changes, three demo markers,
multi-member camera fit, selected accuracy area, and no GPS prompt on map entry.
iOS annotation PNG decoding uses screen scale, so marker size compensates for
Retina density. Do not initialise the SDK location component even to disable it:
its default puck is already off; accessing it can initialise iOS location services.

Still verify photo avatars, marker taps/movement, attribution/telemetry menu and
network recovery on physical iOS and Android devices before release. Maps require
network access; sharing's existing stop/offline behaviour remains unchanged.

References:
- https://docs.mapbox.com/flutter/maps/guides/install/
- https://docs.mapbox.com/flutter/maps/guides/#telemetry-opt-out
- https://www.mapbox.com/legal/privacy
- https://operations.osmfoundation.org/policies/tiles/

## Deployment and verification

Apply `sql/migrations/2026-10-28-add-trip-live-locations.sql` using the operator migration
runner after a validated backup. Runtime account needs DML only. Fresh installs include the
same table in `sql/schema.sql`. Install the supplied systemd service/timer, enable the timer,
run the service once and verify its exit status. Missing schema returns explicit 409 instead
of exposing a partially working map. No existing trip/location data is migrated into live shares.

Tests: PHP real-handler fixture covers opt-in, IDOR, input, expiry, stop, token rotation,
stale erasure and membership cascade. Flutter tests cover consent/permission, navigation,
expiry, account switch, stop while offline, revocation and logout. These do not substitute
for two-phone GPS/background testing: check 15-minute expiry, locked screen/movement,
network loss/recovery, OS permission revocation, force-close, leaving and finishing a trip.
