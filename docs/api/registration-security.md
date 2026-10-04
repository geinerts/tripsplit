# Registration identity boundary (SEC-01 / F04)

Status: locally verified, 2026-10-04. Not deployed. This closes only the registration
device-ID reuse path; it does not complete SEC-01 or the wider authentication audit.

## Contract

- `register_proof` still returns a short-lived proof bound to a device identifier.
  A proof authorizes an attempt to create a new account, not access to an existing one.
- `register` inserts a new user. It never updates a user on email/device-token collision.
- Collision response: HTTP 409, `ok: false`, `code: REGISTRATION_CONFLICT` and a message
  directing the user to sign in or recover their account. No `me`/`auth` payload is returned.
- This applies to guest, verified, unverified and inactive existing accounts, whether
  or not the request supplies credentials. No mail, registration event or session is
  issued for the rejected attempt. A valid proof replay does not bypass this rule.
- Ordinary successful creation and verification-required response contracts remain
  unchanged. Session issuance resolves the new insert ID, not the client device token.
- Infrastructure errors outside integrity-constraint violations propagate as errors;
  they are not disguised as successful registration.

## Compatibility and rollout prerequisites

No migration is added: `sql/schema.sql` already defines unique device-token and email
indexes. Confirm those indexes on the target database before rollout. Their uniqueness
is the concurrency boundary; a separate SELECT-before-INSERT would not suffice.

Existing clients must sign in/recover rather than replay registration to regain access.
In particular, retrying after an uncertain network response or a verification-required
response can now return 409. Never automatically fall back to device-ID authentication.
Test the verification resend/login UI and same-device new-account journey before release.
Authenticated guest credential enrollment is a separate flow; registration is not an upgrade.

This patch intentionally does not modify `set_credentials`, profile password updates,
email changes, password recovery, social linking or session revocation policy. F01 remains
open. The `@example.test` production shortcut (F11) also remains open in this first slice.

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
