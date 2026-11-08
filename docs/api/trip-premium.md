# Trip Premium

Status: approved by the owner on 2026-11-08. Needs the migration below before the server is
deployed. There is no purchase yet: an administrator grants it for testing.

A one-off Premium for a single trip. It covers every current member of that trip, including
people who join later. Someone who leaves loses it. It has no end date and can be revoked.
Deleting the trip deletes it. It unlocks only features that belong to a trip. Account-wide
features, such as the year summary, still need the person's own Premium.

## Feature list

Each feature in `premium_feature_catalog()` has a `scope`:

| Feature | Tier | Scope |
| --- | --- | --- |
| `trip_export` | premium | trip |
| `year_summary` | premium | account |

A trip feature is allowed when the account's own Premium allows it (including Premium for
everyone), or the trip has an active trip Premium. `premium_access.features` keeps meaning
"allowed by the account itself, in every trip".

## Trips list

Each row of `trips` gains `premium_features`, an object with one boolean per trip feature:

```json
{"id": 10, "name": "Rome", "premium_features": {"trip_export": true}}
```

It is the final answer for the requesting account in that trip. If the trip Premium table is
missing, only the account's own Premium counts. Older apps ignore the field. Apps fall back to
`premium_access.features` when it is absent, for example in offline caches, which don't store it.

## Detailed export

`trip_export` uses the same rule for the trip in `X-Trip-Id`. Otherwise it still returns 403
`premium_required`. Other request and response fields don't change.

## Administration

`admin_panel_premium_mutate` gains two operations, with the same superadmin, verified 2FA,
CSRF, `request_id` and `reason` rules as the existing ones:

- `trip_grant_create`: `trip_id` and `source` (`testing` or `compensation`). A trip can hold
  only one active trip Premium; a second one returns an error.
- `trip_grant_revoke`: `trip_grant_id` and `version`.

Each is recorded in `premium_events` with `user_id` null, `grant_id` set to the trip grant,
and `trip_id` in `before_json`/`after_json`, and in the standard admin audit log.

`admin_panel_user_detail.premium.trip_grants` lists the active trip Premium of the user's
trips: `id`, `trip_id`, `source`, `reason`, `version` and `created_at`. Like account grants,
only admins and superadmins receive it; support gets an empty list. The user detail's trip list shows them, with grant and
revoke buttons for those allowed to manage Premium.

## Migration

`sql/migrations/2026-11-08-add-trip-premium.sql` adds `trip_premium_trip_grants`. Without it
the server behaves as before, and trip grant operations return an error.

## Later

Purchases will add their own `source` to this table through the purchase flow. Nothing in
the app buys a trip Premium yet.
