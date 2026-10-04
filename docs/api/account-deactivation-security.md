# Account deactivation and retired email changes

Local implementation: 2026-10-04. No production rollout or real mail sent.

## Product boundary

Self-service email changes are removed. Profile email is read-only. Legacy
`request_email_change`, `confirm_email_change`, `cancel_email_change` and both web
confirmation/cancellation pages return HTTP 410. Even valid outstanding tokens cannot
change an address. Historical tables remain intact. Initial guest credential enrollment
and password changes retaining the same email are separate, supported operations.

## Deactivation contract

- Direct `deactivate_account` requires the current password. Social identity membership
  is not a password exemption. Password whitespace is preserved.
- Authenticated `request_deactivation_link` requires an active, verified, established
  account. It sends only to the stored contact address, never a submitted recipient.
- Request limits: IP 10/15 minutes, user 3/hour, global 100/hour. Under a user-row lock,
  enforce a 60-second cooldown and three attempts per rolling hour. Limits fail closed
  when their storage is missing. Existing delivered proofs survive another request.
- Proofs contain 256 random bits, stored as SHA-256 hashes, expire after 15 minutes and
  are bound to user ID, email, password hash, verification, enrollment and deactivation
  state. Only the `deactivate` purpose is accepted. Old unbound proofs fail closed.
- Requesting the email preserves the session and account. Failed delivery invalidates
  the newly issued proof only. Delivery is synchronous; no durable outbox is introduced.
- Opening `deactivate-account.php` does not mutate anything. An explicit confirmation
  submits the proof. The page uses no-store/no-referrer headers and clears its query
  from browser history; origin access-log token redaction is separate deployment work.
- Confirmation limits: IP 20/15 minutes, token 5/15 minutes, fail closed.
- Confirmation locks the user then proof. Deactivation, refresh-token revocation, push
  disabling and consumption of all pending account-action tokens commit together.
  Injected write failures roll back the entire operation. No replacement session is issued.
- Password-based deactivation also consumes pending account-action tokens. Deactivation
  is not deletion; existing reactivation remains a separate workflow needing further audit.

## Rollout

Apply `sql/migrations/2026-10-04-deactivation-email-proof.sql` before the backend update.
It extends the action enum and adds a nullable credential-state hash. Missing state schema
or refresh-session storage prevents email confirmation. Coordinate the mobile update:
older social clients relying on password bypass will now receive a reauthentication error.

Verify actual delivery and explicit confirmation for password, Google and Apple relay
accounts before beta. Existing deletion email proof, reactivation and login/refresh races
still need coordinated lifecycle validation. Access-token invalidation policy remains
SEC-05 work; this change must not be described as instantaneous revocation of all JWTs.

## Evidence

- 29 tests / 279 assertions on SQLite and isolated MySQL: password/email success, social
  placeholder accounts, request-only invariants, wrong purpose, expiry/replay, changed
  credentials/contact/state, inactive/unverified/guest accounts, missing infrastructure,
  cooldown/budget, recipient override, mail failure and transactional rollback.
- 15 MySQL races / 60 worker requests: concurrent requests send once; same/different
  proofs produce one successful mutation. Fixtures apply the actual migration to a
  minimal legacy table, not the full production schema/foreign-key graph.
- Credentials suite: 23 / 300, including all three retired API routes and no mutation.
- Full PHP: 276 / 2203. Full Flutter: 88 passed. Two profile widgets verify read-only
  email and session preservation when requesting deactivation confirmation.
- Handler tests stub mail and limiter calls; shared limiter SQL has separate recovery
  integration checks. PHP page smoke checks verify 410/confirmation markup. These are
  not deployed HTTP, browser screenshot, device, real provider or email-delivery E2E tests.
