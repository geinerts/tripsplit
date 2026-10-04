<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/credentials_harness.php';
$scenario = $argv[1] ?? '';
$pdo = credentials_test_db();
reset_credentials_test_schema($pdo);
$enroll = str_starts_with($scenario, 'enroll_');
$state = $enroll ? substr($scenario, 7) : 'established';
if (in_array($state, ['success', 'duplicate', 'mail_failure', 'rollback', 'replay', 'verify'], true)) { $state = 'guest'; }
if ($scenario === 'password_social') { $state = 'social'; }
if ($scenario === 'password_unverified') { $state = 'unverified'; }
seed_credential_user($pdo, $state);
$accessToken = create_access_token_for_user(1);
$beforeUser = fetch_me_row_by_id($pdo, 1);
$beforeOther = fetch_me_row_by_id($pdo, 2);
$beforeSessions = $pdo->query('SELECT * FROM trip_refresh_tokens ORDER BY id')->fetchAll();
$requestBody = ['email' => $enroll ? 'new@example.invalid' : 'owner@example.invalid',
    'password' => 'New-password-456'];
if (!$enroll) { $requestBody['current_password'] = ' Current-password-123 '; }
if ($scenario === 'enroll_duplicate') { $requestBody['email'] = 'other@example.invalid'; }
if ($scenario === 'enroll_mail_failure') { $mailSucceeds = false; }
if ($scenario === 'password_missing') { unset($requestBody['current_password']); }
if ($scenario === 'password_wrong') { $requestBody['current_password'] = 'Wrong-password'; }
if ($scenario === 'password_trimmed') { $requestBody['current_password'] = trim($requestBody['current_password']); }
if ($scenario === 'password_email_change') { $requestBody['email'] = 'new@example.invalid'; }
if ($scenario === 'password_partial') { unset($requestBody['password']); }
if ($scenario === 'password_mixed') { $requestBody['first_name'] = 'Injected'; $requestBody['last_name'] = 'Name'; }
if ($scenario === 'profile') { $requestBody = ['first_name' => 'Updated', 'last_name' => 'Owner']; }
if ($scenario === 'anonymous') { $accessToken = ''; }
if (in_array($scenario, ['enroll_rollback', 'password_rollback', 'email_rollback'], true)) {
    fail_credential_session_write($pdo, 'UPDATE');
}
if ($scenario === 'password_issue_failure') { fail_credential_session_write($pdo, 'INSERT'); }
if ($scenario === 'missing_sessions') { $pdo->exec('DROP TABLE trip_refresh_tokens'); }
if (str_starts_with($scenario, 'email_')) {
    $pdo->prepare('INSERT INTO trip_email_change_requests
        (user_id, old_email, new_email, verify_token_hash, cancel_token_hash, expires_at)
        VALUES (1, ?, ?, ?, ?, ?)')->execute(['owner@example.invalid', 'new@example.invalid',
        hash('sha256', str_repeat('a', 64)), hash('sha256', str_repeat('b', 64)),
        gmdate('Y-m-d H:i:s', time() + 3600)]);
    $requestBody = ['token' => str_repeat('a', 64), 'new_email' => 'new@example.invalid'];
}
$action = $enroll ? 'set_credentials_action' : 'update_profile_action';
if (str_starts_with($scenario, 'email_')) {
    $action = match ($scenario) {
        'email_request' => 'request_email_change',
        'email_cancel' => 'cancel_email_change',
        default => 'confirm_email_change',
    };
    $action = fn() => dispatch_api_action($action);
}
$databaseError = false;
try { $response = credential_test_response($action); } catch (PDOException $error) {
    $databaseError = true;
    $response = ['status' => 500, 'payload' => []];
}
$firstResponse = $response;
if ($scenario === 'enroll_replay') { $response = credential_test_response($action); }
if ($scenario === 'enroll_verify') {
    parse_str((string) parse_url($mail[0]['body'], PHP_URL_QUERY), $query);
    $requestBody = ['token' => $query['token']];
    $response = credential_test_response('confirm_email_verification_action');
}
$afterUser = fetch_me_row_by_id($pdo, 1);
$sessions = $scenario === 'missing_sessions' ? [] : $pdo->query('SELECT * FROM trip_refresh_tokens ORDER BY id')->fetchAll();
$pending = $pdo->query('SELECT consumed_at FROM trip_email_change_requests')->fetchColumn();
echo json_encode([
    'response' => $response, 'first_response' => $firstResponse,
    'user_unchanged' => $beforeUser === $afterUser,
    'other_unchanged' => $beforeOther === fetch_me_row_by_id($pdo, 2),
    'sessions_unchanged' => $sessions === $beforeSessions,
    'old_sessions_revoked' => count(array_filter($sessions, static fn(array $r): bool =>
        (int) $r['user_id'] === 1 && (int) $r['id'] <= 2 && $r['revoked_at'] !== null)),
    'active_sessions' => count(array_filter($sessions, static fn(array $r): bool =>
        (int) $r['user_id'] === 1 && $r['revoked_at'] === null)),
    'other_session_active' => $sessions === [] ? false : $sessions[2]['revoked_at'] === null,
    'new_password_matches' => password_verify('New-password-456', (string) $afterUser['password_hash']),
    'email' => $afterUser['email'], 'verified' => !empty($afterUser['email_verified_at']),
    'mail_count' => count($mail), 'rates' => $rates, 'database_error' => $databaseError,
    'transaction_open' => $pdo->inTransaction(), 'email_change_consumed' => is_string($pending),
], JSON_THROW_ON_ERROR);
