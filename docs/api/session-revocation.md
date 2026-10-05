# Session revocation

Access tokens contain a signed `sid` identifying their refresh-token row. Each
authentication validates the row's owner, expiry and revocation state. Tokens
without `sid` fail closed. The public response shape and mobile storage format
are unchanged; existing clients can exchange a still-valid refresh token.

## Security events

- Password reset, password change, credential enrollment, deactivation, deletion
  and reactivation revoke the existing refresh rows, invalidating their access
  tokens as well. Reactivation never resurrects these rows.
- Password change issues a replacement session inside the same transaction.
- Logout invalidates access bound to the submitted refresh row. Session-limit
  eviction also invalidates access belonging to the evicted row.
- Refresh rotates the row and invalidates the preceding access token. Mobile
  clients already serialize refresh and retry an unauthorized request.
- Authenticated credential changes recheck the session after locking the user,
  rejecting a request admitted before a concurrent security event.

## Transaction ordering

Password login verifies credentials again under the user lock, and creates its
session before releasing that lock. Apple/Google sign-in locks the user before
rechecking the linked identity and issues its session before committing.
Refresh first discovers the owner, locks the user, then locks and revalidates
the refresh row. Credential and lifecycle mutations use the same user-first
ordering. Refresh cleanup is scoped to that user to avoid cross-account locks.

If login/refresh wins the race, a subsequent security event revokes the newly
created row. If the security event wins, old credentials/refresh cannot create
a replacement session. A genuinely new Apple/Google authentication after a
password reset remains valid; the provider is an independent sign-in method.

## Release and validation

No schema migration or secret rotation is required. Deploy the token helper and
all auth callers together; do not roll back to code accepting unbound tokens.
Unauthenticated users and invalidated refresh sessions must sign in again.
Missing/unreadable session storage denies access rather than trusting a token.

Tests cover reset, deactivation/reactivation, password change, logout, rotation,
replay, expiry, wrong owner, legacy-token refresh and session-limit eviction.
The isolated MySQL suite races password login and refresh against real reset
and deactivation handlers. No production user is changed by these tests.

This does not retroactively cancel requests that already passed authorization,
erase offline data on an unreachable device, or revoke independent provider
sessions. Endpoint-specific transaction authorization, shared-data retention and
real-device/provider end-to-end checks remain separate release concerns.
