# Quick split share links

Status: approved by the owner on 2026-11-28 (phase 1). Needs the migration below before the
server is deployed.
Mockups: `output/design/quick-split-share/` (`chat-quick-start.png`, `page-app-style.png`,
`page-items.png`, `items-switcher.png`, `receipt-view.png`, `og-quick-start.png`).

Sharing a quick split now sends plain text. Instead, the app shares a link that anyone can
open in a browser, with or without the app: the bill, who paid, each person's part, the
items (with a switch between people), the receipt photo if the sharer allows it, and a link
to get SPLYTO. Chat apps show a rich preview card.

## Phases

1. **This proposal.** Share link, public page, preview image, optional receipt, person
   switcher, "Get the app".
2. Payment buttons (Revolut, PayPal, IBAN copy), only with the sharer's explicit consent,
   following `payment-details-privacy.md`. Separate proposal.
3. Personal links sent to each person from the app. The page already supports them (`p`).

## Who can share

Only the creator of the quick split (they chose who is in it and own the receipt). One active
link per quick split; sharing again returns the same link.

## New actions (signed-in, `POST`, JSON)

### `share_quick_split`

```json
{"id": 31, "show_receipt": false}
```

Returns the active link, creating it when there is none:

```json
{"ok": true, "share": {"url": "https://splyto.eu/split?code=Kq3vT8mW1pZx7RbN2cYd4A",
  "expires_at": "2027-02-26T12:00:00Z", "show_receipt": false}}
```

- `show_receipt` is `false` unless the literal `true` is sent. Sending it again changes it on
  the existing link. Without a receipt it is always `false`.
- The link lasts **90 days** from when it was made. Sharing again after it expired makes a new
  one.
- Errors: 403 `Only the creator can share this quick split.`, 404 `Quick split not found.`,
  409 `This quick split was added to a trip.` Rate limit: the existing `expense_write_*` limits.

### `revoke_quick_split_share`

`{"id": 31}` → `{"ok": true}`. The link stops working at once. Same 403/404 as above.

### `get_quick_split` (additive)

For the creator only, adds `"share": {"url", "expires_at", "show_receipt"}` or `null`. Others
get no `share` field. Older apps ignore it.

## Public page: `GET https://splyto.eu/split?code={token}`

Served like `/invite` (`split.php` at the site root), so no Nginx change is needed.

- Optional `?p={person id}` only chooses which person the switcher shows first ("You"). It
  grants nothing: every part is visible under "Everyone" anyway.
- Shows: title (note, or category name), date, category, total and currency, who paid, each
  person's name and amount, and for "by item" splits the items with who had them (shared
  items as a fraction). Person switcher: each person, then "Everyone"; without `p`, "Everyone".
- Names are the account's current nickname or the name saved with the quick split. **No
  avatars, emails, user ids or profile links**; people are shown with initials.
- Receipt: a "Receipt · View" row only when `show_receipt` is true; the photo opens full
  screen from a short-lived signed address (`api/receipt-media.php`, as in the app), made
  only when the page loads with a valid link.
- "Get the app" with App Store and Google Play links. No "Open in SPLYTO": the app has no
  screen for a link like this yet, and `/split` is not an app link, so it always opens in the
  browser. The page needs no JavaScript (the person switcher is plain links, the receipt
  opens with `#receipt`).
- Language from `Accept-Language`, all 16 app languages, like the invite page.
- Not found, revoked, expired, deleted, or added to a trip: one neutral page "This bill is no
  longer shared" with no details and the same status (404), so a token can't be probed.
- Headers like the invite page: `noindex, nofollow`, `Cache-Control: no-store`,
  `Referrer-Policy: no-referrer`, the site CSP (no inline styles, no third-party scripts).
- Rate limit per IP on the page and image: `quick_split_share_view`, 120 per 10 minutes. The
  receipt uses the existing signed media address and its own checks.

### Preview image: `GET /share-image.php?type=quick_split&code={token}`

1200 × 630 JPEG in the Quick Start colours (mint to cream, ribbons, ink text), with the
SPLYTO logo, title, total, date and up to 3 people with their amounts (`+N` for more); no
other words, so it needs no language. The main text stays in the central square that small
WhatsApp cards show. Sent with `Cache-Control: no-store`. Invalid links get the generic card.
Open Graph (in the page's language): title `Matiss shared a bill: €35.09`, description
`See your share`.

## Storage

Migration `sql/migrations/2026-11-28-quick-split-shares.sql` (runs before the server update):

`trip_quick_split_shares`: `id`, `quick_split_id` (FK, cascade on delete), `token_salt`
(random), `token_hash` (SHA-256 of the token, unique), `show_receipt`, `created_by`,
`created_at`, `expires_at`, `revoked_at`.

The token is 22 URL-safe characters (16 bytes), made from `token_salt` with a server key, so
the same link can be shown again but the database alone can't rebuild one. Deleting the quick
split, deleting the creator's account, or moving it to a trip ends the link (cascade or the
moved check).

## App

- Share on a quick split: calls `share_quick_split` and shares `"{title} · {total}\n{url}"`
  through the system share sheet. With a receipt, a switch "Include the receipt photo"
  (off by default) first. Offline or on error: the current plain text, as now.
- Under Share, the creator sees "Shared by link until {date} · Stop sharing" while a link
  works. People in the quick split who didn't create it share the plain text, as before.
- New texts in all 16 languages.

## Privacy and policy

Anyone with the link sees the names and amounts in that bill, and the receipt if allowed.
That needs a short addition to the privacy policy (what a share link shows, 90 days, how to
stop it) and the terms. No new data from the device. Store data safety answers don't change.

## Not changed

Existing actions, responses, notifications and the text share for older apps.
