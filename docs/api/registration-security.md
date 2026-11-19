# Registration identity boundary (SEC-01 / F04)

Status: locally verified, 2026-10-04. Not deployed. This closes only the registration
device-ID reuse path; it does not complete SEC-01 or the wider authentication audit.

## Contract

- `register_proof` still returns a short-lived proof bound to a device identifier.
  A proof authorizes an attempt to create a new account, not access to an existing one.
- `register` inserts a new user. It never updates a user on email/device-token collision.
- **Email already in use (changed 2026-11-19, F16):** when the request carries credentials and
  the email belongs to any existing account, nothing is created or changed and the answer is
  exactly the verification-required response a new account gets (HTTP 200,
  `code: EMAIL_VERIFICATION_REQUIRED`, the submitted `verification_email`). The account owner
  instead gets a notice email ("someone tried to create an account with your email; sign in or
  reset your password"), at most once per address per 24 hours. So a sign-up no longer reveals
  whether an email is registered. Apps already show the "check your email" screen for this
  response; no app change is needed.
- **Device ID collision:** HTTP 409, `ok: false`, `code: REGISTRATION_CONFLICT` and a message
  directing the user to sign in or recover their account. No `me`/`auth` payload is returned.
  The device ID is chosen by the client, so this reveals nothing about other people.
- In both cases no session, registration event or verification mail is issued for an existing
  account, and existing rows stay unchanged. A valid proof replay does not bypass this rule.
- Ordinary successful creation and verification-required response contracts remain
  unchanged. Session issuance resolves the new insert ID, not the client device token.
- Infrastructure errors outside integrity-constraint violations propagate as errors;
  they are not disguised as successful registration.

## Compatibility and rollout prerequisites

No migration is added: `sql/schema.sql` already defines unique device-token and email
indexes. Confirm those indexes on the target database before rollout. Their uniqueness
is the concurrency boundary; a separate SELECT-before-INSERT would not suffice.

Existing clients must sign in/recover rather than replay registration to regain access.
In particular, retrying after an uncertain network response with the same device ID can
return 409; with the same email it gets the verification-required response again. Never automatically fall back to device-ID authentication.
Test the verification resend/login UI and same-device new-account journey before release.
Authenticated guest credential enrollment is a separate flow; registration is not an upgrade.

This patch intentionally does not modify `set_credentials`, profile password updates,
email changes, password recovery, social linking or session revocation policy. F01 remains
open in this historical slice. The `@example.test` shortcut (F11 / S-03) was removed
locally on 2026-10-26; see [the follow-up and deployment status](../security/trip-media-registration-fixes.md).

## Verification and limits

Run from `api`: `php vendor/bin/phpunit --filter RegistrationSecurityTest`.

The CLI-only fixture loads the real registration/proof handlers and validation helpers
with an in-memory SQLite database by default, or explicitly guarded isolated MySQL.
Configuration capability checks, request transport,
rate limiting, session issuance, mail and events are replaced by controlled test adapters.
It never loads `.env`, production bootstrap or production data. MySQL mode connects only
to the marked disposable Docker database; mail/session services remain local adapters.
Tests assert responses, unchanged existing rows, unique constraints and side-effect counts.
Both name-column and legacy-schema branches are covered.

Local result: 19 tests / 231 assertions; full PHP suite 147 tests / 706 assertions
on PHP 8.5.4. Docker was initially unavailable; that prerequisite is now resolved.

Additional verification on 2026-10-04: PHP 8.3.35 / MySQL 8.4.11 passed the same 19 tests
and 20 concurrent registration races (six workers each, 120 requests). At most one account
was inserted, rejected attempts caused no auth/mail/event calls, and existing identities
remained unchanged. See [repeatable Docker tests](../../ops/testing/README.md).

Before marking release-verified: verify exact production DB-version/schema parity and
full HTTP signup/login/verification behavior, including lost-response retries, logout and
revocation followed by registration replay. The concurrency tests exercise native InnoDB
constraints, not every schedule or service failure; token/mail/transport adapters are
still stubbed. Production deployment and mobile distribution remain separate authorized steps.

## Unverified accounts

Email/password accounts cannot sign in until the email is verified (`EMAIL_NOT_VERIFIED`).
The link is valid for `TRIP_EMAIL_VERIFICATION_TOKEN_TTL_SEC` (24 h); a new one can be
requested from the sign-in screen. `scripts/run_email_verification_cleanup.php` (cron,
every 10 minutes) deactivates accounts still unverified after
`TRIP_EMAIL_VERIFICATION_GRACE_DAYS` (7) and erases them after
`TRIP_EMAIL_VERIFICATION_ERASE_DAYS` (30, always later than the grace period) when they
were never used: no refresh session, trip membership, friend or Apple/Google link.
Erasure is the same as a self-service deletion (`erase_account_for_deletion`): personal
data is removed and the email address becomes free for a new sign-up. Each account is
rechecked under a row lock, so a verification or sign-in in the meantime keeps it.
Verifying an automatically deactivated (not yet erased) account reactivates it only
when the internal `email_verification_can_reactivate` permission is set. Automatic
cleanup grants this permission atomically with deactivation; administrator suspension
revokes it, including when the account was already automatically deactivated.
Confirmation checks the locked account row. Administrative/unknown suspensions return
the existing HTTP 403 account-block response and cannot receive new verification mail.
Public resend retains its generic successful response to avoid account enumeration.

### 2026-11-18 rollout

Apply `sql/migrations/2026-11-18-email-verification-reactivation-permission.sql` before
deploying the updated backend. Deploy the backend consistently across workers before
running the updated cleanup job. This is an internal column; public account statuses,
request fields and successful verification responses are unchanged.

The migration defaults existing rows to no automatic-reactivation permission. Old
deactivated rows cannot reliably distinguish administrative suspension from cleanup:
do not backfill permission based only on timestamps or missing audit entries. Support
must review these accounts and explicitly reactivate eligible users. Active unverified
accounts still verify normally. Without the migration, automatic deactivation is
skipped and unknown deactivated accounts remain blocked. Metadata-query errors fail
closed rather than being treated as an absent column. No migration is run by API code.

## Related enumeration fixes (2026-11-19, F16)

- `set_credentials` (guest adds email and password) keeps its 409 `CREDENTIALS_CONFLICT` for an
  email that is already taken: the app signs out on the success answer, so answering "success"
  would cost the guest their account. Instead the account owner gets the same notice email, and
  the action is limited to 10 per IP and 5 per account per day (429 above that).
- `login` with an unknown email checks the password against a fixed dummy hash, so the answer
  takes as long as for a real account.
- Friend search (`search_users`) matches an email only when `q` is the whole address
  (case-insensitive). Parts of an email no longer match; names match as before.
