# Deletion and reactivation confirmation links

Local implementation and verification: 2026-10-05. Not deployed or pushed in this batch.
This completes the scoped link-hardening work, not the whole account-erasure or session audit.

## Proof and account boundary

- Keep existing API actions and response shapes. No new mobile navigation is required.
- Deletion requests require an authenticated active, verified, established account.
  Existing password-based request confirmation remains; social accounts may request an
  email without a local password, but cannot actually delete without the email proof.
  Wrong passwords return 403, not a session-refresh-triggering 401.
- Public reactivation requests only issue mail for verified, established, deactivated
  accounts. Unknown/ineligible addresses, cooldown and mail failure return the same 200
  response. This does not hide synchronous delivery timing.
- Send only to the freshly locked stored contact address. Client recipient overrides are
  ignored. Reactivation rechecks the lookup email under the user lock.
- Each proof has 256 random bits; only its SHA-256 hash is stored. A separate state hash
  binds the purpose, user ID, email, password hash, enrollment flag, email verification,
  account status and deactivation/deletion timestamps. Another action or account cannot
  use it. Changed credentials/state, expired, consumed and unbound legacy proofs fail.
- Expiry is bounded at one hour for deletion and 24 hours for reactivation, respecting
  shorter supported configured lifetimes. Only exact 64-character lowercase hex is accepted.
- New requests preserve delivered prior links. Under the user lock, enforce a 60-second
  cooldown and three delivery attempts per rolling hour, including failed attempts.
- Additional fail-closed limits: request IP 10/15 minutes, email or user 3/hour, global
  100/hour per action; confirmation IP 20/15 minutes and proof 5/15 minutes. Shared storage
  failures cannot bypass the limits. Mail failure invalidates only the newly issued proof.

## Atomic confirmation

Lock the user before the proof in every lifecycle confirmation. Recheck purpose, user ID,
state, current eligibility, expiry and unused status inside that transaction. Deletion is
only valid for the active state; reactivation only for the deactivated state. Deleted
accounts cannot be restored by a link.

The account update, refresh-session revocation, push disabling and consumption of ALL
outstanding account-action proofs commit together. Deletion also removes friendships and
provider identities and anonymizes the profile, including bank/payment contact fields
that the previous implementation left behind. Shared trip/expense accounting is retained.
Injected failures roll back all database effects; another user's rows are unchanged.
Reactivation issues no login session and leaves old refresh/push credentials disabled.

Avatar-file cleanup follows commit and cannot be transactional with MySQL. Durable cleanup
retries, historical data in other tables/logs/backups and full erasure/retention policy remain
separate work. This is not a claim that every personal-data copy is removed immediately.

## Confirmation pages and rollout

Opening either page is non-mutating. Deletion still requires typing DELETE. The browser
guards pending and completed requests against double clicks, rejects HTTP failures even
if a body incorrectly says ok, supports retry, and clears its in-memory proof on success.
Existing no-store/no-referrer/CSP headers and query removal remain.

No new migration: requires the already-added `credential_state_hash` column from
`2026-10-04-deactivation-email-proof.sql`, lifecycle user columns and refresh-token storage.
Schema checks use unquoted metadata names from the real quoted table-name helper.
Old deletion/reactivation links with NULL state bindings are intentionally rejected; users
must request a new email. Do not synthesize bindings for previously issued links.

Deploy the updated Nginx private-upload snippet BEFORE sending new links: it allows all
three lifecycle confirmation paths and disables their origin access logs. Cloudflare,
email-provider logs and other observability retention require separate verification.
No production configuration or migrations were changed during this local work.

## Evidence and remaining gates

- AccountLifecycleSecurityTest: 77 tests / 734 assertions on SQLite and isolated MySQL,
  including replay after reconstructed old state, wrong account/purpose, state changes,
  mail failure, cooldown/budget, social accounts and transaction failure injection.
- Six schema-contract scenarios (24 assertions) exercise the real quoted table mapping
  with a custom prefix, including missing-schema failures.
- 35 MySQL races / 140 worker requests: deletion/reactivation request delivery, same and
  different proof consumption, and deletion racing deactivation. Exactly one mutation wins.
- Full PHP: 359 tests / 2961 assertions. All existing isolated MySQL security suites pass.
- Web: 26 tests pass, including six new real-PHP-rendered page checks; browser interactions
  run at 360px and 1280px with API responses intercepted. No actual email or account action.
- Fixture schemas are deliberately minimal, not a complete production foreign-key graph.
  Handler limiter/mail calls are test adapters; shared limiter SQL is separately exercised
  by the existing MySQL rate-limit suite. Browser tests do not verify production routing,
  logo asset delivery, deployed Nginx headers or real Apple private-relay delivery.
- Next: step 2, access-token invalidation and login/refresh/security-event race ordering.
  Especially verify old access tokens cannot regain access after reactivation. This batch
  revokes refresh sessions but does not introduce an access-token security epoch.
