# Admin panel: users

Admin-only actions on `ops.splyto.eu`, used by `admin2/`. Not part of the mobile API.

## `admin_panel_user_search` and `admin_panel_user_detail`

Each user object has these fields in addition to `id`, `nickname`, `email`,
`account_status` and `created_at`:

| Field | Type | Meaning |
| --- | --- | --- |
| `sign_in_methods` | string[] | `email` when a password is set, plus each linked provider (`apple`, `google`). Empty for an account that cannot sign in (for example a deleted one). |
| `platforms` | string[] | Distinct push token platforms (`ios`, `android`, `web`), active or not. Empty when the app never registered for push. |
| `email_verified` | bool or null | Whether `email_verified_at` is set; `null` when the column is unavailable. |

The password hash is never selected; only a computed boolean is read.
With an empty `q`, the search lists the newest accounts first.

`admin_panel_user_search` also returns, per user:

| Field | Type | Meaning |
| --- | --- | --- |
| `trips_count` | int | Trips the user is a member of. |
| `last_active_at` | string or null | Latest `refresh_tokens.last_used_at`, including sessions revoked since; `null` when never used. |
| `premium_grant` | bool | An active admin Premium grant (not launch Premium). |

and `premium_for_everyone` (bool) for the whole response. Optional query parameters:
`sort` (`newest` default, `oldest`, `last_active`, `trips`), `platform` (`ios`, `android`),
`sign_in` (`email`, `apple`, `google`), `premium=1`, `unverified=1` (email set but not verified).
`q` matches nickname or email; `%` and `_` are literal. Guests are never listed.

`admin_panel_user_detail` also returns `sessions` (active app sessions: `id`,
`created_at`, `last_used_at`, `user_agent` up to 120 characters; no token hashes or IPs),
`timeline` (the latest 25 app events: `event_type`, `entity_type`, `entity_id`,
`trip_id`, `trip_name`, `created_at`) and `members_count` for each trip.

## `admin_panel_user_sign_out_everywhere`

POST `{user_id}`, support roles. Revokes every refresh session of the user
(`revoke_refresh_tokens_for_user`), which also ends their access tokens. The account
stays active. Audit `user.sessions.revoke_all` with the number of sessions. Returns `revoked`.

## Dashboard, System and Security

- `admin_panel_dashboard` adds `stats.growth`: 30 daily rows (`date`, `signups`
  excluding guests, `active` = distinct users with an app event, `trips`).
- `admin_panel_system_health` (superadmin, admin, ops): `jobs` from heartbeat files,
  `system` (disk, database size, PHP/MySQL versions, deployed commit) and `push`
  (pending, oldest pending, failed in 24 h, last sent). See
  [job heartbeats](../../scripts/README.md#job-heartbeats).
- `admin_panel_security_overview` (superadmin, admin): admin sign-in, 2FA and session
  events from the audit log for 7 days, `counts_7d`, `rate_limits_24h` per scope
  (peak hits in one window, requests, windows; subjects stay hashed) and the number
  of active admin sessions. Failed app (non-admin) logins are not recorded today.

## `admin_panel_user_delete`

Requires `reason`. Erases the account the same way as a confirmed self-service
deletion (`erase_account_for_deletion`): personal data, password, payment details,
avatar, friends, Apple/Google links (provider tokens are revoked), sessions and
push tokens are removed, and pending account links are consumed. Shared trip
history remains under "Deleted User". The audit entry keeps the nickname and
reason, not the email.

Errors: `400` missing `user_id` or `reason`, `404` unknown user, `409` already deleted.
