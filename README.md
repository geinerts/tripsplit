# Trip Split Ultra (Hostinger-Friendly)

## Web UI status (March 12, 2026)

- End-user web UI at [`index.html`](./index.html) is frozen (landing only).
- Active end-user product is Flutter app in [`mobile/`](./mobile/).
- Web remains active for admin panel at [`admin.html`](./admin.html) and legacy API at [`api/api.php`](./api/api.php).

Mobile-first PWA for one travel group:

- Shared expenses (who paid, for whom)
- Receipt/screenshot attachment for each expense
- Auto balances and settlements (who pays who)
- Random picker without repeats in cycle (all users are picked once, then cycle restarts)
- Edit/Delete expenses (owner only)
- Offline queue for mutations and auto-sync when internet is back
- "Live" updates via short polling (no incoming WebSocket requirement)
- Minimal admin panel for user management and user-level stats
- Expense split modes: `equal`, `exact`, `percent`, `shares` across selected participants

## 1) Database setup

1. You can use an existing MySQL database.
2. Open phpMyAdmin for that database.
3. Import [`sql/schema.sql`](./sql/schema.sql).
4. Tables are prefixed with `trip_` so they do not conflict with existing app tables.

If tables already exist, run incremental migrations from [`sql/migrations/`](./sql/migrations) in date order (oldest to newest).

## 2) Backend setup

1. Copy [`.env.example`](./.env.example) to `.env`.
2. Fill real values in `.env`:
   - `TRIP_DB_NAME`
   - `TRIP_DB_USER`
   - `TRIP_DB_PASS`
   - `TRIP_ADMIN_KEY` (strong random secret for admin panel)
   - optional limits for rate-limit and upload quotas
3. Upload project files to `public_html` (or your target subdirectory).
4. Upload `.env` to project root (`.../trip/.env`) or `api/.env`.
5. Ensure directories `uploads/receipts` and `uploads/avatars` exist and are writable by PHP process.
6. Place Verot `class.upload.php` at `api/lib/verot/class.upload.php` (or change `TRIP_CLASS_UPLOAD_REL_PATH`).

## 3) Run

1. Open your domain over HTTPS.
2. Enter nickname on first launch.
3. Install to home screen from browser install prompt.
4. Admin panel is available at `/admin.html`.

## API actions

`register_proof`, `register`, `login`, `set_credentials`, `me`, `update_profile`, `users`, `search_users`, `friends_list`, `send_friend_invite`, `respond_friend_invite`, `cancel_friend_invite`, `remove_friend`, `upload_receipt`, `upload_avatar`, `remove_avatar`, `add_expense`, `update_expense`, `delete_expense`, `list_expenses`, `balances`, `end_trip`, `mark_settlement_sent`, `confirm_settlement_received`, `list_notifications`, `mark_notifications_read`, `generate_order`, `list_orders`, `admin_summary`, `admin_users`, `admin_user_detail`, `admin_delete_expense`, `admin_update_user`, `admin_delete_user`

## Notes about realtime on Hostinger shared hosting

- Shared hosting typically does not support inbound WebSocket servers.
- This project uses polling every ~3.2s for instant-enough shared updates.
- If you need true socket backend, use VPS or external realtime service.
