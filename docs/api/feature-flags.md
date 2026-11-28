# Feature flags

Approved by the owner on 2026-11-20. Server-side switches for features that are rolled out
step by step. Flags: `receipt_ai` (AI receipt reading, see
`docs/mobile/quick-split-ai-plan.md`) and `year_summary` (the year in travel card, added
2026-11-28, see [trip-reports.md](trip-reports.md)). The app only uses the flag to decide what to show;
the server checks it again on every request of the feature, before any cost.

## Model

Each flag has a global **mode**:

| Mode | Meaning |
| --- | --- |
| `off` | Emergency stop and default. Nobody gets the feature, granted accounts included. |
| `allowlist` | Only accounts with a grant (test phase). |
| `everyone` | Every active, non-guest account (public launch, no new app version needed). |

A **grant** turns the feature on for one account while the mode is `allowlist`. Grants stay
stored when the mode changes, so switching `off` → `allowlist` restores the same testers.
Flag keys come from a fixed list in the code (`feature_flag_catalog()`); there are no free-form
flags. Deleted, deactivated and guest accounts never get a feature.

Missing tables or a failed read count as "off" (fail closed).

## App API

`me` (and every response that carries the `me` payload) gains one field:

```json
"features": { "receipt_ai": false, "year_summary": false }
```

`year_summary` is also limited to its season (January–March): outside it the value is
`false`, except for accounts with a grant, so testers can check it at any time.

All catalog keys are always present as booleans. Older apps ignore the field. The value may be
up to 60 seconds old; the feature's own request re-checks the flag without caching, so `off`
takes effect immediately there.

## Admin API (admin host only, verified 2FA session)

| Action | Role | Request | Response |
| --- | --- | --- | --- |
| `admin_panel_features` (GET) | superadmin, admin | – | `flags: [{key, label, description, mode, updated_at, updated_by}]`, `grants: [{key, user_id, nickname, email, account_status, granted_at, granted_by}]` |
| `admin_panel_feature_set_mode` (POST) | superadmin | `{key, mode, reason}` | `{ok, flag}` |
| `admin_panel_user_feature_set` (POST) | superadmin | `{user_id, key, enabled, reason}` | `{ok, enabled}` |

`reason` is required (1–200 characters) for every change. Unknown keys, modes or users answer
400/404; granting to a deleted or guest account answers 409. Every change writes an admin audit
entry (`feature.mode_set`, `feature.user_grant`, `feature.user_revoke`) in the same transaction;
if the audit entry cannot be written, nothing changes.

`admin_panel_user_detail` gains `features: [{key, label, granted, effective}]` for that user.

## Storage

Migration `sql/migrations/2026-11-20-feature-flags.sql` adds two tables and changes no existing
data:

- `trip_feature_flags (flag_key PK, mode, updated_at, updated_by_admin_id)`
- `trip_user_features (user_id, flag_key, granted_at, granted_by_admin_id)`, primary key
  `(user_id, flag_key)`, deleted with the user.

`receipt_ai` and `year_summary` start as `off` with no grants (a flag without a row is
`off`, so no migration is needed for a new key).

## Removing a flag

When a feature has run for everyone and is stable, remove its key from the catalog and the
checks from the code, then delete its rows. Do not keep finished flags around.
