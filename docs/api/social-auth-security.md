# Social identity boundary

Local implementation: 2026-10-04. SEC-04 is IN_PROGRESS; no production rollout.

## Login contract

- Production JWT verification checks the accepted provider, signing key, signature,
  issuer, audience, timestamps and subject before account selection.
- A previously linked `(provider, subject)` authenticates only that linked user. The
  subject must match exactly, including case, even on the legacy case-insensitive index.
- Returning users do not need a newly supplied email claim. Missing, changed or unverified
  provider email must not overwrite or verify the Splyto contact email. Existing unverified
  contact state remains unverified; this handler is not a replacement for verification gates.
- An unlinked identity can create a new account only with a verified provider email.
  Client-supplied email is not identity proof.
- Matching an existing email NEVER implicitly links or merges accounts, even when the
  provider verifies that email. Sign in using the existing method instead. Explicit linking
  after fresh ownership proof is still to be implemented.
- Inactive linked users cannot sign in. Conflicting writes roll back; integrity conflicts
  and serialization/deadlock errors receive a conflict response rather than partial linkage.

Errors (HTTP 409, without a new auth payload):

| Code | Meaning |
| --- | --- |
| `SOCIAL_LINK_REQUIRED` | Existing email owner; use the existing sign-in method. |
| `SOCIAL_VERIFIED_EMAIL_REQUIRED` | New social identity lacks a verified provider email. |
| `SOCIAL_IDENTITY_CONFLICT` | Legacy collation matched a different exact subject. |
| `SOCIAL_AUTH_RETRY` | Concurrent/integrity conflict; transaction rolled back. |

Invalid tokens retain HTTP 401. An inactive account retains HTTP 403. The Flutter client
has not gained dedicated localized handling for these new codes in this batch.

## Migration and compatibility

`sql/migrations/2026-10-04-social-identity-subject-case.sql` changes only the subject
column's collation to `ascii_bin`, preserving the provider-subject unique index and rows.
New schemas use the same collation. Deploy through the normal reviewed migration process;
the runtime exact-match guard already protects legacy indexes pending migration.

Existing email/password users who have never linked a provider cannot use a matching-email
Google/Apple login to attach it automatically anymore. Existing provider links are retained,
not audited or repaired retroactively. Password reset and Apple private-relay delivery still
need their own end-to-end validation before rollout.

## Evidence and limits

- `SocialIdentitySecurityTest`: 48 tests / 618 assertions on SQLite and isolated MySQL.
  Cases cover both providers, verified=false/missing claims, client email substitution,
  incorrect signature/algorithm/issuer/audience, expiry/future issue time, subject conflicts,
  returning users, contact email invariants, new accounts and inactive accounts.
- Ephemeral RSA keys sign synthetic tokens. Only external JWKS retrieval is replaced;
  production JWT validation runs. No provider credentials, real email, user data or VPS access.
- MySQL fixtures deliberately retain the legacy case-insensitive collation for handler tests.
  The integration runner then applies the actual migration twice, checks row preservation,
  case-sensitive lookups and unique-index enforcement in the disposable test database.
  All these migration checks passed on MySQL 8.4.11; no production migration was executed.
- Minimal fixture schema has no full application foreign-key graph. HTTP transport, rate
  limits, mail and profile extras are test adapters. This is not a deployed HTTP or device test.
- No social concurrency suite, external JWKS outage/rotation test, real Apple/Google login,
  full profile verification flow or production migration has been performed in this batch.

## Remaining work, not implemented

Owner decision after this initial work: defer new provider linking/native step-up beyond
the first beta. Use password proof or operation-bound verified email confirmation for
sensitive actions instead. The password setup/recovery slice is now implemented locally;
see `password-recovery-security.md`. Email changes have since been removed, and deactivation
now requires password or email proof; see `account-deactivation-security.md`.
The list below records design concerns, not a requirement to ship every provider feature.

1. Durable password capability: social accounts currently contain a random placeholder
   password hash. Its presence does not prove that the user has a Splyto password; linked
   accounts may also have a real password. Preserve legacy mixed accounts during migration.
2. Explicit provider linking (deferred) and fresh, purpose-bound proof before changing credentials or
   sensitive lifecycle settings. Bind proof to account/session/provider subject/operation,
   enforce expiry and atomic single use, test cancellation and wrong-account selection.
3. The deactivation exemption is removed locally. Review deletion/reactivation proof
   handling and test the coordinated lifecycle before declaring this boundary complete.
4. Separate native UI for password-based vs social-only accounts, optional password setup,
   localized recovery, and end-to-end Apple/Google testing. Normal social login is not a
   step-up method: it must not switch the current account during a sensitive action.
5. SEC-05 recovery throttling, token atomicity, session revocation policy and race tests.

Do not accept recent ID-token issuance alone as evidence of fresh user interaction. The
current Google sign-in integration has no per-operation nonce. A SDK upgrade by itself is
not sufficient: Google's Flutter plugin documents initialize-once semantics, with nonce on
initialization, not on each authenticate call. Design and validate the challenge flow before
claiming provider reauthentication support.

References: [Google OIDC](https://developers.google.com/identity/openid-connect/openid-connect),
[Flutter Google initialize](https://pub.dev/documentation/google_sign_in/latest/google_sign_in/GoogleSignIn/initialize.html),
[Flutter Google authenticate](https://pub.dev/documentation/google_sign_in/latest/google_sign_in/GoogleSignIn/authenticate.html).
