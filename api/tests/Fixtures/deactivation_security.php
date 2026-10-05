<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/deactivation_harness.php';
$pdo = credentials_test_db();
reset_deactivation_schema($pdo);
$scenario = $argv[1];
seed_credential_user($pdo, str_contains($scenario, 'social') ? 'social' : 'established');
$accessToken = create_access_token_for_user(1, 1);
$request = str_starts_with($scenario, 'request');
$direct = str_starts_with($scenario, 'direct');
if (!$request) {
    seed_deactivation_proof($pdo, 'a', $scenario === 'purpose' ? 'delete' : 'deactivate');
    seed_deactivation_proof($pdo, 'b');
}
if ($scenario === 'request_limit') { foreach (['a','b','c'] as $char) { seed_deactivation_proof($pdo, $char); } }
if ($scenario === 'legacy') { $pdo->exec('UPDATE trip_account_action_tokens SET credential_state_hash = NULL'); }
if ($scenario === 'expired') { $pdo->exec("UPDATE trip_account_action_tokens SET expires_at = '2000-01-01'"); }
if ($scenario === 'used') { $pdo->exec('UPDATE trip_account_action_tokens SET used_at = UTC_TIMESTAMP()'); }
if ($scenario === 'changed_email') { $pdo->exec("UPDATE trip_users SET email = 'changed@example.invalid' WHERE id = 1"); }
if ($scenario === 'changed_password') { $pdo->exec("UPDATE trip_users SET password_hash = 'different' WHERE id = 1"); }
if ($scenario === 'reactivated') { $pdo->exec("UPDATE trip_users SET deactivated_at = '2026-01-01' WHERE id = 1"); }
if (in_array($scenario, ['unverified','request_unverified'], true)) { $pdo->exec('UPDATE trip_users SET email_verified_at = NULL WHERE id = 1'); }
if (in_array($scenario, ['inactive','request_inactive'], true)) { $pdo->exec("UPDATE trip_users SET account_status = 'deactivated' WHERE id = 1"); }
if ($scenario === 'guest') { $pdo->exec('UPDATE trip_users SET credentials_required = 1 WHERE id = 1'); }
if ($scenario === 'request_anonymous') { $accessToken = ''; }
if ($scenario === 'request_mail_failure') { $mailSucceeds = false; }
if ($scenario === 'missing_schema') { $pdo->exec('ALTER TABLE trip_account_action_tokens DROP COLUMN credential_state_hash'); }
if ($scenario === 'session_failure') { fail_credential_session_write($pdo, 'UPDATE'); }
if ($scenario === 'token_failure' || $scenario === 'push_failure') {
    $table = $scenario === 'token_failure' ? 'trip_account_action_tokens' : 'trip_push_tokens';
    $pdo->exec('CREATE TRIGGER fail_deactivation BEFORE UPDATE ON ' . $table . ' '
        . ($pdo->getAttribute(PDO::ATTR_DRIVER_NAME) === 'mysql'
            ? "FOR EACH ROW SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Synthetic failure'"
            : "BEGIN SELECT RAISE(ABORT, 'Synthetic failure'); END"));
}
$before = deactivation_snapshot($pdo);
$requestBody = $request ? ['email' => 'attacker@example.invalid'] : ['token' => str_repeat('a', 64)];
if ($scenario === 'malformed') { $requestBody['token'] = 'invalid'; }
if ($direct) { $requestBody = ['password' => $scenario === 'direct_password' ? ' Current-password-123 ' : '']; }
$action = $request ? 'request_deactivation_link_action' : ($direct ? 'deactivate_account_action' : 'confirm_deactivation_action');
$failure = false;
$second = null;
try {
    $response = credential_test_response($action);
    if ($scenario === 'replay' || $scenario === 'request_cooldown') { $second = credential_test_response($action); }
} catch (PDOException $e) { $failure = true; $response = null; }
$after = deactivation_snapshot($pdo);
echo json_encode(['response' => $response, 'second' => $second, 'failure' => $failure,
    'unchanged' => $before === $after, 'transaction_open' => $pdo->inTransaction(),
    'other_unchanged' => $before['users'][1] === $after['users'][1]
        && $before['refresh_tokens'][2] === $after['refresh_tokens'][2] && $before['push_tokens'][1] === $after['push_tokens'][1],
    'status' => $after['users'][0]['account_status'],
    'password_unchanged' => $before['users'][0]['password_hash'] === $after['users'][0]['password_hash'],
    'active_sessions' => count(array_filter($after['refresh_tokens'], fn($r) => (int)$r['user_id'] === 1 && $r['revoked_at'] === null)),
    'push_active' => (int) $after['push_tokens'][0]['is_active'],
    'unused' => count(array_filter($after['account_action_tokens'], fn($r) => $r['used_at'] === null)),
    'mail_count' => count($mail), 'recipients' => array_column($mail, 'to'),
    'tokens' => count($after['account_action_tokens']),
], JSON_THROW_ON_ERROR);
