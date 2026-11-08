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

## `admin_panel_user_delete`

Requires `reason`. Erases the account the same way as a confirmed self-service
deletion (`erase_account_for_deletion`): personal data, password, payment details,
avatar, friends, Apple/Google links (provider tokens are revoked), sessions and
push tokens are removed, and pending account links are consumed. Shared trip
history remains under "Deleted User". The audit entry keeps the nickname and
reason, not the email.

Errors: `400` missing `user_id` or `reason`, `404` unknown user, `409` already deleted.
