# Quick splits

Status: approved by the owner on 2026-11-17. Needs the migration below before the server
is deployed.

A quick split is one bill split between people without a trip: who paid, what each had, and
each person's amount. It is a record only. There are no balances, payment requests or "I paid"
steps; the bill is assumed settled on the spot.

It is stored on the server and shared with everyone in it who has a Splyto account. People
without an account are added by name for that quick split only. Only the person who created
it can change or delete it.

## People

Every request that saves a quick split sends the whole list of `people`. Each person is one of:

```json
{"key": "me", "user_id": 12}
{"key": "f1", "user_id": 57}
{"key": "n1", "name": "Mamma"}
```

- `key` is any text of 1 to 16 characters, unique in the request. `paid_by`, `participants`,
  `splits[].person` and `items[].people` refer to people by `key`. Keys are not stored.
- A person with `user_id` is a Splyto account. It must be the creator or one of the creator's
  accepted friends.
- A person with `name` has no account. Names are 1 to 32 characters, without links, like trip
  guests. They get no account, sign-in, notification or push.
- The creator must be one of the people. 2 to 50 people, each account at most once.

Errors (400): `Add at least two people.`, `Too many people.`, `Each person needs a key.`,
`People keys must be unique.`, `Name is required.`, `Name is too long.`,
`You must be part of the quick split.`, `Unknown person.`; 403 `You can only add friends.`

## New actions

All are `POST` with a JSON body, for a signed-in account, and use the existing
`expense_write_*` rate limits for writes.

### `add_quick_split`

```json
{"client_mutation_id": "a1b2c3", "amount": 84, "currency_code": "EUR",
 "note": "Dinner at Lido", "category": "food", "subcategory": "restaurant",
 "date": "2026-11-16", "paid_by": "me",
 "people": [{"key": "me", "user_id": 12}, {"key": "v", "user_id": 57}, {"key": "a", "name": "Andris"}],
 "split_mode": "equal", "participants": ["me", "v", "a"]}
```

| Field | Rules |
| --- | --- |
| `amount`, `currency_code` | As in `add_expense`. No conversion: the quick split stays in its own currency. |
| `note` | Optional, up to 255 characters, without links. Shown as the title. |
| `category`, `subcategory` | As in `add_expense`, including own types. |
| `date` | `YYYY-MM-DD`, today when left out. |
| `receipt_path` | Optional receipt photo, uploaded first with the existing `upload_receipt`. Same rules as `add_expense`: it must be uploaded by the caller. |
| `paid_by` | A person `key`. Any person may be the payer. |
| `split_mode` | `equal`, `exact`, `percent`, `shares`, `adjustment` or `itemized`, with the same rules and errors as `add_expense`. |
| `participants` | Person keys for every mode except `itemized`. Everyone when left out. |
| `splits` | `[{"person": "v", "value": 30}]`, same meaning as `add_expense` `splits`. |
| `items`, `extra_amount` | For `itemized`: `[{"name": "Pizza", "amount": 12, "people": ["me", "v"]}]`, same rules as `add_expense`. |
| `client_mutation_id` | Optional, up to 96 characters. Sending the same one again returns the first response and saves nothing new. |

Returns `{"ok": true, "quick_split": {...}}` with the full object described under
`get_quick_split`.

Every account in it except the creator gets a `quick_split_added` notification.

### `update_quick_split`

The same body as `add_quick_split` plus `"id": 31`. It replaces the whole quick split,
including its people. Accounts that were not in it before get `quick_split_added`; nobody else
is notified. Errors: 403 `Only the creator can change this quick split.`, 404
`Quick split not found.`, 409 `This quick split was added to a trip.`

### `delete_quick_split`

`{"id": 31}` → `{"ok": true}`. It disappears for everyone, and its receipt photo is deleted.
Same 403/404 errors as update. When `update_quick_split` replaces or removes the receipt, the
old photo is deleted too.

### `list_quick_splits`

`{"limit": 30, "cursor": null}` → newest date first, then newest saved first. Lists every
quick split the account created or is a person in, except those added to a trip.

```json
{"ok": true, "items": [{
  "id": 31, "note": "Dinner at Lido", "category": "food", "subcategory": "restaurant",
  "date": "2026-11-16", "amount": 84.0, "currency_code": "EUR",
  "people_count": 4, "my_amount": 21.0, "paid_by_me": true, "paid_by_name": "Matiss",
  "people_preview": [{"name": "Valērija", "avatar_thumb_url": "..."}],
  "can_edit": true, "created_at": "2026-11-16 20:14:03", "updated_at": "2026-11-16 20:14:03"
}], "has_more": false, "next_cursor": null}
```

`limit` is 1 to 100 (30 by default). `people_preview` holds up to 4 people other than the
viewer. `my_amount` is the viewer's part (0 when they only paid).

### `get_quick_split`

`{"id": 31}` → `{"ok": true, "quick_split": {...}}`. Everything from the list row, plus:

```json
{"split_mode": "itemized", "created_by": 12,
 "people": [{"id": 401, "user_id": 12, "name": "Matiss", "avatar_thumb_url": null,
             "is_me": true, "is_payer": true, "is_account": true,
             "amount": 21.0, "split_value": 0}],
 "items": [{"name": "Pizza", "amount": 12.0, "person_ids": [401, 402]}],
 "extra_amount": 3.0,
 "receipt_url": "https://...", "receipt_thumb_url": "https://...",
 "added_to_trip": null}
```

- `people[].id` is the stored person id, used by `items[].person_ids`. When saving again, the
  app sends `key: "401"` and so on.
- `name` for an account is its current nickname, and for a deleted account the name saved
  with the quick split.
- `items` and `extra_amount` are present only for `itemized`. `split_value` has the same
  meaning as in expenses.
- `receipt_url` and `receipt_thumb_url` are `null` without a receipt. The creator also gets
  `receipt_path`, to send back unchanged when saving again; others get `null`. The list rows add
  `has_receipt` (boolean).
- `added_to_trip` is `{"trip_id": 7, "expense_id": 950}` after it was added to a trip, else
  `null`.

404 `Quick split not found.` when it doesn't exist or the account isn't in it.

### `move_quick_split_to_trip`

"Add to a trip" is done by the app in two steps:

1. It calls the existing `add_expense` for the chosen trip with the quick split's amount,
   currency, note, category, type, date, payer, split and `receipt_path`, so trip rules apply unchanged
   (trip members only, guests through the trip owner, currency conversion, notifications).
   The app offers only trips that fit (owner decision 2026-11-20): the user created and paid
   the quick split, every person in it has an account and is a member of the trip (the trip
   may have more people), and the trip is active. Nobody is dropped or re-split. The same
   rule lists quick splits under "From a quick split" in a new trip expense.
2. It calls `move_quick_split_to_trip` with `{"id": 31, "trip_id": 7, "expense_id": 950}`.

The server checks that the caller created the quick split, is a member of the trip and that
the expense belongs to that trip. Then it records the trip and expense, and the quick split
leaves everyone's list. The receipt photo now belongs to the trip expense and is not
deleted with the quick split. Returns `{"ok": true}`. Errors: 403, 404 as above, 404
`Expense not found.`, 409 `This quick split was added to a trip.`

### Trip expenses added from a quick split

Approved by the owner on 2026-11-20 (additive). Each expense in `list_expenses` adds
`from_quick_split` (boolean): true when a quick split was moved to this trip as that expense
(`moved_trip_id` and `moved_expense_id`). The app shows a small ⚡ after the title in the list
and in the details, for every member. Older servers don't send it; the app treats that as false.

## Notification

New type `quick_split_added`, sent to accounts only, never to people added by name.

- Not tied to a trip: `trip_id` is null, like friend notifications.
- Title `Quick split`; body `Matiss added you to a quick split: Dinner at Lido` or, without a
  note, `Matiss added you to a quick split of EUR 84.00`.
- Payload `{"quick_split_id": 31}`.
- Push and in-app use the existing "New expenses" switches (`push.expense_added`,
  `in_app.expense_added`). No new preference fields.
- The push text is translated with the other push texts (16 languages).

## Older app versions

They don't call the new actions and don't show the tab. A `quick_split_added` notification
appears in their inbox with the English text from the server, and tapping it does nothing
because it has no trip. Trips, expenses, balances and every existing response are unchanged.

## Share links

The creator can share a link that anyone can open in a browser (`share_quick_split`,
`revoke_quick_split_share`, and `share` in `get_quick_split`). See
[quick-split-share-links.md](quick-split-share-links.md).

## Account deletion

Deleting the creator's account deletes their quick splits and their share links. Deleting another person's account
keeps the quick split and shows the name saved with it.

## Migration

`sql/migrations/2026-11-17-add-quick-splits.sql` runs before the server is updated. It adds:

- `trip_quick_splits`: one row per quick split, with creator, amount, currency, note,
  category, type, date, receipt photo, split mode, payer, client mutation id and the trip it was added to.
- `trip_quick_split_people`: the people, each with an optional account, a saved name, the
  amount and `split_value`.
- `trip_quick_split_items` and `trip_quick_split_item_people`: the `itemized` lines, like the
  expense item tables.
