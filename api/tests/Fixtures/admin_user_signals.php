<?php
declare(strict_types=1);
// Runs admin_users_with_account_signals() against SQLite with schema checks stubbed.
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
function table_name(string $key): string { return 'trip_' . $key; }
function json_out(array $payload, int $status = 200): void { throw new RuntimeException('Unexpected response'); }
function social_auth_identity_table_available(PDO $pdo): bool { return true; }
function push_tokens_table_available(PDO $pdo): bool { return true; }
function users_email_verified_at_column_available(PDO $pdo): bool { return true; }
require __DIR__ . '/../../lib/actions/admin_panel_actions.php';

$pdo = new PDO('sqlite::memory:');
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
$pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
$pdo->exec('CREATE TABLE trip_users (id INTEGER PRIMARY KEY, nickname TEXT, email TEXT, account_status TEXT,
    created_at TEXT, password_hash TEXT, email_verified_at TEXT)');
$pdo->exec('CREATE TABLE trip_user_identities (user_id INTEGER, provider TEXT)');
$pdo->exec('CREATE TABLE trip_push_tokens (user_id INTEGER, platform TEXT)');
$pdo->exec("INSERT INTO trip_users VALUES
    (1,'Password user','a@example.invalid','active','2026-11-01','hash','2026-11-01'),
    (2,'Apple user','b@example.invalid','active','2026-11-02',NULL,NULL),
    (3,'Both','c@example.invalid','active','2026-11-03','hash',NULL),
    (4,'Empty hash',NULL,'deleted','2026-11-04','',NULL)");
$pdo->exec("INSERT INTO trip_user_identities VALUES (2,'apple'),(3,'google')");
$pdo->exec("INSERT INTO trip_push_tokens VALUES (1,'ios'),(1,'ios'),(1,'android'),(3,'android')");
$rows = $pdo->query("SELECT id, nickname, " . admin_has_password_login_sql() . "
    FROM trip_users ORDER BY id")->fetchAll();
echo json_encode(['users' => admin_users_with_account_signals($pdo, $rows),
    'empty' => admin_users_with_account_signals($pdo, [])], JSON_THROW_ON_ERROR);
