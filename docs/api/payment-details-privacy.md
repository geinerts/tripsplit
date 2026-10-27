# Request-scoped payment details

## Contract

Friendship and trip membership alone do not grant access to payment profiles. Both
friend-list variants and workspace users omit bank details and payment links.
The account owner's own profile is unchanged.

`create_trip_payment_request` accepts optional JSON boolean
`share_payment_details`. Only literal `true` records consent; omitted, false,
string and numeric inputs do not. Consent belongs to the authenticated payee
and is stored in the same transaction as the request. Supplying another
`to_user_id` or `requester_user_id` cannot share somebody else's profile.

`POST trip_payment_request_details`, with `X-Trip-Id` and body `payment_id`,
returns `payment_details` only when all of these are true in the read query:

- Authenticated actor is the payment's payer, not its recipient or trip owner.
- Request was created by the recipient and explicitly shares payment details.
- Request is still `requested`, and the trip is `active`.
- Both people remain trip members and both accounts are active.
- Payment belongs to the selected trip; self-requests are rejected.

Allowed fields: account holder, IBAN, BIC, Revolut handle/link, PayPal.me link,
Wise link. No email, credentials or additional profile fields. Missing or
unauthorized details return 404; missing consent migration returns 409. The
normal API JSON response has `Cache-Control: no-store`; there is no public URL.
The `can_view_payment_details` UI flag is only a hint, never authorization.

## Client behavior

The request form has an unchecked sharing checkbox with localized scope text.
The payer explicitly opens details; every opening/retry makes a fresh authorized
request. The response is an ephemeral `PaymentDetails` object, not a user profile
or workspace snapshot. No offline fallback or persistent storage is used. The
repository rejects responses after account/session generation changes.

Trip and friend parsers ignore legacy payment fields, including old snapshot
data. Generic profile screens no longer show an empty bank-details placeholder.
Existing standalone settlement suggestions do not silently expose bank details.

Revocation stops subsequent reads. It cannot retract data already seen, copied
or captured by the recipient; an already admitted response can finish. This is
not a guarantee of erasing information from another person's device.

## Rollout

1. Apply `2026-10-05-add-payment-details-consent.sql` through the migration runner.
   Existing requests receive consent 0; never backfill consent to 1.
2. Deploy backend files, including `settlements_payment_details.php` and router.
3. Verify authenticated positive/negative HTTP cases in an authorized test
   environment and confirm response-cache behavior at the proxy.
4. Release the mobile client with the explicit checkbox and details sheet.

The schema is additive. A backend without the consent column can still accept
requests without sharing, but rejects attempts to share. A new client must not
fall back to friend or trip payloads. Old clients cannot opt into the new sharing
flow and will stop receiving other people's payment profiles.

## Verification and remaining scope

`PaymentDetailsPrivacyTest` covers 25 SQL/payload cases on SQLite and MySQL 8.4,
including the actual migration and default consent on old requests.
`PaymentDetailsConsentHandlerTest` covers 8 real handler/transaction cases:
explicit/omitted/invalid consent, spoofed recipient/requester inputs, rollback,
and missing migration behavior. Auth transport, rate limiting, balance math,
notifications and idempotency storage are adapters in that fixture.

Mobile tests cover old-payload minimization, fresh reads, offline denial, late
cross-account responses, consent-aware retry keys, loading/error/retry UI, and
320px layouts in English, Latvian and Spanish. These are not store/device E2E
tests, nor new concurrent membership-change tests.

Pending-invitation membership, accept/decline/remove/rejoin behavior and related
receipt/activity/statistics permissions are a separate remaining security batch.
Do not interpret payment-profile minimization as completion of that work.


## Profile opt-in for all joined trips (2026-10-26)

Locally implemented; requires backend migration/deployment and a new mobile build.
The owner requested an explicit global preference under Profile → Payment methods.
`share_payment_details_with_trips` defaults to 0 for all existing/new users. Only
literal JSON booleans on `update_profile` change the authenticated user's setting;
client-supplied user IDs cannot change somebody else's consent. `me` returns the
boolean; unrelated profile changes leave it unchanged. Missing migration rejects
consent writes and member-detail reads with 409, and reports false in `me`.

`POST trip_member_payment_details` takes `X-Trip-Id` and `user_id`. One SQL query
checks the target's opt-in and both active accounts' membership in the selected
trip, then returns only the seven existing payment-detail fields. Pending invites,
friendship, owner/admin status or membership in a different trip do not grant
access. The preference applies to current and future joined trips, including
retained membership in archived trips. Leaving/removal or switching it off denies
subsequent reads. Separate explicitly shared payment requests keep their original
consent contract; this preference does not silently revoke those requests.

Details are fetched when a member profile opens or is refreshed/retried, never
placed into workspace/friend caches, and guarded against late cross-account
responses. The owner continues to see their own data. A failed/denied read shows
“not shared or currently unavailable”, not “not added”. Already displayed or copied
data cannot be remotely erased. The own-account preference boolean may be cached;
other members' payment details may not.

Rollout: apply `2026-10-26-add-profile-payment-sharing.sql` (no consent backfill),
deploy API/helper/router, then release mobile. No migration or deployment was
performed during implementation. Tests: `ProfilePaymentSharingTest`,
`payment_details_privacy_test.dart`, profile and workspace widget regressions,
and auth consent transport tests. Synthetic adapters do not replace device/HTTP
rollout verification.

Validation result on 2026-10-26: all 445 PHP tests (3946 assertions) and all
521 Flutter tests pass. Static analysis reports existing warnings in unrelated
files; the changed production files introduce no new diagnostics. No archive,
version bump, deployment or live data changes were performed.
