# Offline account isolation

Implemented: 2026-09-23

## Boundaries

- Trips, workspace snapshots, notification inboxes and mutation queues use account-specific keys, additionally separated by API base URL.
- One shared `AccountDataSession` tracks account ID and login generation. Async repository operations keep the identity they started with, including across awaited network failures. Logout invalidates that generation immediately.
- Nested storage and replay operations inherit the original account lease. They cannot silently capture the next signed-in account after an `await`.
- `LegacyApiClient` checks that lease after asynchronous credential loading and before HTTP dispatch. Requests already dispatched can finish on the server under their original credentials, but their late results cannot populate another account's cache or start further queued requests.
- In-memory trip/friend caches are generation-checked. Account transitions also clear cached application state.
- Secure session storage now writes both tokens, their expiries and the API-confirmed account ID as one record. Offline profile restoration requires the cached profile ID to match that secure record. No API response, token or personal data is logged by this mechanism.

## Queue consistency

- New queued mutations carry the owner ID in addition to their account-specific key.
- Storage changes and logout cleanup are serialized through the shared store.
- Concurrent enqueues cannot overwrite each other. Concurrent flushes within one session share the same work.
- Successful replay removes only the processed item, preserving items queued during the network call.
- Network failures, HTTP 401 and server errors retain the queue for retry. Account changes stop replay. Existing mutation IDs are retained for backend idempotency.
- Payment retry IDs are separated by account and session generation; they are not reused across accounts.

## Upgrade behavior

Old global cache keys have no reliable owner and are never adopted into the currently signed-in account. Snapshots, trip lists and notification caches are removed and refreshed from the API.

Legacy queued mutations are preserved under `unassigned_workspace_queue_v1` (with a timestamp suffix if necessary). They are **not read or replayed by the application**. These recovery copies remain on the device across logout; review ownership before manually recovering or deleting them. No server data is deleted by this migration.

Legacy session keys remain usable for online authentication until a successful login/refresh creates the new secure record. They cannot establish an offline account identity. After upgrading, the user may need connectivity and a fresh login/refresh before offline restoration becomes available. A mismatched or damaged session/profile cannot open another account's offline workspace.

Signing out still discards that installation's normal caches and pending queues, as before. Signing in drains any previous refresh/revocation work first; a late sign-in result cannot reactivate an account after logout.

## Verification

- Flutter suite: 44 tests passed (17 new tests, plus expanded auth lifecycle assertions).
- Covered: same-trip-ID isolation, same-account restart, API environment separation, expired generation rejection, late success/error responses, enqueue after account change, queue replay interrupted by account change, concurrent enqueue/flush, secure owner restoration, malformed session records, interrupted login and credential-loading races.
- iOS simulator Debug build passed. This is not a TestFlight upload or a two-device production exercise.

## Limits

This change isolates accounts at the application boundary. It does not encrypt all SharedPreferences cache data or protect a rooted/jailbroken device against filesystem extraction. Tokens and their account binding use the existing Keychain/Keystore-backed secure-storage configuration; caches and legacy quarantine copies remain in the app-private preferences store. Encrypted offline databases and a recovery UI are separate work.

No server deployment or database migration is required. Existing TestFlight installations receive these protections only after a new app build is distributed.
