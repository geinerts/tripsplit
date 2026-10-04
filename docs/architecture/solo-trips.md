# Personal trips (phase 1)

`trip_mode` is explicit: `group` (the default, including all existing trips)
or `solo`. Member count never determines the mode.

Personal trips have only their creator as a member. The mobile creation form
hides friend selection in solo mode and clears selected friends on switching
to solo. The expense form keeps amount, currency, category, date, note and
receipt; it submits an explicit owner participant with an equal split.
The mode is retained in the account-isolated trip cache for offline use.

The API rejects other participants/custom splits for personal expenses, and
blocks adding members, creating invites, previewing invites and joining a
personal trip. Existing group trip behavior is unchanged.

## Rollout

1. Apply `sql/migrations/2026-10-04-add-trip-mode.sql` once to the target DB
   (adjust the `trip_` prefix if the environment uses a custom table prefix).
2. Deploy the changed API helper, trip/expense actions and action router together.
3. Release the mobile app. Solo creation uses `create_solo_trip` so an old server
   returns an error instead of ignoring the new field and creating a group.
4. Verify both modes, solo expense create/edit/offline sync and blocked invites
   in the deployed environment before distributing the mobile build.

This change does not deploy or migrate production automatically.

## Deliberate boundary

Mode changes on existing trips are not supported in phase 1. In particular,
inviting somebody must never publish the owner's previous personal expenses.
A later solo-to-group workflow requires private-expense authorization across
lists, receipts, activity, balances and statistics, or an explicitly separate
new group trip. No analytics duplication, budget feature or subscription limit
is introduced here.
