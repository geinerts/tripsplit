# Email password recovery and setup

Local implementation, 2026-10-04. This is the password slice of the owner's simplified
email-ownership approach, NOT a generic reauthentication grant for other sensitive actions.

## Contract

`forgot_password` accepts an email. Eligible accounts are active, have completed credential
enrollment and have a verified contact email. Social placeholder passwords do not prevent
recovery: an Apple/Google user can choose a Splyto password after proving email access.
Unverified accounts must complete the existing verification flow first. Provider links are
not changed, created or removed. No password capability is inferred from social membership.

Request limits run before user lookup, also for unknown addresses:

| Scope | Limit |
| --- | --- |
| Request IP | 10 per 15-minute fixed window |
| Request email | 3 per hourly fixed window |
| Request global | 100 per hourly fixed window |
| Account delivery attempts | 60-second rolling cooldown, 3 per rolling hour |
| Confirmation IP | 20 per 15-minute fixed window |
| Confirmation token | 5 per 15-minute fixed window |

The global budget counts requests, not just sent mail. It deliberately bounds delivery but
can also limit legitimate recovery under abuse; tune with monitoring before wider rollout.
Use the existing rate-limiter store. Recovery opts into fail-closed behavior if that table
is missing; other callers retain their previous default. Missing reset-state migration or
refresh-session storage also fails closed. Database/infrastructure errors do not grant access.

For valid input within limits, unknown/ineligible accounts, cooldown, success and delivery
failure return the same `{ok:true}` body. Rate limits return 429 independently of account
lookup. This is uniform status/body handling, not a claim of timing indistinguishability.
Mail still sends synchronously, so timing protection remains open.

Under the user-row lock, a current locking read checks recent attempts. A consistent-snapshot
read is insufficient under MySQL repeatable read: the concurrency tests caught duplicate
sends before it was changed to `FOR UPDATE`. A new request does not invalidate older links.
Failed delivery marks only the newly issued proof used and retains its attempt for the
cooldown/budget. Provider exception details are not returned. No real mail was sent in tests.

The random 256-bit token is emailed to the stored account address. Only its SHA-256 hash is
stored. A separate state hash binds it to user ID, normalized email, password hash, email
verification timestamp and enrollment flag. The one-hour expiry is UTC. Password rehash or
contact/verification changes can invalidate a pending proof; the user must request another.

`reset_password` requires the proof, not an existing session or old password. It locks the
user before the reset row, checks expiry/unused/state/active eligibility, then updates the
password, consumes all outstanding password-reset proofs for that user and revokes refresh
sessions in one transaction. Failure rolls all of these back. No new auth session is issued.
Sign in again using the new password or the previously linked provider.

## Mobile behavior

Profile -> Change password -> Set password by email opens the existing recovery screen
with the current email prefilled, no current-password requirement, localized labels and
Back to profile on success. Requesting the link preserves the current session. The ordinary
login-screen recovery entry stays available. The new label applies to all account types;
we do not guess whether a legacy social account also has a real user-chosen password.

## Rollout

1. Apply `sql/migrations/2026-10-04-password-reset-state.sql` once through the migration
   process before deploying the new backend. It adds a nullable column without deleting data.
2. Existing reset rows have NULL state bindings and will be rejected intentionally. Users
   must request a new link. Do not synthesize state bindings for old proofs.
3. Deploy the backend and mobile update; verify real delivery and completion for password,
   Google and Apple private-relay accounts. Never use real mail in the synthetic test suite.

No production deployment or migration was performed for this implementation.

## Verification and remaining work

- 29 tests / 300 assertions: success including social placeholder accounts, proof replay,
  expiry, inactive/unverified/guest accounts, changed credentials/email, malformed/unknown
  proofs, legacy proofs, missing schema/session storage, transaction rollback on injected
  reset/session write failure, cooldown, rolling budget, preserved prior links and mail failure.
- Run on SQLite/PHP 8.5.4 and isolated MySQL 8.4.11/PHP 8.3.35. MySQL fixtures apply the actual
  reset migration to the old minimal table. This is not a full production schema rehearsal.
- 15 MySQL races / 60 worker requests: repeated requests send once; same or different valid
  proofs yield one password mutation. Real limiter SQL has separate MySQL threshold,
  subject-isolation and missing-storage tests; handler tests stub rate limiting and delivery.
- Full PHP 247 tests / 1914 assertions, full Flutter 86 tests passed. No HTTP/device/provider
  email end-to-end test, production data or external service access in these checks.
- Access tokens already issued may remain valid for their existing lifetime (default 900s).
  Concurrent login/refresh vs reset, other pending email/account-action proofs, durable
  asynchronous delivery/timing protection and failure monitoring remain SEC-05 work.
- A subsequent local batch removed email changes and the social deactivation exemption,
  adding operation-bound email deactivation confirmation; see `account-deactivation-security.md`.
  Review deletion/reactivation's existing emailed proofs separately. Additional provider
  linking and native provider reauthentication are deferred, not silently enabled.
