# RevenueCat sandbox setup

This is a server-verification checkpoint, not a live subscription release.
Configuration and migration have NOT been applied to the VPS. All public app
behavior is unchanged. Keep real billing and Free limits off.

## Dashboard setup required

1. Create a RevenueCat project for Splyto. Add the App Store app with bundle ID
   `com.tripsplit.app.tripsplit`; add Google Play later using the same package ID.
2. Connect the store credentials using RevenueCat's setup flow. Create monthly
   and yearly auto-renewable products in the store and import them. Final pricing
   and product identifiers still require owner approval; none were invented or
   created by this code change.
3. Create entitlement `splyto_pro` and associate those subscription products.
   Collect the RevenueCat project ID (`proj...`) and RevenueCat product IDs
   (`prod...`). Do not confuse these with the store product identifiers.
4. Require login before purchasing. Set restore behavior to **Keep with original
   App User ID**, including the sandbox override if present. This deliberately
   rejects cross-account restore; support must offer account recovery, not an
   automatic transfer. Never configure the SDK anonymously. Use the server-issued
   UUID as the App User ID across both platforms. Public friend-share tokens and
   email addresses must not be used as billing identities.
5. Create a server API v2 secret with ONLY
   `customer_information:subscriptions:read`. The Flutter SDK will later use the
   separate platform PUBLIC SDK keys. Never embed the server secret in Flutter,
   a repository, screenshots, logs or chat.

## Server preparation

After reviewing the migration and testing it against an isolated MySQL database,
deploy the relevant files and apply
`sql/migrations/2026-09-23-add-subscription-sandbox-ledger.sql` with the existing
migration runner. Review its pending list first; do not blindly apply unrelated
pending migrations. These tables assume the project's standard `trip_` prefix.

Use the established VPS account `splytoadmin`, not root SSH. The production
environment file is `/etc/splyto/splyto.env`, outside the web root. Add the keys
documented in `.env.example`, initially leaving `TRIP_RC_SANDBOX_ENABLED=false`.
`TRIP_RC_SANDBOX_USER_IDS` is an explicit comma-separated list of internal test
account IDs, never `*`. `TRIP_RC_SANDBOX_PRODUCTS` is JSON mapping `app_store`
and/or `play_store` to allowlisted RevenueCat product ID arrays. Empty or invalid
configuration keeps both endpoints unavailable.

Enable only for the agreed tester accounts after setup. TestFlight remains
connected to the normal backend, but these routes reject production purchases
and do not modify `subscription_preview` or real access permissions.

## Current API checkpoint

An authenticated POST to `api/api.php?action=subscription_sandbox_session`
returns the caller's UUID under `sandbox.app_user_id`. The authenticated user's
ID comes only from the access token, not the request body. Repeated calls return
the same UUID. Wrong/non-allowlisted users cannot obtain another user's identity.

Once a real store sandbox purchase exists under that UUID, an authenticated POST
to `api/api.php?action=subscription_sandbox_verify` accepts:

```json
{"subscription_id":"sub_FROM_REVENUECAT","request_id":"unique-verification-attempt"}
```

The subscription reference currently comes from RevenueCat diagnostics. It is
NOT a receipt and not necessarily present in Flutter SDK CustomerInfo. A future
account-scoped sync endpoint must discover RevenueCat subscriptions server-side
before wiring mobile purchase/restore to this checkpoint.

Results are attempt statuses (`applied`, `pending`, `superseded`, `failed`), not
Pro grants. `production_access` is always false. A failed/superseded/abandoned
pending attempt should be retried with a new request key; an already successful
request can be safely retried with the same key. Do not automatically retry in
a tight loop. Provider 429/outage requires backoff.

## Remaining before a TestFlight purchase flow

- Configure products and SDK keys, integrate the official Flutter SDK, fetch
  offerings/localized store prices, serialize purchase/restore with account
  switching and refresh verified state through account-scoped server sync.
- Implement an authenticated signed webhook inbox plus retry worker. Notifications
  trigger authoritative re-fetch; do not apply unverified event fields directly.
- Reconcile status after store outages, expiry, refund/revocation and missed events;
  establish retention for sandbox attempts and privacy/account-deletion handling.
- Test MySQL migration and concurrent writes against MySQL itself. SQLite unit
  tests intentionally do not prove MySQL row-lock behavior.
- Run real store sandbox purchase/renew/cancel/expire/restore/reinstall tests and
  cross-account restore rejection. Verify sandbox cannot grant production access.

## Official references

- [RevenueCat subscription API](https://www.revenuecat.com/docs/api-v2/subscription)
- [Subscription data model](https://www.revenuecat.com/docs/api-v2/subscription-data-model)
- [Customer identity](https://www.revenuecat.com/docs/customers/identifying-customers)
- [Restore behavior](https://www.revenuecat.com/docs/projects/restore-behavior)
- [Webhook authentication and retries](https://www.revenuecat.com/docs/integrations/webhooks)
