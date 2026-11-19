<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/credentials_harness.php';
require __DIR__ . '/../../lib/actions/admin_panel_actions.php';
function token_from_header(): string { return str_repeat('a', 64); }
function app_event(PDO $pdo, mixed ...$args): void {}

$scenario = $argv[1] ?? 'active';
$pdo = credentials_test_db();
reset_credentials_test_schema($pdo);
if (!str_starts_with($scenario, 'missing_')) {
    $pdo->exec('ALTER TABLE trip_users ADD COLUMN email_verification_can_reactivate TINYINT NOT NULL DEFAULT 0');
}
$pdo->exec('ALTER TABLE trip_users ADD COLUMN deactivated_at DATETIME NULL');
$pdo->exec('ALTER TABLE trip_users ADD COLUMN avatar_path TEXT NULL');
$pdo->exec('ALTER TABLE trip_users ADD COLUMN created_at DATETIME');
seed_credential_user($pdo, 'unverified');
$pdo->exec("UPDATE trip_users SET created_at = '2020-01-01' WHERE id = 1");
$other = fetch_me_row_by_id($pdo, 2);

// A real authenticated admin guard and real mutation handlers, with synthetic tables.
foreach (['admin_sessions', 'admin_users', 'admin_audit_log'] as $table) {
    $pdo->exec('DROP TABLE IF EXISTS trip_' . $table);
}
$pdo->exec('CREATE TABLE trip_admin_users (id INT, username TEXT, email TEXT, role TEXT, is_active INT, totp_enabled INT)');
$pdo->exec("INSERT INTO trip_admin_users VALUES (1,'test-admin','admin@example.invalid','support',1,1)");
$pdo->exec('CREATE TABLE trip_admin_sessions (token TEXT, admin_user_id INT, ip_address TEXT,
    is_2fa_verified INT, expires_at DATETIME, last_active_at DATETIME)');
$pdo->prepare('INSERT INTO trip_admin_sessions VALUES (?,1,?,1,?,NULL)')->execute([
    hash('sha256', str_repeat('c', 64)), '192.0.2.1', gmdate('Y-m-d H:i:s', time() + 3600)]);
$pdo->exec('CREATE TABLE trip_admin_audit_log (admin_user_id INT, admin_username TEXT, action TEXT,
    target_type TEXT, target_id INT, details TEXT, ip_address TEXT)');
$_COOKIE[ADMIN_SESSION_COOKIE] = str_repeat('c', 64);

$cleanup = null;
if (in_array($scenario, ['cleanup', 'cleanup_then_admin', 'missing_cleanup'], true)) {
    $cleanup = process_unverified_account_deactivation($pdo);
}
if (in_array($scenario, ['legacy', 'missing_deactivated'], true)) {
    $pdo->exec("UPDATE trip_users SET account_status = 'deactivated', deactivated_at = '2020-01-02' WHERE id = 1");
}
if ($scenario === 'deleted') { $pdo->exec("UPDATE trip_users SET account_status = 'deleted' WHERE id = 1"); }
$proof = create_email_verification_token($pdo, 1, 'owner@example.invalid');
$admin = null;
if (in_array($scenario, ['admin', 'proof_before_admin', 'cleanup_then_admin', 'admin_reactivate', 'stale_timestamp'], true)) {
    if ($scenario === 'stale_timestamp') { $pdo->exec("UPDATE trip_users SET deactivated_at = '2020-01-02' WHERE id = 1"); }
    $requestBody = ['user_id' => 1, 'reason' => 'Synthetic suspension'];
    $admin = credential_test_response('admin_panel_user_suspend_action');
    if ($scenario === 'admin_reactivate') { credential_test_response('admin_panel_user_reactivate_action'); }
}
if ($scenario !== 'proof_before_admin') {
    $requestBody = ['email' => 'owner@example.invalid'];
    credential_test_response('request_email_verification_link_action');
    if ($mail) {
        parse_str((string) parse_url($mail[0]['body'], PHP_URL_QUERY), $query);
        $proof['token'] = $query['token'];
    }
}
$requestBody = ['token' => $proof['token']];
$confirmation = credential_test_response('confirm_email_verification_action');
$requestBody = ['email' => 'owner@example.invalid', 'password' => ' Current-password-123 '];
$login = credential_test_response('login_action');
$user = fetch_me_row_by_id($pdo, 1);
echo json_encode(['confirmation' => $confirmation, 'login_status' => $login['status'],
    'account_status' => $user['account_status'], 'permission' => $user['email_verification_can_reactivate'] ?? null,
    'mail_count' => count($mail), 'admin' => $admin, 'cleanup' => $cleanup,
    'other_unchanged' => $other === fetch_me_row_by_id($pdo, 2), 'open' => $pdo->inTransaction()], JSON_THROW_ON_ERROR);
