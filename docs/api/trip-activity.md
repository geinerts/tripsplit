# Trip activity feed

`GET list_trip_activity` returns a group trip's events from `app_events`, newest
first. The response shape is `events[]` with `event_type`, `actor_*`,
`entity_type`, `entity_id`, `payload`, `created_at`, plus `pagination`. Clients
must render an unknown `event_type` with a generic fallback and treat every
payload key as optional, because rows written before a key existed do not have it.

## Event types

| `event_type` | Written when | Payload |
| --- | --- | --- |
| `expense.created`, `expense.updated` | Expense saved | `amount_cents`, `trip_currency_code`, `expense_currency_code`, `source_amount_cents`, `category`, `split_mode`, `participants_count`, `note`; `receipt_changed` on update |
| `expense.deleted` | Expense deleted | As above without `participants_count`, `receipt_changed` |
| `expense.comment_added` | Comment or reply posted | `comment_id`, `note` (the expense's note, never the comment text) |
| `trip.created` | Trip created | See handler |
| `trip.updated` | Trip details actually changed. A save with no changes writes nothing. | `name_changed`, `currency_changed`, `image_changed`, `budget_changed`, `destinations_changed` (booleans only, no values) |
| `trip.members_added` | Legacy rows only | `members_added_count` |
| `trip.members_invited` | Invitations sent | `members_invited_count` |
| `trip.member_joined`, `trip.invitation_declined`, `trip.invitation_revoked` | Invitation lifecycle | None |
| `trip.member_removed` | Member removed | `removed_user_id`, `removed_user_name` |
| `trip.member_left` | Member left | `left_user_id`, `left_user_name` |
| `trip.member_role_updated` | Role changed | `target_user_id`, `target_user_name`, `role` |
| `trip.member_ready`, `trip.member_not_ready` | Ready state changed | `is_ready`, `all_ready` |
| `trip.all_members_ready` | The last member became ready | None |
| `trip.finished` | Trip finished | `status`, `settlements_count` |
| `trip.settled` | The last open transfer was confirmed and the trip was archived | None |
| `settlement.marked_sent`, `settlement.sent_cancelled`, `settlement.not_received`, `settlement.confirmed` | Settlement transfer state changed | `from_user_id`, `to_user_id`, `amount_cents`; `all_settled` on confirm |
| `payment.*` | Payment or payment request state changed | `payment_id`, `from_user_id`, `to_user_id`, `amount_cents`; `status` on create |

## Deliberately not in the feed

- `settlement.reminder_sent` is recorded but filtered out: a reminder is a nudge
  between two members, not something the whole group needs to see.
- `trip.deleted` has no `trip_id`, because the feed is gone with the trip.
- Comment edits and deletions, reactions, and invite-link generation are not
  recorded here. They would add noise without changing anything for the group.
- Live location, travel map data, payment details, and profile or account
  changes never appear here, because they are private to a member.

## Privacy

`note` repeats a value already visible to every trip member. Comment text is not
copied into the payload.
