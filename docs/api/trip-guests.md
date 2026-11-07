# Trip guests

Status: approved by the owner on 2026-11-07. Needs the migration below before the server is
deployed.

A guest is a person in a group trip who has no account. They are added by name, take part in
splits and balances like any member, and never sign in. Only the trip owner acts for them.

## New actions

`add_trip_guest` (POST, trip owner, active group trip)

```json
{"name": "Mamma"}
```

Returns `{"ok": true, "guest": {"id": 91, "nickname": "Mamma", "is_guest": true}}`.

`rename_trip_guest` (POST, trip owner)

```json
{"user_id": 91, "name": "Mamma Anna"}
```

Names are 1 to 32 characters, without links. Errors: 400 `Name is required.`, 400
`Name is too long.`, 403 `Only the trip owner can manage guests.`, 404 `Guest not found.`,
409 when the trip isn't active.

Guests leave a trip through the existing `remove_trip_member`, with its existing rules.

## Changed responses

Each person in a workspace snapshot's `users` adds `is_guest` (boolean).

## Expenses

`add_expense` and `update_expense` accept an optional `paid_by` (user id).

- Anyone may send their own id, which is what happens without the field.
- The trip owner may also send a guest of that trip.
- Anything else returns 403 `Only the trip owner can enter expenses for a guest.`

The owner can also edit and delete expenses paid by a guest. On `update_expense`, leaving out
`paid_by` keeps the current payer.

## Settlements and payments

The trip owner can do for a guest whatever that guest could do for themselves:
`mark_settlement_sent`, `cancel_settlement_sent`, `report_settlement_not_received`,
`confirm_settlement_received`, and the matching payment actions. `can_*` fields in responses
already reflect this, so they are true for the owner on a guest's settlements.

## What a guest doesn't get

No sign-in, push, in-app notification or email, including the trip report. They don't appear
in user search, can't be invited to other trips or added as friends, and don't count towards
"all members are ready" before settling. They aren't cleaned up as unverified accounts.
Deleting a trip removes its guests.

## Older app versions

They show a guest as an ordinary member, and can't add one or enter expenses for one. A
guest's settlements show the owner's buttons only in versions that read `can_*`, which all
current ones do.

## Migration

`sql/migrations/2026-11-07-add-trip-guests.sql` runs before the server is updated. It adds
`trip_users.guest_trip_id`, which is set only for guests.
