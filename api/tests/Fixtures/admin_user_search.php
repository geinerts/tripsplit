<?php
declare(strict_types=1);
// Runs admin_user_search() against SQLite with schema checks stubbed.
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
function table_name(string $key): string { return 'trip_' . $key; }
function json_out(array $payload, int $status = 200): void { throw new RuntimeException('Unexpected response'); }
function social_auth_identity_table_available(PDO $pdo): bool { return true; }
function push_tokens_table_available(PDO $pdo): bool { return true; }
function users_email_verified_at_column_available(PDO $pdo): bool { return true; }
require __DIR__ . '/../../lib/actions/admin_panel_actions.php';

$pdo = new PDO('sqlite::memory:');
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
$pdo->exec('CREATE TABLE trip_users (id INTEGER PRIMARY KEY, nickname TEXT, email TEXT, account_status TEXT,
    created_at TEXT, password_hash TEXT, email_verified_at TEXT, guest_trip_id INTEGER)');
$pdo->exec('CREATE TABLE trip_user_identities (user_id INTEGER, provider TEXT)');
$pdo->exec('CREATE TABLE trip_push_tokens (user_id INTEGER, platform TEXT)');
$pdo->exec('CREATE TABLE trip_trip_members (trip_id INTEGER, user_id INTEGER)');
$pdo->exec('CREATE TABLE trip_refresh_tokens (id INTEGER PRIMARY KEY, user_id INTEGER, last_used_at TEXT, created_at TEXT DEFAULT \'2026-11-01 00:00:00\', revoked_at TEXT, expires_at TEXT DEFAULT \'2026-12-31 00:00:00\', user_agent TEXT, token_hash TEXT DEFAULT \'h\', ip_address TEXT DEFAULT \'192.0.2.9\')');
$pdo->exec('CREATE TABLE trip_premium_grants (user_id INTEGER, revoked_at TEXT, starts_at TEXT, ends_at TEXT)');
$pdo->exec("INSERT INTO trip_users VALUES
    (1,'Anna 100%','anna@example.invalid','active','2026-11-01','hash','2026-11-01',NULL),
    (2,'Bob','bob@example.invalid','active','2026-11-02',NULL,NULL,NULL),
    (3,'Cara','cara@example.invalid','deleted','2026-11-03','hash',NULL,NULL),
    (4,'Guest',NULL,'active','2026-11-04',NULL,NULL,9)");
$pdo->exec("INSERT INTO trip_user_identities VALUES (2,'apple')");
$pdo->exec("INSERT INTO trip_push_tokens VALUES (1,'iOS'),(2,'android')");
$pdo->exec('INSERT INTO trip_trip_members VALUES (1,2),(2,2),(3,2),(1,1)');
$pdo->exec("INSERT INTO trip_refresh_tokens (user_id, last_used_at, user_agent) VALUES (1,'2026-11-10 10:00:00','Splyto/1.0 iOS'),(1,'2026-11-11 10:00:00','Splyto/1.0 Android'),(3,'2026-11-05 09:00:00','x')");
$pdo->exec("INSERT INTO trip_refresh_tokens (user_id, last_used_at, revoked_at) VALUES (1,'2026-11-12 07:00:00','2026-11-12 07:30:00')");
$pdo->exec("INSERT INTO trip_refresh_tokens (user_id, last_used_at, expires_at) VALUES (1,'2026-11-12 07:00:00','2026-11-01 00:00:00')");
$pdo->exec("INSERT INTO trip_premium_grants VALUES
    (1,NULL,'2026-11-01 00:00:00','2026-12-01 00:00:00'),
    (2,'2026-11-02 00:00:00','2026-11-01 00:00:00','2026-12-01 00:00:00'),
    (3,NULL,'2026-10-01 00:00:00','2026-11-01 00:00:00')");

$pdo->exec('CREATE TABLE trip_app_events (id INTEGER PRIMARY KEY, user_id INTEGER, created_at TEXT, event_type TEXT DEFAULT \'expense.create\', entity_type TEXT, entity_id INTEGER, trip_id INTEGER)');
$pdo->exec('CREATE TABLE trip_trips (id INTEGER PRIMARY KEY, created_at TEXT, name TEXT DEFAULT \'Rome\')');
$pdo->exec("INSERT INTO trip_app_events (user_id, created_at, trip_id) VALUES (1,'2026-11-12 07:00:00',1),(1,'2026-11-12 07:30:00',NULL),(2,'2026-11-12 06:00:00',NULL),
    (2,'2026-11-10 06:00:00',NULL),(NULL,'2026-11-12 06:00:00',NULL),(3,'2026-10-01 06:00:00',NULL)");
$pdo->exec("INSERT INTO trip_trips (id, created_at) VALUES (1,'2026-11-11 10:00:00'),(2,'2026-11-11 11:00:00'),(3,'2026-09-01 00:00:00')");
$pdo->exec('CREATE TABLE trip_push_queue (status TEXT, created_at TEXT, updated_at TEXT, sent_at TEXT)');
$pdo->exec("INSERT INTO trip_push_queue VALUES ('pending','2026-11-12 07:50:00','2026-11-12 07:50:00',NULL),
    ('pending','2026-11-12 07:40:00','2026-11-12 07:40:00',NULL),('sent','2026-11-12 07:00:00','2026-11-12 07:00:01','2026-11-12 07:00:01'),
    ('failed','2026-11-12 03:00:00','2026-11-12 03:00:00',NULL),('dead','2026-11-01 03:00:00','2026-11-01 03:00:00',NULL)");
$pdo->exec('CREATE TABLE trip_admin_audit_log (id INTEGER PRIMARY KEY, admin_username TEXT, action TEXT, ip_address TEXT, created_at TEXT)');
$pdo->exec("INSERT INTO trip_admin_audit_log (admin_username, action, ip_address, created_at) VALUES
    ('owner','admin.auth.login_failed','192.0.2.1','2026-11-12 07:00:00'),
    ('x','admin.auth.login_failed_unknown_user','192.0.2.2','2026-11-12 07:01:00'),
    ('owner','admin.auth.2fa_failed','192.0.2.1','2026-11-12 07:02:00'),
    ('owner','admin.auth.2fa_success','192.0.2.1','2026-11-12 07:03:00'),
    ('owner','user.suspend','192.0.2.1','2026-11-12 07:04:00'),
    ('owner','admin.auth.login_failed','192.0.2.1','2026-10-01 07:00:00')");
$pdo->exec('CREATE TABLE trip_request_limits (scope TEXT, subject_hash TEXT, window_start INTEGER, hits INTEGER)');
$nowTs = strtotime('2026-11-12 08:00:00 UTC');
$pdo->exec("INSERT INTO trip_request_limits VALUES ('login_ip','a'," . ($nowTs - 600) . ",25),('login_ip','b'," . ($nowTs - 300) . ",3),
    ('refresh_ip','c'," . ($nowTs - 60) . ",8),('login_ip','old'," . ($nowTs - 2 * 86400) . ",99)");
$pdo->exec('CREATE TABLE trip_admin_sessions (token TEXT, expires_at TEXT)');
$pdo->exec("INSERT INTO trip_admin_sessions VALUES ('a','2026-11-12 09:00:00'),('b','2026-11-12 07:00:00')");
$now = '2026-11-12 08:00:00';
$ids = static fn(array $query): array => array_column(admin_user_search($pdo, $query, $now)['users'], 'id');
echo json_encode([
    'newest' => $ids([]),
    'oldest' => $ids(['sort' => 'oldest']),
    'last_active' => $ids(['sort' => 'last_active']),
    'trips' => $ids(['sort' => 'trips']),
    'ios' => $ids(['platform' => 'ios']),
    'apple' => $ids(['sign_in' => 'apple']),
    'email' => $ids(['sign_in' => 'email']),
    'premium' => $ids(['premium' => '1']),
    'unverified' => $ids(['unverified' => '1']),
    'percent' => $ids(['q' => '100%']),
    'literal_percent' => $ids(['q' => '%']),
    'deleted' => $ids(['status' => 'deleted']),
    'page' => admin_user_search($pdo, ['limit' => 1, 'offset' => 1], $now),
    'push' => admin_push_queue_health($pdo, $now),
    'sessions' => admin_user_sessions($pdo, 1, $now),
    'timeline' => admin_user_timeline($pdo, 1),
    'security' => admin_security_overview($pdo, $nowTs),
    'growth' => admin_growth_series($pdo, '2026-11-12', 30),
    'first' => admin_user_search($pdo, ['sort' => 'oldest', 'limit' => 1], $now)['users'][0],
], JSON_THROW_ON_ERROR);
