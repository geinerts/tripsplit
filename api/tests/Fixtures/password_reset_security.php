<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/password_reset_harness.php';
$scenario = $argv[1] ?? 'reset';
$pdo = credentials_test_db();
reset_password_test_schema($pdo);
seed_credential_user($pdo, str_contains($scenario, 'social') ? 'social' : 'established');
$userBefore = fetch_me_row_by_id($pdo, 1);
$response = $second = null;
$failed = false;
if (str_starts_with($scenario, 'request_')) {
    $requestBody = ['email' => ' OWNER@example.invalid '];
    if ($scenario === 'request_unknown') { $requestBody['email'] = 'missing@example.invalid'; }
    if ($scenario === 'request_inactive') { $pdo->exec("UPDATE trip_users SET account_status = 'deactivated' WHERE id = 1"); }
    if ($scenario === 'request_unverified') { $pdo->exec('UPDATE trip_users SET email_verified_at = NULL WHERE id = 1'); }
    if ($scenario === 'request_guest') { $pdo->exec('UPDATE trip_users SET credentials_required = 1 WHERE id = 1'); }
    if ($scenario === 'request_failed_mail') { $mailSucceeds = false; }
    if ($scenario === 'request_missing_schema') { $pdo->exec('ALTER TABLE trip_password_resets DROP COLUMN credential_state_hash'); }
    if ($scenario === 'request_preserves_link') { seed_password_reset($pdo); }
    if ($scenario === 'request_rolling_limit') {
        foreach (['a', 'b', 'c'] as $token) { seed_password_reset($pdo, $token); }
    }
    $before = password_reset_snapshot($pdo);
    $response = credential_test_response('forgot_password_action');
    if ($scenario === 'request_cooldown') { $second = credential_test_response('forgot_password_action'); }
} else {
    seed_password_reset($pdo);
    seed_password_reset($pdo, 'b');
    seed_password_reset($pdo, 'c', 2);
    if ($scenario === 'legacy') { $pdo->exec('UPDATE trip_password_resets SET credential_state_hash = NULL WHERE user_id = 1'); }
    if ($scenario === 'expired') { $pdo->exec("UPDATE trip_password_resets SET expires_at = '2000-01-01' WHERE user_id = 1"); }
    if ($scenario === 'used') { $pdo->exec('UPDATE trip_password_resets SET used_at = UTC_TIMESTAMP() WHERE user_id = 1'); }
    if ($scenario === 'changed_email') { $pdo->exec("UPDATE trip_users SET email = 'changed@example.invalid' WHERE id = 1"); }
    if ($scenario === 'changed_password') { $pdo->exec("UPDATE trip_users SET password_hash = 'different-hash' WHERE id = 1"); }
    if ($scenario === 'unverified') { $pdo->exec('UPDATE trip_users SET email_verified_at = NULL WHERE id = 1'); }
    if ($scenario === 'inactive') { $pdo->exec("UPDATE trip_users SET account_status = 'deactivated' WHERE id = 1"); }
    if ($scenario === 'guest') { $pdo->exec('UPDATE trip_users SET credentials_required = 1 WHERE id = 1'); }
    if ($scenario === 'missing_schema') { $pdo->exec('ALTER TABLE trip_password_resets DROP COLUMN credential_state_hash'); }
    if ($scenario === 'missing_sessions') { $pdo->exec('DROP TABLE trip_refresh_tokens'); }
    if ($scenario === 'session_failure') { fail_credential_session_write($pdo, 'UPDATE'); }
    if ($scenario === 'token_failure') {
        $pdo->exec('CREATE TRIGGER fail_reset BEFORE UPDATE ON trip_password_resets ' .
            ($pdo->getAttribute(PDO::ATTR_DRIVER_NAME) === 'mysql'
                ? "FOR EACH ROW SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Synthetic failure'"
                : "BEGIN SELECT RAISE(ABORT, 'Synthetic failure'); END"));
    }
    // The missing-session case must fail closed before it can mutate anything.
    if ($scenario === 'missing_sessions') {
        $before = ['users' => $pdo->query('SELECT * FROM trip_users ORDER BY id')->fetchAll(),
            'password_resets' => $pdo->query('SELECT * FROM trip_password_resets ORDER BY id')->fetchAll()];
    } else { $before = password_reset_snapshot($pdo); }
    $requestBody = ['token' => str_repeat($scenario === 'unknown' ? 'd' : 'a', 64), 'password' => ' New-password-456! '];
    if ($scenario === 'malformed') { $requestBody['token'] = 'not-a-token'; }
    if ($scenario === 'invalid_password') { $requestBody['password'] = 'short'; }
    try {
        $response = credential_test_response('reset_password_action');
        if ($scenario === 'replay') { $second = credential_test_response('reset_password_action'); }
    } catch (PDOException $e) { $failed = true; }
}
if ($scenario === 'missing_sessions') {
    $after = ['users' => $pdo->query('SELECT * FROM trip_users ORDER BY id')->fetchAll(),
        'password_resets' => $pdo->query('SELECT * FROM trip_password_resets ORDER BY id')->fetchAll()];
} else { $after = password_reset_snapshot($pdo); }
$user = fetch_me_row_by_id($pdo, 1);
$storedTokens = $after['password_resets'];
$plainTokenStored = false;
foreach ($mail as $message) {
    parse_str((string) parse_url($message['body'], PHP_URL_QUERY), $query);
    $plainTokenStored = $plainTokenStored || str_contains(json_encode($storedTokens), $query['token'] ?? 'MISSING');
}
echo json_encode(['response' => $response, 'second' => $second, 'failed' => $failed,
    'unchanged' => $before === $after, 'transaction_open' => $pdo->inTransaction(),
    'password_changed' => password_verify(' New-password-456! ', $user['password_hash']),
    'email_unchanged' => $user['email'] === $userBefore['email'],
    'mail_count' => count($mail), 'rates' => $rates, 'token_count' => count($storedTokens),
    'plain_token_stored' => $plainTokenStored,
    'active_resets' => count(array_filter($storedTokens, fn($r) => (int) $r['user_id'] === 1 && $r['used_at'] === null)),
    'active_sessions' => count(array_filter($after['refresh_tokens'] ?? [], fn($r) => (int) $r['user_id'] === 1 && $r['revoked_at'] === null)),
    'other_unchanged' => ($before['users'][1] === $after['users'][1])
        && array_values(array_filter($before['refresh_tokens'] ?? [], fn($r) => (int) $r['user_id'] === 2))
        === array_values(array_filter($after['refresh_tokens'] ?? [], fn($r) => (int) $r['user_id'] === 2)),
], JSON_THROW_ON_ERROR);
