# Request-scoped payment details

## Contract

Friendship and trip membership do not grant access to payment profiles. Both
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
