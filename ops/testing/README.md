# Isolated account security tests

This is a local handler/database integration environment, NOT a full deployed staging
application. It uses PHP 8.3, MySQL 8.4/InnoDB and synthetic records only. Verify the exact
production database version separately before claiming full environment parity.

## Run

Prerequisites: running Docker Desktop and the project's locked PHPUnit dependencies
already installed under `api/vendor` (`composer install` in `api` if missing).
From the repository root:

```sh
docker compose --env-file /dev/null -f ops/testing/compose.yaml up --build --abort-on-container-exit --exit-code-from tests
```

The runner executes the existing 19 registration regression tests on MySQL, then five
rounds of four simultaneous-request scenarios, six PHP workers each (120 requests).
It fails on duplicate users, changed existing identities, unexpected rejection codes or
extra session/email/event calls. A readiness barrier starts workers together. This tests
real concurrent connections, not all possible schedules or failures.

The scenarios cover a shared device ID with/without credentials, a shared email across
different devices, and attempts to overwrite an existing verified account. The focused
regression suite also covers unverified/inactive/guest accounts, proof replay, bad proof,
new signup, verification and infrastructure errors with/without name columns.

Next, the runner executes 23 credential-security tests (300 assertions): established-account
enrollment denial, verified guest enrollment, current-password reauthentication, email
change retirement, session revocation and injected database failures. Five rounds of two
four-worker races cover enrollment and password change (40 requests). The credential
suite uses real access-token/refresh-token helpers with a test-only signing secret.
Mail delivery, HTTP handling, profile payload extras and rate limiting remain adapters.

Then 48 social-identity tests (618 assertions) exercise real JWT verification using ephemeral
RSA-signed synthetic Apple/Google tokens. External JWKS retrieval is replaced. Cases cover
unlinked email collisions, unverified/missing claims, incorrect signatures/claims, exact
subject matching, returning accounts and inactive users. Handler tests use the legacy
case-insensitive subject index. The runner then applies the actual subject-collation
migration twice and checks row preservation, exact lookups and unique-index enforcement.
Social concurrency and real provider/device flows are not covered by these tests.

Password recovery adds 29 tests (300 assertions), followed by 15 four-worker races (60
requests): concurrent email requests, same-link use and different valid links for one user.
The handler tests use synthetic delivery/limit adapters. A separate runner executes the
real MySQL limiter SQL at all five recovery thresholds and verifies missing storage fails
closed. Reset fixtures apply the actual credential-state migration to a minimal old table.

Deactivation adds 29 tests (279 assertions), then 15 four-worker races (60 requests):
concurrent email requests and same/different-link confirmation. Tests cover password and
email ownership, purpose/state/expiry, request-only session preservation, failure rollback,
mail failure and retired email-change compatibility. Its real migration is applied to a
minimal old account-action table. Mail and handler rate-limit calls remain test adapters.

Deletion/reactivation adds 77 tests (734 assertions), six schema-contract cases using the
real table mapper, and 35 four-worker races (140 requests). Covers single-use state-bound
proofs, request cooldowns, rollback and deletion racing deactivation. Synthetic fixtures
also include friendship/provider rows and payment profile fields; no real data is mounted.

Stop/remove only this disposable test environment afterward:

```sh
docker compose --env-file /dev/null -f ops/testing/compose.yaml down
```

No persistent database volume is used. Stopping MySQL discards its test data. Keep the
images for the next run; do not use global Docker prune or remove unrelated containers.

## Isolation and limits

- No host ports. Both containers use a dedicated internal network with no ordinary
  outbound connectivity; image/build dependency downloads happen before runtime tests.
- Only selected code/test/vendor paths are mounted, read-only. No `.env`, keys, uploads,
  SSH credentials, Docker socket or production configuration is mounted.
- PHP runs without root/capabilities and with a read-only root filesystem; `/tmp` is writable.
- Public, deliberately disposable test credentials authenticate only to this test DB.
  Never reuse them for staging with real data or for production.
- Test connection has a fixed local service/database/user, requires the dedicated runtime
  marker and verifies a synthetic database marker before any table reset. There is no
  arbitrary DSN/environment fallback to production. Fixtures recreate only their synthetic
  `trip_users`, `trip_refresh_tokens`, `trip_email_verification_tokens` and
  `trip_email_change_requests`, `trip_user_identities`, `trip_password_resets` and
  `trip_request_limits`, `trip_account_action_tokens` and `trip_push_tokens` tables.
- The MySQL fixture mirrors the relevant production user fields, unique indexes and
  collation. Social fixtures add `avatar_path` and a minimal identity table without the
  full foreign-key graph. Only the subject-collation, reset-state and deactivation-proof migrations are mounted and tested;
  this does not apply the entire application schema/migrations.
- Real registration/proof handlers run. HTTP transport, schema capability checks, rate
  limiting, mail, audit events and auth issuance are controlled adapters. Calls are counted;
  no production mail, push or sessions are issued. Credential tests store synthetic
  refresh sessions and verify rollback with failing triggers. Binary logging is disabled
  only in this disposable DB so triggers need no SUPER privileges. This is NOT an HTTP/E2E test.
- SQLite remains the default outside Docker; the MySQL mode is explicitly opt-in and
  refuses to connect outside this marked runtime. Do not run concurrent copies against
  the same Compose project, because the fixture intentionally resets its test table.
- No production deployment, application migration, store build or configuration change
  is performed by these commands. F01/F04 local coverage is not full deployed assurance;
  other audit findings and the credential contract's residual risks remain separate work.

## Session revocation

The suite also runs `SessionRevocationSecurityTest` (11 scenarios) against MySQL,
then 12 races / 36 requests combining real password login, refresh rotation and
password-reset or deactivation handlers. Newly issued access and refresh tokens
must be unusable after the security event commits. Unrelated sessions must stay
unchanged. See `docs/api/session-revocation.md` for boundaries and rollout behavior.
