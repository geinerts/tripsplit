# Optional expense type (subcategory)

Approved by the owner on 2026-11-17 (plan section E). Local implementation; not
deployed. Run the migration and deploy only after iOS 1.0.20 has passed review.

## API

`add_expense` and `update_expense` accept an optional `subcategory`:

- A string of 1 to 40 characters after trimming and collapsing spaces, or `null`.
  Links are rejected like in notes. Anything else returns 400.
- Built-in types are sent as lowercase keys and translated by the app:
  Food: `restaurant`, `cafe`, `bar`, `fast_food`, `snacks`; Transport: `taxi`,
  `flight`, `train`, `bus`, `car_rental`, `ferry`, `public_transport`;
  Accommodation: `hotel`, `hostel`, `apartment`, `camping`.
  Any other text is a custom type typed by a member and shown as written.
  Activities and Shopping have no built-in types, only members' own ones.
- `add_expense`: omitted, empty or `null` means no type.
- `update_expense`: omitted keeps the stored type, `null` or empty removes it. When
  the category changes and `subcategory` is omitted, the stored type is removed,
  because it belonged to the old category. Old app versions never send the field,
  so editing an expense in an old version keeps its type unless the category changes.

`list_expenses`, the workspace snapshot and the add/update responses include
`subcategory` (string or `null`) on each expense. Old app versions ignore it.

## Database

`sql/migrations/2026-11-17-add-expense-subcategory.sql` adds a nullable
`trip_expenses.subcategory VARCHAR(40)`. Existing rows stay `NULL`; nothing is
removed. Before the migration the API keeps working: reads return `null` and a sent
`subcategory` is ignored without an error, so the new app works against the
current server.

## Trip types (app only)

Custom types used in a trip are suggested while typing. A custom type used in at
least 3 expenses of a trip (by any member, compared case-insensitively) is offered
in that trip's Type menu for everyone. This is computed from the trip's expenses in
the app; the server stores nothing extra.
