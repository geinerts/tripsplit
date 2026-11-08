# Push notification categories

Approved by the owner on 2026-11-08. Phone (push) notifications are split into nine
categories. In-app banner preferences don't change. Expense edits and deletions don't send
push notifications.

| Category (`push.*`) | Flat key | Notification types |
|---|---|---|
| `expense_added` | `push_expense_added_enabled` | `expense_added` |
| `comments` | `push_comments_enabled` | `expense_comment_mention`, `expense_comment_added` |
| `trip_invites` | `push_trip_invites_enabled` | `trip_invitation`, `trip_added`, `trip_member_added`, `trip_member_removed` |
| `trip_status` | `push_trip_status_enabled` | `trip_finished`, `trip_ready_to_settle`, `member_ready_to_settle` |
| `payment_requests` | `push_payment_requests_enabled` | `payment_requested`, `payment_request_sent`, `payment_request_cancelled`, `payment_request_declined` |
| `payments` | `push_payments_enabled` | `payment_sent`, `payment_confirmed`, `payment_cancelled`, `payment_not_received`, `settlement_sent`, `settlement_confirmed`, `settlement_sent_cancelled`, `settlement_not_received` |
| `reminders` | `push_reminders_enabled` | `settlement_reminder`, `settlement_auto_reminder` |
| `friend_invites` | `push_friend_invites_enabled` | `friend_invite`, `friend_invite_received`, `friend_invite_accepted` |
| `location` | `push_location_enabled` | `live_location_started` |

All categories are on by default. Types that aren't in the table still send a push and
have no switch.

Before this change, settlement reminders never sent a push, and
`trip_member_removed`, `settlement_sent_cancelled` and `settlement_not_received` sent
one with no way to turn it off. Reminders now send a push when `reminders` is on.

## API

`get_notification_preferences` and `update_notification_preferences` keep their existing
fields. The `push` object gains the seven new keys above, and the matching flat keys are
accepted in updates. `location` has no older key.

The older keys stay for apps that don't know the new categories:

- `push.trip_updates` reads `true` when any of `comments`, `trip_invites` or `trip_status`
  is on. Writing it sets all three.
- `push.settlement_updates` reads `true` when any of `payment_requests`, `payments` or
  `reminders` is on. Writing it sets all three.

When a request sets both an old key and one of its new keys, the new key wins.

## New notification type: `expense_comment_added`

When someone comments on an expense, its payer gets an `expense_comment_added`
notification unless the payer wrote the comment or is mentioned in it, because a mention
already sends `expense_comment_mention`. Editing a comment sends nothing. The payload
holds `trip_id`, `expense_id`, `comment_id` and `commented_by_user_id`. The English text
is `"{name} commented on \"{note}\"."` or `"{name} commented on your expense."` when the
expense has no note. In-app banners follow the trip updates preference, as mentions do.

## New notification type: `live_location_started`

When a member starts sharing their live location in a group trip, every other active
member gets `live_location_started`. Renewing a share that is still active sends nothing,
and the same person notifies a trip at most once every 30 minutes. The payload holds
`trip_id`, `shared_by_user_id` and `minutes`. It never holds coordinates. The English text
is `"{name} started sharing their live location in \"{trip}\"."`. In-app banners follow
the trip updates preference.

## Migration

Run `sql/migrations/2026-11-08-split-push-notification-categories.sql`. It adds the six
`push_*_enabled` columns to `trip_user_notification_preferences`. When it adds a column,
it copies that user's current value from `push_trip_updates_enabled` or
`push_settlement_updates_enabled`, so nobody's existing choice changes. Running it again
does nothing.

Then run `sql/migrations/2026-11-08-add-live-location-push.sql`, which adds
`push_location_enabled`, on for everyone. Each migration works without the other.

Without the migrations the server still works. The split categories read from the old
switches, and updates to them only change the old switches. Location reads as on until
its column exists, and changes to it are ignored until then.
