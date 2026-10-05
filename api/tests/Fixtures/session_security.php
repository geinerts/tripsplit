<?php
declare(strict_types=1);
require __DIR__ . '/session_harness.php';
$pdo = credentials_test_db();
reset_session_schema($pdo);
$accessToken = create_access_token_for_user(1, 1);
$otherToken = create_access_token_for_user(2, 3);
$scenario = $argv[1];
$result = ['before' => resolve_user_id_from_access_token($accessToken)];
switch ($scenario) {
    case 'reset':
    case 'deactivate':
    case 'reactivate':
        $result['response'] = session_event($scenario === 'reset' ? 'reset' : 'deactivate');
        if ($scenario === 'reactivate') {
            seed_lifecycle_proof($pdo, 'reactivate', 'd');
            $requestBody = ['token' => str_repeat('d', 64)];
            $result['reactivated'] = credential_test_response('confirm_reactivation_action')['status'];
        }
        $result['refresh'] = rotate_refresh_token($pdo, str_repeat('1', 96));
        break;
    case 'logout':
        revoke_refresh_token($pdo, str_repeat('1', 96));
        break;
    case 'rotate':
        $rotated = rotate_refresh_token($pdo, str_repeat('1', 96));
        $result['new_access'] = resolve_user_id_from_access_token($rotated['auth']['access_token']);
        $result['replay'] = rotate_refresh_token($pdo, str_repeat('1', 96));
        break;
    case 'expired':
        $pdo->exec("UPDATE trip_refresh_tokens SET expires_at='2000-01-01 00:00:00' WHERE id=1");
        break;
    case 'wrong_owner':
        $accessToken = create_access_token_for_user(1, 3);
        break;
    case 'legacy':
        $payload = json_decode(base64url_decode(explode('.', $accessToken)[0]), true);
        unset($payload['sid']);
        $encoded = base64url_encode(json_encode($payload));
        $accessToken = $encoded . '.' . hash_hmac('sha256', $encoded, auth_access_token_secret());
        $rotated = rotate_refresh_token($pdo, str_repeat('1', 96));
        $result['new_access'] = resolve_user_id_from_access_token($rotated['auth']['access_token']);
        break;
    case 'password_change':
        $requestBody = ['email'=>'owner@example.invalid', 'current_password'=>' Current-password-123 ',
            'password'=>'Replacement-password-456'];
        $result['response'] = credential_test_response(fn()=>change_profile_password($pdo, 1, $requestBody));
        $result['new_access'] = resolve_user_id_from_access_token($result['response']['payload']['auth']['access_token']);
        break;
    case 'stale_sensitive_request':
        $admitted = get_me();
        session_event('reset');
        $requestBody = ['email'=>'owner@example.invalid', 'current_password'=>'Replacement-password-456',
            'password'=>'Another-password-789'];
        $result['response'] = credential_test_response(fn()=>change_profile_password($pdo, $admitted['id'], $requestBody));
        break;
    case 'session_limit':
        for ($i=0; $i<AUTH_MAX_ACTIVE_SESSIONS; $i++) issue_auth_payload($pdo, 1);
        break;
    default: throw new RuntimeException('Unknown scenario');
}
$result['after'] = resolve_user_id_from_access_token($accessToken);
$result['other'] = resolve_user_id_from_access_token($otherToken);
$result['open'] = $pdo->inTransaction();
echo json_encode($result, JSON_THROW_ON_ERROR);
