# Administrator 2FA

Implemented locally 2026-11-12. Closes F05 from the [2026-10-04 audit](audit-2026-10-04.md)
and makes 2FA mandatory for every admin account. Not deployed by this change.

## Policy

- Every admin account must use TOTP. A password-only session is never fully
  authenticated: all admin actions except enrolment answer
  `403 2fa_enrollment_required` (`api/lib/helpers/helper_admin_auth.php`, `admin_session_denial`).
- Login always creates an unverified session. The response says
  `requires_2fa` (enrolled) or `requires_2fa_enrollment` (not enrolled yet).
- A verified code is accepted once. `totp_last_counter` refuses a code (or an older
  one) that was already used, including the enrolment confirmation code.
- 2FA cannot be turned off in the panel. The `admin_panel_disable_totp` action is removed.

## Lifecycle (`api/lib/helpers/helper_admin_totp.php`)

| Step | Requirement | Effect |
| --- | --- | --- |
| Enrol (no 2FA yet) | Login session + password | New secret stored as **pending** only |
| Replace (2FA on) | Verified session + password + current code | New secret stored as pending; old one keeps working |
| Confirm | Code from the pending secret, within 10 minutes | Pending becomes active, every other session of this admin is deleted, this session is verified, audit `admin.totp.enable` / `admin.totp.replace` |
| Lost authenticator | Superadmin edits another admin ("Reset 2FA"), or operator CLI | 2FA removed, all sessions of that admin deleted; next login must enrol |

A superadmin changing another admin's password or deactivating them also signs
that admin out everywhere. Setup and confirm are rate limited per IP and per admin.

Known limits: enrolment for an account that has no 2FA yet is protected by the
password only, so enrol right after deploy. No email is sent when 2FA changes
(the audit log records it). Sessions are not rotated to a new cookie on verification.

## Encryption key rotation

Secrets are AES-256-GCM encrypted with `TRIP_ADMIN_TOTP_ENCRYPTION_KEY`. During
rotation `TRIP_ADMIN_TOTP_ENCRYPTION_KEY_PREVIOUS` holds the old key; it is only
used for reading. No admin has to re-enrol.

1. `sudo php scripts/admin_totp.php status`
2. Generate a key (`openssl rand -hex 48`). In the server env file set
   `TRIP_ADMIN_TOTP_ENCRYPTION_KEY_PREVIOUS` to the old value and
   `TRIP_ADMIN_TOTP_ENCRYPTION_KEY` to the new one. Reload PHP-FPM.
3. `sudo php scripts/admin_totp.php rotate-key` (dry run). If it reports an
   unreadable secret, stop: nothing was changed.
4. `sudo php scripts/admin_totp.php rotate-key --apply`
5. Remove `TRIP_ADMIN_TOTP_ENCRYPTION_KEY_PREVIOUS`, reload PHP-FPM, log in with 2FA.
6. Delete old env copies that contain the old key.

Recovery without the panel: `sudo php scripts/admin_totp.php reset --username=NAME --apply`.

## Rollout

1. Back up the database.
2. Apply `sql/migrations/2026-11-12-admin-totp-lifecycle.sql` **before** the code
   (the new code reads the new columns; without them admin login 2FA fails).
3. Deploy the backend and `admin2/` (asset versions bumped to `app.css?v=14`, `app.js?v=17`).
4. Log in at the admin host. Without 2FA the panel asks you to enrol at once.
5. Rotate the key as above.

## Verification

- `api/tests/Unit/AdminTotpLifecycleTest.php`: 11 tests on SQLite for enrolment,
  replacement, expiry, replay, reset, key rotation and the removed disable route.
  Row locking (`FOR UPDATE`) is not exercised on SQLite.
- `admin2/tests/admin-mfa.test.cjs`: mocked-API browser test of enrolment and
  replacement at 1280 px and 390 px.
