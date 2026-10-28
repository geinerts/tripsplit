# Private travel map

Profile → My travel map shows a bundled Natural Earth overview with visited
countries highlighted and one check marker per city. Markers have a 24-pixel
visual inside a 48-pixel touch target. Bundled country labels appear at overview
zoom levels; major city labels appear when zoomed in (starting at zoom 4.3).
Labels avoid one another and visit markers, without external tile requests. Selecting a marker opens a
small card with city, country/region and latest visit date. There is no persistent
list below the map. Repeated dates in the same city are separate visits; the card
pages between visits and allows editing or removing the displayed visit after confirmation.
Optional personal photos and titles appear inside the card, with an Open trip
action when the linked trip is still accessible.

## Adding visits

- Add place: explicit native city search, select result, choose date, Save visit.
- I've been here: request foreground location permission on tap, obtain one
  position, reverse-geocode to a city, resolve its centre, then show the same
  confirmation. Cancelling never saves. Permission refusal leaves manual search
  available. No background updates, location stream or group/live sharing.
- The API receives only the confirmed city centre, not the device's measured
  position. City search/reverse-geocoding uses the device platform's geocoder;
  the map geometry itself makes no tile/network requests. Search terms may go
  to the platform provider. No external map API keys are required.
- This first version is an overview of cities, not a street/navigation map.
  Native search/location target iOS and Android. Native provider availability,
  connectivity and rate limits can affect lookups; errors keep the form open.

## Deployment

Run `sql/migrations/2026-10-26-add-travel-places.sql` on the intended database
followed by `sql/migrations/2026-10-26-link-travel-places-to-trips.sql`
before exposing the feature, then deploy the PHP handlers/router/bootstrap and
account-deletion integrations. Prefix in this migration is `trip_`, matching
production. Apply the standard deployment backup/check process. Nothing in the
mobile UI creates or migrates a server table.

Ship a new mobile build with the updated dependencies and permission text.
`Podfile` sets `BYPASS_PERMISSION_LOCATION_ALWAYS=1` for geolocator_apple;
Info.plist requests only When In Use. Android requests coarse location only.
Before release, review the store privacy/data-safety disclosure for optional
account-linked city/approximate-location data. This implementation does not
publish store metadata or upload a build.

## API and security

Authenticated legacy actions (no trip-id header needed):

- GET `list_travel_places`: `{ok:true, places:[...]}`; owner-only, newest first.
- POST `save_travel_place`: city, region, country, uppercase country_code,
  numeric latitude/longitude and `visited_on` (ISO date). Server assigns owner
  and ID. Optional `id` edits an owned visit; `trip_id` links an accepted membership.
  Optional `title`, `photo_base64`, `remove_photo` update personal details.
  Deduplicates country/region/city/date/source (manual or trip ID). Retries of
  an existing visit return it without overwriting its title or photo. At most 1,000 visits/account.
- GET `travel_place_photo`: owned `id`; returns base64 WebP or null with
  no-store headers. Missing/foreign IDs return 404. Lists omit photo bytes.
- POST `delete_travel_place`: integer `id`. Foreign/missing IDs return 404.

Writes are rate-limited. Save locks the active user's row to serialize with
account deletion and the visit limit. Deletion removes personal map rows;
hard deletion also cascades by foreign key. Routine backup retention still
applies. Missing schema returns 409 `travel_map_unavailable`; it never silently
saves only on the device. Client cache is account-scoped, session-guarded and
cleared with sign-out. Cached reads are allowed on network failure only, not
after an authorization error. There is no offline write queue for visits.

## Verification

- PHP isolated real-handler test: owner isolation, spoofed owner ignored,
  validation, duplicate visits, deletion, deleted account, size limit and
  missing migration. No production data involved.
- Flutter tests: cache isolation/session changes, confirmation before save,
  manual search, denied permission, popup/deletion and small-screen translations.
- `TRAVEL_MAP_PREVIEWS=true` writes actual Flutter dark/light previews with
  synthetic visits to `output/design/travel-map`.
- Native simulator compilation checks plugin integration. Before release,
  test real iPhone/Android permission prompts, city lookup, date selection,
  cancel/save/reopen, offline viewing and deleting a visit against a migrated
  test backend. Simulator compilation alone does not verify real GPS/geocoding.

## Trip destinations and personal photos

Create/edit trip accepts optional `destinations` (up to 20 validated city objects).
These planned destinations are shared with members. Trip creation, invitation
acceptance and trip completion never create a personal visit automatically.
Profile map → From a trip and trip menu → Add to my map require confirmation
of a city and visit date. Completion offers the same optional action.

Saving from a trip copies its name and available cover thumbnail. Each member
has a separate private visit and may replace the photo from their gallery.
The snapshot survives source-cover changes, leaving or deletion of a trip;
leaving removes the Open trip link, not the person's existing private memory.

Gallery photos are compressed client-side before upload. The authenticated
`save_travel_place` action permits a 704 KiB JSON body for base64 image data and
metadata; other actions retain the default 64 KiB limit. The JSON reader checks
both declared and actual body length and reads at most the limit plus one byte. Server validation
accepts bounded JPG/PNG/WebP input (512 KiB, 12 megapixels), re-encodes to WebP
(maximum 768-pixel edge, 256 KiB) and strips metadata. Private bytes live in the
visit row, never a public uploads URL. Saves are limited to 60/15 minutes and
photo uploads to 15/15 minutes. Photo cache keys are account- and version-scoped.
Deleting a visit/account deletes its photo from the active database; standard
backup retention still applies. Logout clears local account storage.

Tests also cover accepted membership, unauthorized trip imports, private photo
access, cover-copy independence, image validation, repeat imports, membership
revocation, photo versioning, explicit confirmation and repeated-city paging.
