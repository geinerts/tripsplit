# Claude Security scan plan

Written 2026-11-20. The owner decided that everything below is to be scanned with the
Claude Security plugin (`/claude-security`).

## Already done

- 2026-11-18 scan of `api/` at revision `426b909` (medium effort), results in
  `CLAUDE-SECURITY-20261118-095002/`. All 9 findings are fixed: F1–F5, F14, F15 and F17
  in `8cb6df3`, F16 in `bb2766b`.
- Not covered by that scan: everything outside `api/`, and Quick split authorization (the
  report says the Quick split handlers were not audited).

## Still to scan, in priority order

1. **New server code since `426b909`** (diff scan of `api/` from `426b909`, 24 files):
   - AI receipt reading: `api/lib/actions/receipt_scan_actions.php`,
     `api/lib/helpers/helper_receipt_ai.php` (paid API, budget, uploaded images). Check first.
   - Feature flags and their admin page: `feature_flags_actions.php`, `helper_feature_flags.php`,
     `admin_panel_actions.php`.
   - Fail-closed limits: `api/config/config_auth_logging_rate.php`, `api/lib/bootstrap.php`.
   - F16 and registration: `auth_actions.php`, `auth_social_actions.php`,
     `email_verification_actions.php`, `account_lifecycle_actions.php`,
     `helper_account_lifecycle.php`, `helper_auth_user.php`, `helper_email.php`.
   - Friends after removing user search: `api/lib/actions/friends/*`.
2. **Quick split authorization**: `api/lib/actions/quick_splits_actions.php`, with
   `api/lib/http/action_router.php`. Already deployed, so this is urgent.
3. **Admin panel front end**: `admin2/index.html`, `admin2/app.js` and `admin2/js/` (XSS from user-entered
   names and notes, admin session handling). Never scanned.
4. **Public PHP pages outside `api/`**: `friend.php`, `invite.php`, `share-image.php`
   (no sign-in, they handle links and images). Never scanned.
5. **Flutter app** `mobile/lib/`: session token storage, deep links (invite and friend links),
   account-scoped cache isolation, what goes to logs and crash reports, receipt images.
   Never scanned.
6. **Server configuration and scripts**: `ops/` (nginx, systemd), `scripts/` (backups,
   migrations, `admin_totp.php`), `site/js/`, `html/.well-known/`. Lower risk.

## Suggested runs

| Run | Covers | Scope | Effort |
| --- | --- | --- | --- |
| 1 | Items 1 and 2 | `api/` | medium |
| 2 | Items 3 and 4 | `admin2/`, `friend.php`, `invite.php`, `share-image.php` | medium |
| 3 | Item 5 | `mobile/lib/` (can wait until 1.1.0 is submitted) | medium |
| 4 | Item 6 | `ops/`, `scripts/`, `site/js/`, `html/` | low, when needed |

Results go next to the earlier ones (`CLAUDE-SECURITY-<date>/`). Fixes follow the same rule
as before: proposed first, approved by the owner, then committed and deployed.
