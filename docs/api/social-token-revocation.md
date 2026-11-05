# Provider token revocation on account deletion

Added 2026-11-05. Apple requires apps offering Sign in with Apple to revoke the
user's tokens when an account is deleted. The same flow covers Google.

## Contract change

`social_auth` accepts one new optional request field:

| Field | Type | Meaning |
| --- | --- | --- |
| `authorization_code` | string, at most 4096 characters | One-time code from the provider SDK: Apple `authorizationCode`, Google `serverAuthCode`. |

The field never changes the response or the login result. Older apps omit it and
keep working. The deletion endpoints and their email confirmation are unchanged.

## Behaviour

1. After a successful login, if no token is stored for that identity, the server
   exchanges the code for a provider refresh token and stores it encrypted with
   AES-256-GCM in `user_identities.provider_token_enc`, with the client ID it
   belongs to. An exchange failure is logged without details and login succeeds.
2. `confirm_account_deletion` reads the stored tokens in its transaction and deletes
   them with the identity rows. After the commit it revokes each one at the provider.
3. A failed revocation never blocks or undoes deletion. It is logged with the
   provider name and HTTP status only, and it is not retried.

Tokens and codes are never returned, logged or sent anywhere but the provider.

## Configuration (`/etc/splyto/splyto.env`)

| Variable | Used for |
| --- | --- |
| `TRIP_SOCIAL_TOKEN_ENCRYPTION_KEY` | At least 32 characters. Without it nothing is stored. |
| `TRIP_SOCIAL_APPLE_TEAM_ID`, `TRIP_SOCIAL_APPLE_KEY_ID` | Apple client secret JWT. |
| `TRIP_SOCIAL_APPLE_PRIVATE_KEY_PATH` | Absolute path to a `.p8` key with Sign in with Apple enabled. |
| `TRIP_GOOGLE_WEB_CLIENT_ID`, `TRIP_GOOGLE_WEB_CLIENT_SECRET` | Google code exchange. |

Missing configuration switches the matching provider off without affecting login or
deletion. Changing the encryption key makes stored tokens unreadable, so they could
no longer be revoked; there is no re-encryption tool.

Run `sql/migrations/2026-11-05-add-social-provider-token.sql` before relying on this.
Until then the column is absent and the feature is off.

## Limits

- Accounts that signed in before this change have no stored token until their next
  login with an updated app. Their deletion completes without revocation.
- Google returns a refresh token only on first consent, unless the app forces a new
  consent screen, which it does not. A Google user who consented earlier may never
  get a stored token. Those users can remove access in their Google account.
- Verified with synthetic provider responses only. No real Apple or Google exchange
  or revocation has been run. Do that on a test account after configuring production.
