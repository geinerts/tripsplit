# Subscription rollout

Status: Premium can be switched on for everyone from server configuration, and two features
check it. RevenueCat exists only as sandbox server verification. There is no purchase UI and
no store product. Nothing in this document is deployed or configured by itself.

## Free and Premium

Agreed with the owner on 2026-11-08. Everything a group needs to split money together stays
free, because a paywall there stops new people joining. Premium is extra value for one
person. Nobody pays to see their own data.

| Free | Premium |
| --- | --- |
| Trips and solo trips, invites and QR, friends, people without the app | Detailed PDF/CSV export (`trip_export`) |
| Expenses, categories, comments, reactions, mentions, activity | Year summary (`year_summary`) |
| Every split mode, including adjustments and itemized splits | |
| 120 currencies with automatic rates, receipt photos | |
| Payment requests, settlements, reminders, balances, debt simplification | |
| One trip budget, analytics, travel map, live map, random picker | |
| Offline use, notifications, languages, the trip report email | |

Planned, not built: AI receipt reading with a personal monthly limit (Premium), a short
year summary (free) next to the full one, a trip story with SPLYTO branding (free) and more
designs (Premium). Prices live in the stores, not in code.

Two products, decided on 2026-11-08: a yearly subscription for one person, and a one-off
Premium for a single trip that covers the whole group of that trip. The trip Premium exists
on the server and in the admin panel, without a purchase. See [trip Premium](../api/trip-premium.md).

The draft Free limits of one active trip and two currencies are dropped, with no daily
expense cap.

## Feature list and the server check

`premium_feature_catalog()` in `api/lib/helpers/helper_premium.php` is the one list of
features that can need Premium, each with its tier (`premium` or `free`) and scope (`trip` or
`account`). Moving a feature
between tiers is a change to that list only. Every gated action calls
`require_premium_feature($pdo, $me, '<feature>')`, which returns 403 `premium_required`
unless `premium_feature_allowed` says yes. The check uses the requesting account.

`premium_access` in the `me` payload carries `features`, the same answer for each feature in
the list, so the app shows a feature exactly when the server would allow it. A feature made
free on the server appears in current apps without an update.

## Premium for everyone

Two server settings switch Premium on for every active account:

- `TRIP_PREMIUM_FOR_EVERYONE`: `1` turns it on. Off by default.
- `TRIP_PREMIUM_FOR_EVERYONE_UNTIL`: optional end, `YYYY-MM-DDTHH:MM:SSZ` in UTC. Empty means
  no end date. A value in any other format leaves the switch off.

While it's on, accounts without their own grant get `plan: "premium"`, `source: "launch"`
and the end date, or `null`. An admin grant takes precedence, so testers still see their
own expiry. A deleted or suspended account stays `free`. If the grant table is missing, the
switch still applies. Switching it off needs no app update: features disappear on the next
profile refresh, and the server refuses them at once.

Changing these settings in production is a production configuration change and needs its
own approval.

## App rules

- `PremiumAccess` accepts `schema_version` 1 or higher, any boolean `billing_enabled` and
  `limits_enforced`, and any lowercase `source` up to 40 characters, so builds released now
  keep working when purchases (`purchase`, a trip pass) arrive. A Premium payload may have no
  expiry.
- Features are offered from `features`. Without it, the app falls back to `plan` and the
  expiry, as before.
- The profile hides the plan row while billing is off, unless the account has its own
  Premium (an admin grant), which shows its expiry. During `launch` nothing about plans is
  shown.
- Builds from before 2026-11-08 accept only `admin_grant`. They hide Premium features under
  `launch`. These are TestFlight builds only; ship the updated build before public release.

The removed `subscription_preview` payload is gone from `me`. Older apps already treat its
absence as unknown, and none used it to show or block anything.

Ordinary trip membership and permission checks remain mandatory regardless of plan.

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

- Do not monetize access to existing history, debt resolution, correcting old
  entries, splits, payment requests, joining trips, security, deletion or
  receiving a copy of personal data. Do not introduce a daily expense cap.
- The one-off trip Premium covers every current member of that trip, so it needs a
  grant that belongs to the trip, not to an account. It only unlocks features that
  belong to a trip, not account-wide ones such as the year summary.
- A limited Premium feature such as AI receipt reading needs a per-account monthly
  count, separate from the anonymous feature usage counters.
- On expiry, nothing a person created disappears; only Premium actions stop.
- Keep monthly/yearly products within one Premium tier. No prices are hard-coded.

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
3. Purchases feed `premium_access_for_user` with their own `source`, next to admin
   grants and the launch switch. The feature list and the app need no change.
4. A limited feature counts its use per account and month in the same transaction as
   the use. Return stable structured limit codes to all API clients.
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
   limited-feature counts, trip Premium for the whole group, and offline replay. Switch off
   Premium for everyone only once purchases work, with a rollback plan.

Do not set `billing_enabled` to true before a separate reviewed live contract and
all relevant gates above. Older app versions and
older servers must remain compatible during staged deployment.

## Checks

- `cd api && php vendor/bin/phpunit`
- `cd mobile && flutter test --no-pub`
- `cd mobile && flutter analyze --no-pub`

`PremiumGrantTest` covers the feature list, the launch switch and its end date,
and the precedence of grants. `premium_access_test.dart` covers the payloads that
current and future servers send.

Foundation verified locally on 2026-09-23: 87 PHP tests (294 assertions) and 55 Flutter tests
passed, including 18 subscription-foundation tests. Flutter analysis reports
27 existing warnings/info outside this change, no new findings in the touched
files. The next server step passes 105 PHP tests (380 assertions), including 18
additional sandbox/RevenueCat tests. The ledger tests use SQLite with explicit
MySQL syntax adaptations: they test rollback, uniqueness and ordering, NOT MySQL
locking behavior. Local Docker/MySQL was unavailable. No real store purchase,
external RevenueCat request, migration application or MySQL concurrency test is
claimed. Those remain sandbox deployment gates before any live use.
