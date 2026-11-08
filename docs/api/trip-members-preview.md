# Trip members preview in the trips list

Approved by the owner on 2026-11-09 so the home screen can show member avatars
on the active trip card without loading the whole trip workspace.

## Change

`GET ?action=trips` (`GET /api/v1/trips` in the v1 outline) adds one field to
each trip object:

```json
"members_preview": [
  {
    "id": 7,
    "display_name": "Matīss Geinerts",
    "avatar_url": "https://…/uploads/avatars/7.jpg",
    "avatar_thumb_url": "https://…/uploads/avatars/thumbs/7.jpg"
  }
]
```

- At most **3** members per trip, in the same order as the workspace member list:
  join time, then account creation time, then user id.
- `display_name` is the full name when the user has one, otherwise the nickname.
- `avatar_url` and `avatar_thumb_url` are the avatar the person set on their profile,
  or `null` when they have none. The app then shows their initial.
- Members without an account (trip guests) are included like other members.
- `members_count` is unchanged and still counts all members, so the app shows
  `+N` for `members_count - 3` when a trip has more than three members.

## Compatibility

The field is additive. Older app versions ignore it, and new app versions treat a
missing or malformed `members_preview` as an empty list and fall back to the
member count. No existing field, action name, error format or authentication rule
changes.

## Privacy

Only fellow members of the trip receive the preview, which is the same audience
that already sees these names and avatars in the trip workspace.
