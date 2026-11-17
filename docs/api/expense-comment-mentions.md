# Expense comment mentions

A comment can mention active trip members with `@Name`. The comment body stays
plain text, limited to 280 characters. Mention data travels next to it, so older
clients keep working and simply show the text.

## Request

`add_expense_comment` and `update_expense_comment` accept an optional
`mentioned_user_ids: int[]`.

- The server keeps an ID only when that user is an active member of the trip and
  `@` followed by one of their names appears in the body, case-insensitively and
  not inside a longer word. Accepted names: full name, nickname, the short trip
  name the apps show (first name, or first name and last initial such as
  `Anna B.`), or the text already stored for that mention. The first name is the
  user's first name, otherwise the first word of the full name or nickname; the
  last initial comes from the last name, otherwise the last word. Any other ID is
  ignored without an error.
- On update, the list replaces the comment's mentions, so `[]` removes them all.
  When the field is absent, the stored mentions stay unchanged.

### Mentions with positions (approved 2026-11-17, not deployed)

Both actions also accept an optional `mentions: [{user_id, start, end}]`. Positions
count UTF-16 code units (as Dart and JavaScript do); the text from `start` to `end`
must be `@` followed by the name as written, 2 to 81 units long. When the field is
present, it decides the mentions: the server only checks that each user is an
active trip member and that the position really starts with `@`; the name is no
longer compared, so any spelling works. One entry per person and per position;
anything invalid is ignored without an error. `mentioned_user_ids` keeps working
unchanged for older apps, and newer apps send both, so an older server simply
ignores `mentions`. On update, sending either field replaces the mentions.

## Response

The `comment` returned by both actions and each item of `list_expense_comments`
include `mentions: [{user_id, name}]`, plus `start` and `end` when the mention
was saved with its position (older mentions have no position). `name` is the text as written in the body,
without `@`, so clients can highlight it after the member changes their name.
Treat the field as optional: it is `[]` while the table is not migrated.

## Notification

Each newly mentioned member, except the author, gets one notification of type
`expense_comment_mention`, in the app and by push.

| Field | Value |
| --- | --- |
| `title` | `You were mentioned in a comment` |
| `body` | `{name} mentioned you in a comment on "{note}".`, or `{name} mentioned you in a comment.` when the expense has no note |
| `payload` | `trip_id`, `expense_id`, `comment_id`, `mentioned_by_user_id` |

The comment text is never copied into the notification. A person is notified at
most once per comment, even if an edit removes the mention and adds it back. The
type follows the `trip_updates` preferences for in-app and push delivery.

## Storage

`trip_expense_comment_mentions` holds `comment_id`, `user_id`, `mention_text` and
`is_active`. A removed mention stays with `is_active = 0`, which is what prevents
a repeat notification. Rows are deleted with their comment or user. Migration:
`sql/migrations/2026-11-05-add-expense-comment-mentions.sql`.
`sql/migrations/2026-11-17-add-comment-mention-offsets.sql` adds nullable
`start_offset` and `end_offset`; before it runs, positions are checked but not stored.
