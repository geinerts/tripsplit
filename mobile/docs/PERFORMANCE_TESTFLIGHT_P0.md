# Splyto Performance P0 (Before TestFlight)

## Implemented in current build

1. API timeout guard
- All API requests now use a hard timeout (`TRIPSPLIT_API_TIMEOUT_SEC`, default `15s`).
- Prevents hanging requests from freezing UI flows.

2. API + screen timing instrumentation
- Added runtime perf traces:
  - `api.<method>.<action>`
  - `screen.trips.load`
  - `screen.friends.load`
  - `screen.workspace.load`
  - `screen.analytics.*`
- Enable logs with:
  - `--dart-define=TRIPSPLIT_PERF_LOGS=true`
  - or `--dart-define=TRIPSPLIT_VERBOSE_LOGS=true`

3. Cache-first loading (stale-while-revalidate)
- Trips and Friends now use in-memory cache for instant first paint.
- UI shows cached data immediately, then refreshes from backend in background.

4. Adaptive notification polling
- Polling interval now adapts by context:
  - Active (home/workspace/friends): ~20s
  - Analytics: ~35s
  - Other foreground screens: ~45s
  - Background: ~120s
- Reduces unnecessary network/battery usage.

5. Expense list render optimization
- Reworked expenses tab to a single lazy `ListView.separated`.
- Removed nested list + `shrinkWrap` pattern in this path.

6. Lighter global notification payload
- Global notifications limit reduced from `120` to `50`.

7. Backend pagination (cursor/offset) + UI incremental loading
- Added paged APIs for:
  - `list_expenses`
  - `friends_list` (section mode)
  - `list_notifications_global` (`paged=1`)
- UI now supports incremental list loading for large feeds.

8. Incremental workspace snapshot sync
- Added `workspace_snapshot` API with `since` cursor support.
- Mobile now requests delta checks first and falls back to legacy snapshot flow when needed.

## Pre-TestFlight command gate

Run:

```bash
./scripts/check_mobile_perf.sh
```

This runs:
- `flutter analyze`
- `flutter test`
- manual perf sanity checklist reminder

Before rollout, fill real-device baseline table:

```text
mobile/docs/PERFORMANCE_BASELINE_REAL_DEVICES.md
```

## Suggested target thresholds

- Cold start (release): <= 2.0s on recent test devices
- Home -> Workspace open: <= 1.2s p95
- API request p95 (core actions): <= 500ms on stable network
- Scrolling: no visible frame drops in Trips/Friends/Expenses under realistic data volume
