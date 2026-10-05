<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/isolated_mysql.php';
require __DIR__ . '/../../config/config_user_validation.php';
require __DIR__ . '/../../lib/helpers/helper_trip.php';
require __DIR__ . '/../../lib/actions/trips_actions.php';
require __DIR__ . '/../../lib/actions/workspace_actions.php';
require __DIR__ . '/../../lib/actions/expenses_actions.php';
require __DIR__ . '/../../lib/actions/notifications_actions.php';
require __DIR__ . '/../../lib/helpers/helper_pagination.php';
require __DIR__ . '/../../lib/helpers/helper_share_preview.php';
define('DB_TABLE_PREFIX', 'trip_');
define('PUBLIC_BASE_URL', 'https://example.invalid');
define('RATE_LIMIT_TRIP_WRITE_IP_MAX', 100);
define('RATE_LIMIT_TRIP_WRITE_USER_MAX', 100);
define('RATE_LIMIT_MUTATION_WINDOW_SEC', 60);

class InvitationResponse extends RuntimeException {
    public function __construct(public array $payload, public int $status) { parent::__construct(); }
}
function json_out(array $payload, int $status = 200): void { throw new InvitationResponse($payload, $status); }
function table_name(string $key): string { return 'trip_' . $key; }
function db(): PDO { return $GLOBALS['pdo']; }
function require_post(): void {}
function read_json(): array { return $GLOBALS['body']; }
function bearer_access_token_from_header(): string { return 'synthetic-auth'; }
function resolve_user_id_from_access_token(string $token): int { return $GLOBALS['actor']; }
function fetch_me_row_by_id(PDO $pdo, int $id): ?array {
    $stmt = $pdo->prepare('SELECT * FROM trip_users WHERE id=:id');
    $stmt->execute(['id'=>$id]);
    return $stmt->fetch() ?: null;
}
function client_ip_address(): string { return '192.0.2.1'; }
function enforce_rate_limit(...$args): void {}
function trips_currency_column_available(PDO $pdo): bool { return true; }
function users_name_columns_available(PDO $pdo): bool { return true; }
function users_account_status_column_available(PDO $pdo): bool { return true; }
function default_trip_currency_code(): string { return 'EUR'; }
function normalize_currency_code($code): string { return (string) $code; }
function normalize_me_name_value($name): ?string { return $name ?: null; }
function combine_full_name($first, $last): ?string { return trim($first . ' ' . $last) ?: null; }
function me_display_name(array $user): string { return $user['nickname']; }
function push_should_queue_notification_type(string $type): bool { return false; }
function app_event(...$args): void {}
function compute_trip_balance_data(PDO $pdo, int $id): array { return ['stats'=>[]]; }
function trip_payments_table_available(PDO $pdo): bool { return true; }

// Real handlers, membership/role checks, notification SQL and transactions.
// SQLite only adapts MySQL syntax; the identical scenarios also run on MySQL.
class_alias(class_exists('Pdo\\Sqlite') ? 'Pdo\\Sqlite' : PDO::class, 'InvitationSQLiteBase');
class InvitationSQLite extends InvitationSQLiteBase {
    public function prepare(string $query, array $options = []): PDOStatement|false {
        if (str_contains($query, 'information_schema.tables')) {
            $query = "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name=:table_name";
        } elseif (str_contains($query, 'information_schema.columns')) {
            $condition = substr($query, strpos($query, 'AND column_name') + 4);
            $query = 'SELECT COUNT(*) FROM pragma_table_info(:table_name) WHERE ' . str_replace('column_name', 'name', $condition);
        }
        $query = str_replace(['FOR UPDATE', 'UTC_TIMESTAMP()', 'NOW()'], ['', 'CURRENT_TIMESTAMP', 'CURRENT_TIMESTAMP'], $query);
        if (str_starts_with(ltrim($query), 'UPDATE')) {
            $query = preg_replace('/\s+LIMIT 1\s*$/', '', $query);
        }
        return parent::prepare($query, $options);
    }
}

function invitation_test_setup(bool $mysql, bool $migrated = true): PDO {
    $pdo = $mysql ? isolated_test_mysql() : new InvitationSQLite('sqlite::memory:');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
    if ($mysql) $pdo->exec('SET FOREIGN_KEY_CHECKS=0');
    foreach (['trip_invite_preview_tokens','trip_invites','notifications','expense_participants','expenses','settlements','payments','trip_members','trips','users'] as $table) {
        $pdo->exec('DROP TABLE IF EXISTS trip_' . $table);
    }
    if ($mysql) $pdo->exec('SET FOREIGN_KEY_CHECKS=1');
    $id = $mysql ? 'INT UNSIGNED PRIMARY KEY AUTO_INCREMENT' : 'INTEGER PRIMARY KEY AUTOINCREMENT';
    $pdo->exec('CREATE TABLE trip_users (id ' . $id . ', nickname VARCHAR(64), first_name VARCHAR(64), last_name VARCHAR(64), account_status VARCHAR(20))');
    $pdo->exec('CREATE TABLE trip_trips (id ' . $id . ', name VARCHAR(120), created_by INT UNSIGNED,
        trip_mode VARCHAR(10) DEFAULT "group", currency_code VARCHAR(3), status VARCHAR(20) DEFAULT "active",
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, ended_at TIMESTAMP NULL, archived_at TIMESTAMP NULL)');
    $pdo->exec('CREATE TABLE trip_trip_members (trip_id INT UNSIGNED, user_id INT UNSIGNED, role VARCHAR(20), PRIMARY KEY(trip_id,user_id))');
    $pdo->exec('CREATE TABLE trip_trip_invites (id ' . $id . ', trip_id INT UNSIGNED, created_by INT UNSIGNED,
        invite_code VARCHAR(10) UNIQUE, expires_at DATETIME, revoked_at DATETIME NULL)');
    $pdo->exec('CREATE TABLE trip_trip_invite_preview_tokens (id ' . $id . ', trip_id INT UNSIGNED,
        user_id INT UNSIGNED, invite_code VARCHAR(10), nonce_hash VARCHAR(64) UNIQUE, expires_at DATETIME, used_at DATETIME NULL)');
    $pdo->exec('CREATE TABLE trip_notifications (id ' . $id . ', trip_id INT UNSIGNED, user_id INT UNSIGNED,
        type VARCHAR(50), title VARCHAR(100), body TEXT, payload_json TEXT, is_read INT,
        read_at TIMESTAMP NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)');
    $pdo->exec('CREATE TABLE trip_expenses (id ' . $id . ', trip_id INT UNSIGNED, paid_by INT UNSIGNED)');
    $pdo->exec('CREATE TABLE trip_expense_participants (expense_id INT UNSIGNED, user_id INT UNSIGNED)');
    $pdo->exec('CREATE TABLE trip_settlements (trip_id INT UNSIGNED, from_user_id INT UNSIGNED, to_user_id INT UNSIGNED)');
    $pdo->exec('CREATE TABLE trip_payments (trip_id INT UNSIGNED, from_user_id INT UNSIGNED, to_user_id INT UNSIGNED)');
    if ($migrated) {
        if ($mysql) {
            $pdo->exec(file_get_contents(__DIR__ . '/../../../sql/migrations/2026-10-05-add-directed-trip-invitations.sql'));
        } else {
            $pdo->exec('ALTER TABLE trip_trip_invites ADD COLUMN target_user_id INTEGER NULL');
            $pdo->exec('ALTER TABLE trip_trip_invites ADD COLUMN response VARCHAR(20) NULL');
        }
    }
    $pdo->exec('INSERT INTO trip_users(id,nickname,account_status) VALUES (1,"Owner","active"),(2,"Invitee","active"),(3,"Other","active")');
    return $pdo;
}

function invitation_call(string $handler, int $user, array $input = []): array {
    $GLOBALS['actor'] = $user;
    $GLOBALS['body'] = $input;
    try { $handler(); } catch (InvitationResponse $response) {
        return ['status'=>$response->status, 'body'=>$response->payload];
    }
    throw new RuntimeException('Handler returned without response');
}
function invitation_expect(bool $condition, string $message): void {
    if (!$condition) throw new RuntimeException($message);
    $GLOBALS['assertions']++;
}

if (realpath($_SERVER['SCRIPT_FILENAME']) !== __FILE__) return;
$case = $argv[1];
$mysql = getenv('SPLYTO_ISOLATED_MYSQL') === '1';
$pdo = invitation_test_setup($mysql, $case !== 'unmigrated');
if ($mysql && $case === 'runtime_flow') {
    // DDL setup uses the fixture account; all following real handlers use DML only.
    $pdo = new PDO('mysql:host=mysql;dbname=splyto_security_test;charset=utf8mb4',
        'splyto_runtime_test', 'isolated-runtime-only', [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]);
}
$assertions = 0;
$actor = 1;
$body = [];
if ($case === 'rollback') {
    $pdo->exec($mysql
        ? 'CREATE TRIGGER invitation_failure BEFORE INSERT ON trip_notifications FOR EACH ROW SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT="synthetic failure"'
        : 'CREATE TRIGGER invitation_failure BEFORE INSERT ON trip_notifications BEGIN SELECT RAISE(ABORT, "synthetic failure"); END');
    try {
        invitation_call('create_trip_action', 1, ['name'=>'Rollback trip','member_ids'=>[2]]);
        throw new RuntimeException('Expected notification failure');
    } catch (PDOException $error) {
        invitation_expect(str_contains($error->getMessage(), 'synthetic failure'), 'Expected injected failure');
    }
    foreach (['trip_trips','trip_trip_members','trip_trip_invites','trip_notifications'] as $table) {
        invitation_expect((int)$pdo->query('SELECT COUNT(*) FROM ' . $table)->fetchColumn() === 0, 'Atomic rollback: ' . $table);
    }
    invitation_expect(!$pdo->inTransaction(), 'Rollback closes transaction');
    echo json_encode(['assertions'=>$assertions], JSON_THROW_ON_ERROR);
    exit;
}
$created = invitation_call('create_trip_action', 1, ['name'=>'Private trip', 'member_ids'=>[2]]);
if ($case === 'unmigrated') {
    invitation_expect($created['status'] === 409, 'Must fail closed before schema migration');
    invitation_expect((int) $pdo->query('SELECT COUNT(*) FROM trip_trip_members')->fetchColumn() === 0, 'No auto-membership fallback');
} else {
    invitation_expect($created['status'] === 200, 'Create trip succeeds');
    $tripId = $created['body']['trip']['id'];
    $_SERVER['HTTP_X_TRIP_ID'] = (string) $tripId;
    $code = $pdo->query('SELECT invite_code FROM trip_trip_invites')->fetchColumn();
    invitation_expect($created['body']['trip']['members_count'] === 1, 'Only owner is active');
    invitation_expect(find_trip_for_user($pdo, 2, $tripId) === null, 'Pending user cannot see trip');
    invitation_expect(!share_trip_meta($code)['valid'], 'Personal invitation has no public trip preview');
    invitation_expect((int) $pdo->query('SELECT COUNT(*) FROM trip_notifications')->fetchColumn() === 1, 'Invitation delivered');
    $again = invitation_call('add_trip_members_action', 1, ['member_ids'=>[2]]);
    invitation_expect($again['body']['invited_count'] === 0, 'Pending invitation deduplicated');
    invitation_expect((int) $pdo->query('SELECT COUNT(*) FROM trip_notifications')->fetchColumn() === 1, 'No duplicate notification');
    $preview = invitation_call('preview_trip_invite_action', 2, ['invite_token'=>$code]);
    invitation_expect($preview['status'] === 200 && $preview['body']['invite']['is_directed'], 'Recipient gets confirmation');
    $join = ['invite_token'=>$code, 'preview_nonce'=>$preview['body']['invite']['preview_nonce']];
    switch ($case) {
        case 'runtime_flow':
            $inbox = load_global_notifications_page($pdo, 2, 50, null, 0);
            invitation_expect(count($inbox['items']) === 1, 'Pending recipient sees invitation in global inbox');
            invitation_expect($inbox['items'][0]['payload']['invite_token'] === $code, 'Inbox preserves actionable token');
            invitation_expect(load_global_notifications_page($pdo, 3, 50, null, 0)['items'] === [], 'Other account cannot see invitation');
            invitation_expect(invitation_call('join_trip_invite_action', 2, $join)['status'] === 200, 'DML account can accept');
            invitation_expect(invitation_call('remove_trip_member_action', 1, ['user_id'=>2])['status'] === 200, 'DML account can remove');
            invitation_expect(invitation_call('workspace_snapshot_action', 2)['status'] === 403, 'Removed recipient loses workspace access');
            invitation_expect(invitation_call('add_trip_members_action', 1, ['member_ids'=>[]])['status'] === 400, 'Empty recipient list rejected');
            invitation_expect(invitation_call('add_trip_members_action', 1, ['member_ids'=>[2]])['body']['invited_count'] === 1, 'DML account can reinvite');
            $freshCode = $pdo->query('SELECT invite_code FROM trip_trip_invites WHERE target_user_id=2 AND revoked_at IS NULL')->fetchColumn();
            invitation_expect(invitation_call('decline_trip_invite_action', 2, ['invite_token'=>$freshCode])['status'] === 200, 'DML account can decline');
            invitation_expect(invitation_call('add_trip_members_action', 1, ['member_ids'=>[3]])['body']['invited_count'] === 1, 'DML account invites another recipient');
            $pending = invitation_call('list_pending_trip_invitations_action', 1)['body']['invitations'];
            invitation_expect(count($pending) === 1, 'Only pending invitations listed');
            invitation_expect(invitation_call('revoke_trip_invitation_action', 1, ['invitation_id'=>$pending[0]['id']])['status'] === 200, 'DML account can cancel');
            invitation_expect(find_trip_for_user($pdo, 3, $tripId) === null, 'Cancellation never grants access');
            break;
        case 'financial_history':
            invitation_expect(invitation_call('join_trip_invite_action', 2, $join)['status'] === 200, 'Member accepts');
            $pdo->exec('INSERT INTO trip_payments VALUES (' . $tripId . ',1,2)');
            invitation_expect(invitation_call('remove_trip_member_action', 1, ['user_id'=>2])['status'] === 409, 'Payment history blocks removal even with zero net balance');
            invitation_expect(invitation_call('leave_trip_action', 2)['status'] === 409, 'Payment history blocks departure');
            break;
        case 'revoke':
            $listed = invitation_call('list_pending_trip_invitations_action', 1);
            invitation_expect(count($listed['body']['invitations']) === 1, 'Owner sees pending invitation');
            invitation_expect(!isset($listed['body']['invitations'][0]['invite_code']), 'Listing does not leak tokens');
            $id = (int) $listed['body']['invitations'][0]['id'];
            invitation_expect(invitation_call('revoke_trip_invitation_action', 3, ['invitation_id'=>$id])['status'] === 403, 'Outsider cannot revoke');
            invitation_expect(invitation_call('revoke_trip_invitation_action', 1, ['invitation_id'=>$id])['status'] === 200, 'Owner revokes invitation');
            invitation_expect(invitation_call('join_trip_invite_action', 2, $join)['status'] === 409, 'Revoked invitation cannot be accepted');
            invitation_expect(invitation_call('list_pending_trip_invitations_action', 1)['body']['invitations'] === [], 'Revoked invitation not pending');
            break;
        case 'roles':
            invitation_expect(invitation_call('join_trip_invite_action', 2, $join)['status'] === 200, 'Member accepts');
            invitation_expect(invitation_call('add_trip_members_action', 2, ['member_ids'=>[3]])['status'] === 403, 'Member cannot invite');
            invitation_expect(invitation_call('list_pending_trip_invitations_action', 2)['status'] === 403, 'Member cannot list owner invites');
            invitation_expect(invitation_call('update_trip_member_role_action', 1, ['user_id'=>2,'role'=>'admin'])['status'] === 200, 'Owner promotes admin');
            invitation_expect(invitation_call('add_trip_members_action', 2, ['member_ids'=>[3]])['status'] === 200, 'Admin can invite');
            invitation_expect(invitation_call('list_pending_trip_invitations_action', 2)['status'] === 200, 'Admin can manage pending invites');
            invitation_expect(invitation_call('remove_trip_member_action', 1, ['user_id'=>2])['status'] === 200, 'Owner removes admin');
            invitation_expect(invitation_call('list_pending_trip_invitations_action', 1)['body']['invitations'] === [], 'Removed admin invitations revoked');
            break;
        case 'accept':
            invitation_expect(invitation_call('join_trip_invite_action', 2, $join)['status'] === 200, 'Accept succeeds');
            invitation_expect(find_trip_for_user($pdo, 2, $tripId) !== null, 'Accepted user gains access');
            invitation_expect(invitation_call('join_trip_invite_action', 2, $join)['status'] === 409, 'Replay denied');
            invitation_expect(invitation_call('decline_trip_invite_action', 2, ['invite_token'=>$code])['status'] === 409, 'Accepted invite cannot be declined');
            break;
        case 'decline':
            invitation_expect(invitation_call('decline_trip_invite_action', 2, ['invite_token'=>$code])['status'] === 200, 'Decline succeeds');
            invitation_expect(invitation_call('join_trip_invite_action', 2, $join)['status'] === 409, 'Cannot accept declined token');
            invitation_expect(find_trip_for_user($pdo, 2, $tripId) === null, 'Declining grants no access');
            invitation_expect(invitation_call('add_trip_members_action', 1, ['member_ids'=>[2]])['body']['invited_count'] === 1, 'Fresh invitation allowed');
            break;
        case 'wrong_user':
            invitation_expect(invitation_call('preview_trip_invite_action', 3, ['invite_token'=>$code])['status'] === 404, 'Other user cannot preview');
            invitation_expect(invitation_call('join_trip_invite_action', 3, $join)['status'] === 404, 'Other user cannot accept');
            invitation_expect(invitation_call('decline_trip_invite_action', 3, ['invite_token'=>$code])['status'] === 404, 'Other user cannot decline');
            break;
        case 'pending_access':
            foreach (['workspace_snapshot_action','list_expenses_action','list_trip_activity_action','users_action','list_notifications_action'] as $handler) {
                invitation_expect(invitation_call($handler, 2)['status'] === 403, 'Pending access denied: ' . $handler);
            }
            invitation_expect(invitation_call('add_trip_members_action', 2, ['member_ids'=>[3]])['status'] === 403, 'Pending cannot invite');
            break;
        case 'expired':
            $pdo->exec('UPDATE trip_trip_invites SET expires_at="2000-01-01 00:00:00"');
            invitation_expect(invitation_call('join_trip_invite_action', 2, $join)['status'] === 409, 'Expired invite denied');
            break;
        case 'closed':
            $pdo->exec('UPDATE trip_trips SET status="archived"');
            invitation_expect(invitation_call('join_trip_invite_action', 2, $join)['status'] === 409, 'Closed trip denied');
            break;
        case 'nonce':
            invitation_expect(invitation_call('join_trip_invite_action', 2, ['invite_token'=>$code,'preview_nonce'=>str_repeat('a',40)])['status'] === 409, 'Fake confirmation denied');
            break;
        case 'remove': case 'leave':
            invitation_expect(invitation_call('join_trip_invite_action', 2, $join)['status'] === 200, 'Accept before leaving');
            $shared = invitation_call('create_trip_invite_action', 1)['body']['invite_token'];
            $oldPreview = invitation_call('preview_trip_invite_action', 2, ['invite_token'=>$shared]);
            $depart = $case === 'remove'
                ? invitation_call('remove_trip_member_action', 1, ['user_id'=>2])
                : invitation_call('leave_trip_action', 2);
            invitation_expect($depart['status'] === 200, 'Departure succeeds');
            invitation_expect(find_trip_for_user($pdo, 2, $tripId) === null, 'Departure removes access');
            invitation_expect(invitation_call('join_trip_invite_action', 2,
                ['invite_token'=>$shared,'preview_nonce'=>$oldPreview['body']['invite']['preview_nonce']])['status'] === 409, 'Old shared link cannot restore membership');
            $new = invitation_call('add_trip_members_action', 1, ['member_ids'=>[2]]);
            invitation_expect($new['body']['invited_count'] === 1, 'Owner can reinvite');
            $newCode = $pdo->query('SELECT invite_code FROM trip_trip_invites WHERE target_user_id=2 AND revoked_at IS NULL')->fetchColumn();
            $newPreview = invitation_call('preview_trip_invite_action', 2, ['invite_token'=>$newCode]);
            invitation_expect(invitation_call('join_trip_invite_action', 2,
                ['invite_token'=>$newCode,'preview_nonce'=>$newPreview['body']['invite']['preview_nonce']])['status'] === 200, 'Fresh invitation explicitly restores access');
            break;
        case 'rotate':
            $shared = invitation_call('create_trip_invite_action', 1)['body']['invite_token'];
            invitation_expect(share_trip_meta($shared)['valid'], 'Public share preview still works');
            invitation_call('create_trip_invite_action', 1);
            invitation_expect(invitation_call('join_trip_invite_action', 2, $join)['status'] === 200, 'Link rotation preserves personal invites');
            break;
        default: throw new RuntimeException('Unknown scenario');
    }
}
invitation_expect(!$pdo->inTransaction(), 'No open transaction');
echo json_encode(['assertions'=>$assertions], JSON_THROW_ON_ERROR);
