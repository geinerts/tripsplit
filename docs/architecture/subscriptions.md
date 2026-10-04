# Subscription rollout

Status: preview foundation and opt-in RevenueCat sandbox server verification,
2026-09-23. No purchase UI, paywalls or commercial limit enforcement. No production
deployment, applied migration or store product configuration is included.

## Implemented

- One server-side draft catalog (`helper_subscription.php`): Free allows one
  active owned trip and two currencies per trip; Pro has no commercial count
  limit on these two dimensions. Null explicitly represents no count limit.
- Private `me` payloads include `subscription_preview`, also covering login,
  registration, session refresh and profile updates through `build_me_payload`.
  No client-writable plan field is introduced.
- Payloads are versioned and account-bound. Actual current limits remain null;
  proposed plans are separate. Billing and enforcement are hard-disabled in
  code, not enabled by an environment variable or profile parameter.
- Flutter loads the preview with the authenticated profile. Invalid, unknown,
  enabled-billing or cross-account payloads are ignored without breaking login.
  An absent preview means unknown/unavailable, not Free or Pro authorization.
- Profile copies preserve the preview only for the same user. Offline profile
  storage neither writes nor trusts this information. Existing auth-generation
  checks protect against late profile responses after account switching.
- PHP and Flutter tests consume one shared JSON contract fixture.

This is deliberately not a purchase record, an entitlement resolver, a usage
counter or an authorization gate. No UI should advertise an active subscription
or use proposed limits to block operations. Pro definitions in the catalog do
not grant Pro to any account. Ordinary trip membership and permission checks
remain mandatory regardless of future subscription status.

## RevenueCat sandbox server

RevenueCat was selected by the user. The server adapter reads the API v2
subscription resource using a server-only key. It checks sandbox environment,
current AND original owner, purchased ownership (not Family Sharing), configured
entitlement/project and allowed RevenueCat product IDs. Store and latest renewal
IDs are not trusted from client input. The ledger fingerprints the stable
RevenueCat project/subscription ID, not the latest store transaction ID.

- `subscription_sandbox_session` (POST): authenticated, active verified account,
  tester allowlist, rate limit; returns a random persistent UUID App User ID.
- `subscription_sandbox_verify` (POST): same guards; accepts `subscription_id`
  (RevenueCat `sub...` ID) and `request_id` (8-96 safe characters). The ID is only
  a lookup hint; all state is read from RevenueCat on the server.
- Both are disabled unless sandbox configuration is complete and explicitly on.
  Production transactions are always rejected. Neither can grant real Pro.
- The new migration adds identity, sandbox-attempt and sandbox-purchase tables.
  Purchase ownership is immutable; unique keys and transactional row locks
  prevent a second account from claiming an existing purchase. A monotonically
  ordered verification sequence prevents an older result replacing a newer one
  for the SAME purchase, without dropping independent purchases.
- Provider calls happen without holding DB transactions. Active-account status
  is checked again before saving. Failed validation/provider requests preserve
  the prior observation. There is no silent fallback to trusting client state.
- Duplicate requests return the recorded attempt status without repeating the
  provider call; changed references under the same request key are rejected.
  Failed or abandoned pending attempts require a NEW request key for retry.
  These keys are not authenticated webhook event IDs and are not a webhook inbox.
- The test-state projector uses provider `gives_access`, preserves paid time
  after cancellation, and requires revalidation after 5 minutes. It does not
  infer permanent access from grace periods, errors or missing expiry dates.
- Only fingerprints and minimal normalized state are stored; no receipts,
  Google purchase tokens, secrets, email or provider response bodies are logged
  or stored by this integration. Existing soft deletion is respected; hard
  deletion of billing owners is restricted to preserve purchase binding. Define
  retention/account recovery and provider erasure procedures before live launch.

See [sandbox setup](../process/revenuecat-sandbox.md). The Flutter purchase SDK,
product discovery, purchase/restore UI, signed webhook inbox/worker, automated
reconciliation, production resolver and limit enforcement are NOT implemented
by this server-only step. Nothing in the app currently starts a purchase.

## Product rules for the next phases

These are the initial design, to confirm before enforcing limits:

- Count only owned trips with status `active`, not joined trips or historical
  trips. Settlement-stage trips do not consume an active-trip slot. Resolve the
  actual canonical owner; do not treat every admin/member as an owner.
- Currency limits are a count from supported currencies, never a country-based
  whitelist. Count the trip base currency plus distinct currencies on current
  expenses. Editing within the existing set must not require an upgrade.
- An organizer's Pro benefits apply to that trip's participants, not to their
  own separately organized trips. Trip currency access must therefore be
  resolved from the owner/trip, not solely from the requesting user's plan.
- Do not monetize access to existing history, debt resolution, correcting old
  entries, basic splits, payment requests, joining trips, security, deletion or
  receiving a copy of personal data. Do not introduce a daily expense cap.
- On expiry, keep existing active trips usable with their existing currencies;
  require Free limits for new trips/new premium expansion. Persist per-trip
  grandfathering explicitly, including trips predating the paid rollout.
- Keep monthly/yearly products within one Pro tier. No prices are hard-coded.
  Receipt processing, storage, analytics and exports are not promised by this
  implementation; decide their limits/value before adding them to the catalog.

## Next implementation gates

1. Finish sandbox integration: RevenueCat chosen; server verification and sandbox
   ledger implemented, not configured/deployed. Configure store products, add
   mobile purchase/restore and webhook inbox, verify signed notifications. Bind an
   original purchase to one account, reject replay/cross-account restore, process
   duplicate and out-of-order events idempotently, reconcile with store state.
   Never accept a client `is_pro`, expiry date or receipt-validation result.
2. Entitlement resolver: server time, current expiry, cancellation effective at
   period end, refund/revocation, payment failure, grace period and store outages.
   Resolve account and owner-sponsored trip access separately. Define ownership
   transfer and downgrade behavior before allowing transfers to bypass limits.
3. Shadow usage evaluation before enforcement: count owned active trips and
   currencies without denying requests. Measure actual use with minimal data.
   Ensure create/reopen/transfer/import and add/edit expense paths are covered.
4. Enforcement: transactional locking around owner quota plus trip creation,
   and trip quota plus currency changes; evaluate on the same transaction as
   the write. An independent count before insert is race-prone. Preserve mutation
   idempotency. Return stable structured limit codes to all API clients.
5. Mobile purchase/restore/manage UI with localized store prices, renewal terms,
   privacy/terms links and accessible errors. Do not ship a nonfunctional buy
   button or web checkout until relevant store/region rules are reviewed.
6. Offline handling: a cached profile cannot prove paid access. Design a bounded
   verified offline entitlement cache; the server remains authoritative on sync.
   Keep local drafts/pending changes if a limit prevents sync and offer recovery.
   Current queue handling can discard non-retryable 4xx failures; add explicit
   recoverable handling for subscription-limit errors BEFORE enabling enforcement.
7. Release gates: test purchase, restore, renew, cancel, expire, grace, revoke,
   reinstall, account switch, duplicate/out-of-order notifications, concurrent
   quota writes, organizer sponsorship, ownership transfer, grandfathering and
   offline replay. Confirm Free/Pro limits and existing-user rollout, then enable
   enforcement independently from purchase availability with a rollback plan.

Do not change the preview booleans to enable billing. A separate reviewed live
contract and all relevant gates above are needed first. Older app versions and
older servers must remain compatible during staged deployment.

## Checks

- `cd api && php vendor/bin/phpunit`
- `cd mobile && flutter test --no-pub`
- `cd mobile && flutter analyze --no-pub`

Shared fixture: `api/tests/Fixtures/subscription_preview_v1.json`. New contract
tests cover catalog values, unchanged current limits, valid ownership, ignored
Pro input, backward compatibility, malformed data and untrusted profile caches.

Foundation verified locally on 2026-09-23: 87 PHP tests (294 assertions) and 55 Flutter tests
passed, including 18 subscription-foundation tests. Flutter analysis reports
27 existing warnings/info outside this change, no new findings in the touched
files. The next server step passes 105 PHP tests (380 assertions), including 18
additional sandbox/RevenueCat tests. The ledger tests use SQLite with explicit
MySQL syntax adaptations: they test rollback, uniqueness and ordering, NOT MySQL
locking behavior. Local Docker/MySQL was unavailable. No real store purchase,
external RevenueCat request, migration application or MySQL concurrency test is
claimed. Those remain sandbox deployment gates before any live use.
