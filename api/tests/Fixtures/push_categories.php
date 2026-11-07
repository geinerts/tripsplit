<?php
declare(strict_types=1);
// Push category preferences on the isolated MySQL test database, before and after the migration.
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/isolated_mysql.php';
define('DB_TABLE_PREFIX', 'trip_');
define('PUSH_ENABLED', true);
define('PUSH_QUEUE_BATCH_LIMIT', 10);
define('PUSH_TIMEOUT_SEC', 5);
define('PUSH_MAX_TOKENS_PER_USER', 5);
define('PUSH_CRITICAL_TYPES', 'trip_finished');
function table_name(string $key): string
{
    return DB_TABLE_PREFIX . ($key === 'notification_preferences' ? 'user_notification_preferences' : $key);
}
require __DIR__ . '/../../lib/helpers/helper_notification_preferences.php';
require __DIR__ . '/../../lib/helpers/push/push_core.php';

$pdo = isolated_test_mysql();
$table = 'trip_user_notification_preferences';
$pdo->exec('DROP TABLE IF EXISTS ' . $table);
// The current schema without the new columns and without the user foreign key.
$schema = file_get_contents(__DIR__ . '/../../../sql/schema.sql');
preg_match('/CREATE TABLE IF NOT EXISTS ' . $table . ' \((.*?)\n\) ENGINE/s', $schema, $match);
$lines = array_filter(explode("\n", $match[1]), static fn(string $line): bool =>
    !preg_match('/push_(comments|trip_invites|trip_status|payment_requests|payments|reminders)_enabled|CONSTRAINT|FOREIGN KEY|REFERENCES/', $line));
$pdo->exec('CREATE TABLE ' . $table . ' (' . rtrim(implode("\n", $lines), ", \n") . ') ENGINE=InnoDB');

$assertions = 0;
function check(bool $ok, string $label): void
{
    if (!$ok) throw new RuntimeException('Assertion failed: ' . $label);
    $GLOBALS['assertions']++;
}
function fresh(PDO $pdo, int $userId): array
{
    $cache = &notification_preferences_runtime_cache();
    $cache = [];
    return load_user_notification_preferences($pdo, $userId);
}
$settle = ['push_payment_requests_enabled', 'push_payments_enabled', 'push_reminders_enabled'];
$trip = ['push_comments_enabled', 'push_trip_invites_enabled', 'push_trip_status_enabled'];

// Before the migration: categories follow the older switches, and the server keeps working.
$prefs = fresh($pdo, 1);
check($prefs['push_reminders_enabled'] && $prefs['push_comments_enabled'], 'defaults on');
upsert_user_notification_preferences($pdo, 1, normalize_notification_preferences_patch(['push' => ['payments' => false]]));
$prefs = fresh($pdo, 1);
check($prefs['push_settlement_updates_enabled'] && $prefs['push_payments_enabled'], 'one category off keeps the older switch on');
upsert_user_notification_preferences($pdo, 1, normalize_notification_preferences_patch(
    ['push' => ['payment_requests' => false, 'payments' => false, 'reminders' => false]]
));
$prefs = fresh($pdo, 1);
check(!$prefs['push_settlement_updates_enabled'], 'all categories off turn the older switch off');
foreach ($settle as $key) check(!$prefs[$key], 'unmigrated ' . $key . ' follows the older switch');
check(!user_allows_push_notification($pdo, 1, 'settlement_reminder'), 'reminder blocked');
check(user_allows_push_notification($pdo, 1, 'expense_comment_added'), 'comment allowed');
upsert_user_notification_preferences($pdo, 2, ['push_trip_updates_enabled' => false]);

// The migration copies each user's older switch and is safe to run twice.
$migration = file_get_contents(__DIR__ . '/../../../sql/migrations/2026-11-08-split-push-notification-categories.sql');
$pdo->exec($migration);
$pdo->exec($migration);
$columns = $pdo->query("SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE()
    AND table_name = '{$table}' AND column_name LIKE 'push\\_%'")->fetchColumn();
check((int) $columns === 10, 'ten push columns');
$prefs = fresh($pdo, 1);
foreach ($settle as $key) check(!$prefs[$key], 'migrated ' . $key . ' copied off');
foreach ($trip as $key) check($prefs[$key], 'migrated ' . $key . ' copied on');
$prefs = fresh($pdo, 2);
foreach ($trip as $key) check(!$prefs[$key], 'second user ' . $key . ' copied off');

// After the migration each category is stored on its own.
upsert_user_notification_preferences($pdo, 1, normalize_notification_preferences_patch(['push' => ['reminders' => true]]));
$prefs = fresh($pdo, 1);
check($prefs['push_reminders_enabled'] && !$prefs['push_payments_enabled'], 'one category on');
check($prefs['push_settlement_updates_enabled'], 'older switch reads on while any category is on');
check(user_allows_push_notification($pdo, 1, 'settlement_auto_reminder'), 'reminder allowed');
check(!user_allows_push_notification($pdo, 1, 'payment_confirmed'), 'payment blocked');

// An older app writing the combined switch sets all of its categories.
upsert_user_notification_preferences($pdo, 1, normalize_notification_preferences_patch(['push' => ['trip_updates' => false]]));
$prefs = fresh($pdo, 1);
foreach ($trip as $key) check(!$prefs[$key], 'older switch turned ' . $key . ' off');
// A category in the same request wins over the combined switch.
upsert_user_notification_preferences($pdo, 1, normalize_notification_preferences_patch(
    ['push' => ['trip_updates' => true, 'trip_status' => false]]
));
$prefs = fresh($pdo, 1);
check($prefs['push_comments_enabled'] && $prefs['push_trip_invites_enabled'] && !$prefs['push_trip_status_enabled'], 'category wins');
$payload = build_notification_preferences_payload($prefs);
check($payload['push']['trip_updates'] === true && $payload['push']['trip_status'] === false, 'payload keys');
check(count($payload['push']) === 10, 'payload has ten push keys');

// Reminders and new comments reach the queue even when env critical types is narrowed.
check(push_should_queue_notification_type('settlement_reminder'), 'reminder queued');
check(push_should_queue_notification_type('expense_comment_added'), 'comment queued');
check(!push_should_queue_notification_type('trip_member_removed'), 'critical types still apply to others');

echo json_encode(['assertions' => $assertions]);
