# Trip Split Ultra (nano.lv-Friendly)

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
   - if using email verification on signup (recommended):
     - `TRIP_EMAIL_VERIFICATION_REQUIRED=true`
     - `TRIP_EMAIL_VERIFICATION_TOKEN_TTL_SEC` (default 86400, 24h link)
     - `TRIP_EMAIL_VERIFICATION_GRACE_DAYS` (default 7, auto-deactivate if still unverified)
     - `TRIP_EMAIL_VERIFICATION_CLEANUP_BATCH_LIMIT` (default 300)
   - if using push:
     - `TRIP_PUSH_ENABLED=true`
     - FCM for Android + iOS + Web (recommended HTTP v1):
       - `TRIP_PUSH_FCM_PROJECT_ID` (optional if present in service account JSON)
       - `TRIP_PUSH_FCM_SERVICE_ACCOUNT_REL_PATH` (e.g. `keys/firebase-service-account.json`)
     - FCM legacy (optional fallback only):
       - `TRIP_PUSH_FCM_SERVER_KEY`
     - `TRIP_PUSH_CRITICAL_TYPES` (comma-separated push allowlist; in-app notifications are still saved for all types)
   - if using auto settlement reminders:
     - `TRIP_SETTLEMENT_REMINDER_ENABLED=true`
     - `TRIP_SETTLEMENT_REMINDER_INTERVAL_MIN` (default 720)
     - `TRIP_SETTLEMENT_REMINDER_MIN_AGE_MIN` (default 180)
     - `TRIP_SETTLEMENT_MANUAL_REMINDER_COOLDOWN_MIN` (default 15)
   - optional limits for rate-limit and upload quotas
3. Upload project files to `public_html` (or your target subdirectory).
4. Upload `.env` to project root (`.../trip/.env`) or `api/.env`.
5. Ensure directories `uploads/receipts`, `uploads/avatars`, `uploads/trips`, `uploads/feedback` exist and are writable by PHP process.
6. Place Verot `class.upload.php` at `api/lib/verot/class.upload.php` (or change `TRIP_CLASS_UPLOAD_REL_PATH`).

### Cron jobs (recommended)

Run every 5 minutes:

```bash
php /home/<user>/public_html/projekti/trip/scripts/run_settlement_reminders.php
php /home/<user>/public_html/projekti/trip/scripts/run_push_delivery.php
php /home/<user>/public_html/projekti/trip/scripts/run_email_verification_cleanup.php
```

## 3) Run

1. Open your domain over HTTPS.
2. Enter nickname on first launch.
3. Install to home screen from browser install prompt.
4. Admin panel is available at `/admin.html`.

## 4) Mobile push setup

### Android (FCM)

0. Java/JDK for Android build:
   - Use JDK 21 (Android Studio Embedded JDK).
   - This repo pins Gradle to:
     - `org.gradle.java.home=/Applications/Android Studio.app/Contents/jbr/Contents/Home`
   - If path differs on another machine, update `mobile/android/gradle.properties`.

1. In Firebase Console, add Android app with package id:
   - `com.tripsplit.app.tripsplit`
2. Download `google-services.json`.
3. Place file at:
   - `mobile/android/app/google-services.json`
4. Rebuild Android app (`flutter run` or Gradle build).
5. Server-side FCM credentials:
   - preferred: service account JSON at `keys/firebase-service-account.json` and set:
     - `TRIP_PUSH_FCM_SERVICE_ACCOUNT_REL_PATH=keys/firebase-service-account.json`
     - `TRIP_PUSH_FCM_PROJECT_ID=<your-project-id>` (optional if JSON includes it)
   - optional fallback: set legacy `TRIP_PUSH_FCM_SERVER_KEY` (if your Firebase project still provides it).

Notes:
- Project is configured to enable Google Services plugin only if `google-services.json` exists.
- Without this file, Android app works, but push token registration returns empty and background push is unavailable.
- If Firebase legacy API is disabled, backend must use HTTP v1 service account mode.

### iOS (FCM + APNs key in Firebase)

1. In Firebase Console, add iOS app with bundle id:
   - `com.tripsplit.app.tripsplit`
2. Download `GoogleService-Info.plist`.
3. Place file at:
   - `mobile/ios/Runner/GoogleService-Info.plist`
4. In Firebase Console -> Cloud Messaging, upload APNs auth key (`.p8`) for development and production.
5. Rebuild iOS app (Xcode/TestFlight build).

## 5) GitHub Actions (CI + VPS deploy)

This repository includes workflow:

- `.github/workflows/ci-deploy-vps.yml`

Behavior:

- Pull request to `main`: runs backend PHPUnit tests.
- Push to `main`: runs backend PHPUnit tests.
- Deploy to VPS on push happens only if repository variable `AUTO_DEPLOY_VPS=true`.
- Manual run (`workflow_dispatch`): deploy runs only when input `deploy_target=prod`.
- If required VPS secrets are missing, deploy job is skipped and only tests run.

Required GitHub repository secrets:

- `VPS_HOST` (example: `204.168.239.179`)
- `VPS_USER` (example: `root`)
- `VPS_SSH_PRIVATE_KEY` (private key matching server authorized key)
- `VPS_SSH_KNOWN_HOSTS` (pinned host key line, e.g. output from `ssh-keyscan -H <host>`)
- `VPS_PORT` (optional, default `22`)
- `VPS_APP_DIR` (optional, default `/var/www/splyto`)
- `API_BASE_URL` (example: `https://splyto.egm.lv`)

Optional repository variable:

- `AUTO_DEPLOY_VPS`:
  - `false` (recommended for safer development; deploy only manual)
  - `true` (auto deploy on every push to `main`)

How to generate pinned known hosts value:

```bash
ssh-keyscan -p 22 -H 204.168.239.179
```

Copy full output line(s) into `VPS_SSH_KNOWN_HOSTS` secret (GitHub -> Settings -> Secrets and variables -> Actions).

Deploy strategy used in workflow:

- `git fetch origin`
- `git checkout main`
- `git reset --hard origin/main`
- ensure upload/log directories exist (`uploads/*`, `logs`)
- PHP lint smoke checks on critical backend files
- HTTP health checks:
  - `/api/api.php?action=unknown` -> expects `404`
  - `/api/api.php?action=me` -> expects `401`

## API actions

`register_proof`, `register`, `login`, `refresh_session`, `set_credentials`, `me`, `update_profile`, `forgot_password`, `reset_password`, `request_email_verification_link`, `confirm_email_verification`, `deactivate_account`, `request_reactivation_link`, `confirm_reactivation`, `request_account_deletion_link`, `confirm_account_deletion`, `trips`, `all_users`, `search_users`, `friends_list`, `send_friend_invite`, `respond_friend_invite`, `cancel_friend_invite`, `remove_friend`, `create_trip`, `update_trip`, `delete_trip`, `add_trip_members`, `users`, `upload_trip_image`, `upload_receipt`, `upload_avatar`, `remove_avatar`, `add_expense`, `update_expense`, `delete_expense`, `list_expenses`, `balances`, `end_trip`, `set_ready_to_settle`, `mark_settlement_sent`, `confirm_settlement_received`, `remind_settlement`, `list_notifications`, `list_notifications_global`, `mark_notifications_read`, `mark_notifications_read_global`, `register_push_token`, `unregister_push_token`, `create_trip_invite`, `join_trip_invite`, `submit_feedback`, `workspace_snapshot`, `generate_order`, `list_orders`, `admin_feedback_feed`, `admin_archive_feedback`, `admin_delete_feedback`, `admin_summary`, `admin_users`, `admin_user_detail`, `admin_delete_expense`, `admin_update_user`, `admin_delete_user`

## Notes about realtime on nano.lv shared hosting

- nano.lv shared hosting typically does not support inbound WebSocket servers.
- This project uses polling every ~3.2s for instant-enough shared updates.
- If you need true socket backend, use VPS or external realtime service.
