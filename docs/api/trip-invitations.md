# Trip invitation contract

## Membership boundary

`trip_members` contains accepted members only. Creating a group trip inserts its
creator as owner; any other selected IDs receive personal invitations, not
membership. `add_trip_members` now sends invitations. `invited_count` is the number
of new invitations; the legacy `added_count` aliases that count for old clients.
`members_count` always counts actual members. Existing memberships are preserved;
this migration does not retroactively remove people from existing trips.

Personal invitations use `trip_invites.target_user_id`. NULL means a shareable
link. A personal invitation is bound to its authenticated recipient, is omitted
from public share previews, and expires after 14 days. Deleting the recipient
cascades the invitation rather than converting it into a public link.

## API and client

- `POST preview_trip_invite {invite_token}` returns minimal trip/inviter metadata,
  `is_directed`, and a recipient-bound, short-lived confirmation nonce.
- `POST join_trip_invite {invite_token, preview_nonce}` explicitly accepts and
  atomically creates membership. A personal invitation becomes consumed
  (`response=accepted`, `revoked_at` set); neither another recipient nor a replay
  can use it. Public links retain their existing sharing behavior.
- `POST decline_trip_invite {invite_token}` is recipient-only and personal-only.
  It consumes the invitation with `response=declined`, without granting access.
- `GET list_pending_trip_invitations` with `X-Trip-Id` is owner/admin-only. It
  returns ID, recipient ID, display nickname and expiry, never invitation tokens
  or payment profiles. At most 100 live personal invitations are allowed per trip.
- `POST revoke_trip_invitation {invitation_id}` with `X-Trip-Id` is owner/admin-only
  and only affects an unconsumed invitation in that trip. It cannot undo an
  accepted membership; member removal is a separate operation.

The mobile global inbox handles `trip_invitation` notifications and displays
Accept/Decline. Closing the dialog does neither. Errors are not treated as
successful acceptance/decline. The invite-members dialog shows pending recipients
and supports cancellation, loading and retry states. Notifications respect trip
push/banner preferences; the inbox record is retained even when push is disabled.
Invitation operations are online-only and account-generation guarded.

## Removal and concurrency

All membership/invitation mutations use the trip row as their first shared lock.
Acceptance rechecks the invitation, nonce and membership under locks. Removal,
leaving and role changes also recheck current authorization inside the transaction.
Expense creation/editing revalidates current membership and participants under
the same trip lock. Financial history (including payments) prevents removal or
leaving under the existing accounting policy.

Removing/leaving revokes old public links, personal invitations for that user,
and invitations issued by the departing user. Other recipients' personal
invitations remain valid. Rejoining requires a fresh valid invitation and explicit
acceptance. Revoking a public link affects everyone holding that old link, so an
owner/admin must generate a new link for subsequent sharing.

## Rollout and verification

1. Apply `2026-10-05-add-directed-trip-invitations.sql` through the migration runner.
2. Deploy backend including `trip_invitations.php`, router and share-preview change.
3. Ship the matching mobile build and verify with two synthetic accounts on devices:
   create, receive, accept, decline, cancel, leave/remove and reinvite.

Missing schema fails closed; there is no fallback that automatically joins people.
Older clients do not understand the new inbox action, so coordinate the rollout
with the mobile build. Do not roll back to auto-joining code once personal
invitations are issued. Store/push-provider end-to-end delivery is a release gate,
not something proven by local unit tests.

The matching mobile candidate is 1.0.12 (202610052). A backend-first maintenance
rollout is allowed only while testing is paused; distribute the matching client
before resuming testing. Existing members remain members. An old client receiving
a new personal invitation cannot complete the inbox flow and must be updated.

Tests cover real handlers/SQL on SQLite and isolated MySQL, permissions and replay,
cross-recipient use, expired/closed invitations, transactional notification failure,
owner/admin management, financial removal constraints and concurrent decisions.
Pending and removed users fail the shared workspace/expense/activity/user access
boundary; the workspace also supplies statistics and receipt URLs.
The synthetic runtime-flow scenario additionally verifies the real global inbox
query and create/accept/remove/reinvite/decline/cancel operations under a MySQL
account with only SELECT, INSERT, UPDATE and DELETE privileges.

Existing receipt URLs are short-lived bearer links (default 900 seconds, configured
up to 3600). Already issued links and downloaded/cached data are not erased by
membership removal. Instant media revocation needs a separate actor/membership-bound
media policy; this change must not be described as remotely erasing prior access.
