# Offline trips and expenses

Updated: 2026-11-09

## Supported

After signing in and opening a trip online, its last workspace snapshot (members,
expenses, balances and settlement state) is available to the same account offline.
The Home trip list is cached separately. The Expenses navigation action uses that
list without awaiting a server refresh, and the expense form opens as soon as a
cached workspace is read. A late refresh cannot replace a newly queued expense.

Transport state is read once and maintained from connectivity events. An explicit
lack of Wi-Fi/mobile transport fails API requests immediately into the existing
offline fallback. A connected network without internet may still require the
first request to time out; after that, subsequent actions fail fast into local
storage. Recovery is checked in the background (at most once every five seconds
while requests are attempted) using the existing unauthenticated `me` endpoint.
An expected JSON 401 indicates reachability, not a valid session. Normal API
authentication and permission checks still apply to subsequent real requests.
Transport changes also allow normal requests again. No user mutations are used
as recovery probes. Receipt uploads share the offline gate.

Expense additions, edits and deletions use the existing persistent mutation queue.
Reading a cached workspace overlays that queue in insertion order without changing
the confirmed server snapshot. This keeps pending rows visible after an app restart.
The existing client mutation ID is reused during replay. Balances and exchange-rate
conversion remain server-confirmed; pending rows are marked as queued.

Trip covers viewed on Home or inside a trip are saved to app-private disk storage:
8 MiB per download, 64 MiB per account, with oldest downloads evicted first. Copies
are separated by API environment and user ID. Signing out deletes them; late
requests cannot write back into a signed-out session. Previously installed builds
have no disk covers: open the trip online once after updating.

## Still requires internet

- Creating a new trip, changing membership, sharing invitations and settling.
- Uploading receipts/photos. Existing offline expense handling warns and saves
  without a receipt if its upload cannot complete; receipt bytes are not queued.
- Live location, new map tiles and uncached/paginated data.

Only previously loaded workspace data is available. Offline mode is not a full
mirror of all server records. Signing out clears pending mutations as before.

## Device verification

Use a non-production account and test trip:

1. Open Home and an active trip online; wait for the cover and expenses to load.
2. Enable airplane mode with Wi-Fi disabled. Reopen the app and the same trip.
3. Add an expense without a receipt. Check its queued state, then terminate and
   reopen the app; confirm the cover and pending expense remain.
4. Restore connectivity and refresh the trip. Check that the expense occurs once,
   its queued marker clears and the server-confirmed totals update.
5. Repeat with an edit/delete and a different split. Switch accounts and confirm
   the first account's cached trips, images and pending expenses are inaccessible.

Automated coverage: workspace codec/repository restart and replay tests, account
isolation tests, cover download/restart/logout/size tests, and offline form widget
coverage. These do not replace the iOS/Android airplane-mode check above.
