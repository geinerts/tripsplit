<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }

require __DIR__ . '/credentials_harness.php';
require __DIR__ . '/../../lib/helpers/helper_social_auth.php';
require __DIR__ . '/../../lib/actions/auth_social_actions.php';
define('SOCIAL_AUTH_ENABLED', true);
define('SOCIAL_AUTH_TIMEOUT_SEC', 2);
define('SOCIAL_AUTH_GOOGLE_CLIENT_IDS', 'synthetic-google-client');
define('SOCIAL_AUTH_APPLE_CLIENT_IDS', 'synthetic-apple-client');

// Only the external key download is replaced. JWT parsing, RSA signature and claim
// validation execute the production code with a throwaway signing key.
function http_get_json_assoc(string $url, int $timeout): array { return ['keys' => [$GLOBALS['jwk']]]; }
function token_from_header(): string { return str_repeat('c', 64); }

$provider = $argv[1] ?? 'google';
$scenario = $argv[2] ?? 'collision_verified';
$pdo = credentials_test_db();
reset_credentials_test_schema($pdo);
$mysql = $pdo->getAttribute(PDO::ATTR_DRIVER_NAME) === 'mysql';
$pdo->exec('ALTER TABLE trip_users ADD COLUMN avatar_path VARCHAR(255) NULL');
$pdo->exec('DROP TABLE IF EXISTS trip_user_identities');
$id = $mysql ? 'INT UNSIGNED PRIMARY KEY AUTO_INCREMENT' : 'INTEGER PRIMARY KEY AUTOINCREMENT';
// Exercise legacy production collation too: the runtime must fail closed before migration.
$subject = $mysql ? 'VARCHAR(191) CHARACTER SET ascii COLLATE ascii_general_ci' : 'TEXT COLLATE NOCASE';
$pdo->exec('CREATE TABLE trip_user_identities (id ' . $id . ', user_id INT NOT NULL,
    provider VARCHAR(10), provider_subject ' . $subject . ', email VARCHAR(255), email_verified INT,
    payload_json TEXT, last_login_at DATETIME, UNIQUE(provider, provider_subject), UNIQUE(user_id, provider))');
seed_credential_user($pdo, $scenario === 'inactive' ? 'inactive' : 'established');
if ($scenario === 'linked_unverified') {
    $pdo->exec('UPDATE trip_users SET email_verified_at = NULL WHERE id = 1');
}
$linked = str_starts_with($scenario, 'linked_') || in_array($scenario, ['inactive', 'subject_case'], true);
if ($linked) {
    $pdo->prepare('INSERT INTO trip_user_identities (user_id, provider, provider_subject, email,
        email_verified, payload_json) VALUES (1, ?, ?, ?, 1, ?)')->execute([
            $provider, 'Opaque-Subject-A', 'owner@example.invalid', '{}']);
}
if ($scenario === 'provider_mismatch') {
    $pdo->prepare('INSERT INTO trip_user_identities (user_id, provider, provider_subject, email,
        email_verified, payload_json) VALUES (1, ?, ?, ?, 1, ?)')->execute([
            $provider === 'google' ? 'apple' : 'google', 'Opaque-Subject-A', 'owner@example.invalid', '{}']);
}
$beforeUsers = $pdo->query('SELECT * FROM trip_users ORDER BY id')->fetchAll();
$beforeIdentities = $pdo->query('SELECT * FROM trip_user_identities ORDER BY id')->fetchAll();
$beforeSessions = $pdo->query('SELECT * FROM trip_refresh_tokens ORDER BY id')->fetchAll();

$randFile = tempnam(sys_get_temp_dir(), 'splyto-test-rng-');
if ($randFile === false) { throw new RuntimeException('Cannot allocate test RNG file'); }
putenv('SPLYTO_TEST_RAND_FILE=' . $randFile);
try {
    $key = openssl_pkey_new(['private_key_bits' => 2048, 'private_key_type' => OPENSSL_KEYTYPE_RSA,
        'config' => __DIR__ . '/openssl-test.cnf']);
} finally {
    unlink($randFile);
    putenv('SPLYTO_TEST_RAND_FILE');
}
if ($key === false) { throw new RuntimeException('Cannot create synthetic signing key'); }
$details = openssl_pkey_get_details($key);
$jwk = ['kty' => 'RSA', 'kid' => 'synthetic-key', 'alg' => 'RS256',
    'n' => base64url_encode($details['rsa']['n']), 'e' => base64url_encode($details['rsa']['e'])];
$claims = ['iss' => $provider === 'google' ? 'https://accounts.google.com' : 'https://appleid.apple.com',
    'aud' => 'synthetic-' . $provider . '-client', 'sub' => 'Opaque-Subject-A',
    'iat' => time(), 'exp' => time() + 3600, 'email' => 'owner@example.invalid', 'email_verified' => true];
if (str_starts_with($scenario, 'new_')) { $claims['email'] = 'new@example.invalid'; }
if (in_array($scenario, ['collision_false', 'new_false', 'linked_false'], true)) { $claims['email_verified'] = false; }
if ($scenario === 'collision_string_false') { $claims['email_verified'] = 'false'; }
if ($scenario === 'new_string_true') { $claims['email_verified'] = 'true'; }
if (in_array($scenario, ['collision_missing', 'new_missing', 'linked_missing'], true)) { unset($claims['email_verified']); }
if (in_array($scenario, ['new_no_email', 'linked_no_email'], true)) { unset($claims['email']); }
if ($scenario === 'linked_changed_email') { $claims['email'] = 'other@example.invalid'; }
if ($scenario === 'linked_different_subject') { $claims['sub'] = 'Unlinked-Subject-B'; }
if ($scenario === 'subject_case') { $claims['sub'] = 'opaque-subject-a'; }
if ($scenario === 'wrong_issuer') { $claims['iss'] = 'https://attacker.example.invalid'; }
if ($scenario === 'wrong_audience') { $claims['aud'] = 'other-client'; }
if ($scenario === 'expired') { $claims['exp'] = time() - 3600; }
if ($scenario === 'future') { $claims['iat'] = time() + 3600; }
if ($scenario === 'missing_subject') { unset($claims['sub']); }
$header = ['alg' => $scenario === 'wrong_algorithm' ? 'HS256' : 'RS256', 'kid' => 'synthetic-key'];
$signed = base64url_encode(json_encode($header)) . '.' . base64url_encode(json_encode($claims));
if (!openssl_sign($signed, $signature, $key, OPENSSL_ALGO_SHA256)) { throw new RuntimeException('Signing failed'); }
if ($scenario === 'bad_signature') { $signature[0] = chr(ord($signature[0]) ^ 1); }
$requestBody = ['provider' => $provider, 'id_token' => $signed . '.' . base64url_encode($signature),
    'email' => 'client-supplied@example.invalid', 'full_name' => 'Synthetic Person'];
$response = credential_test_response('social_auth_action');
$afterUsers = $pdo->query('SELECT * FROM trip_users ORDER BY id')->fetchAll();
$afterIdentities = $pdo->query('SELECT * FROM trip_user_identities ORDER BY id')->fetchAll();
$afterSessions = $pdo->query('SELECT * FROM trip_refresh_tokens ORDER BY id')->fetchAll();
$userId = $response['payload']['me']['id'] ?? null;
$authenticated = $userId === null ? null : fetch_me_row_by_id($pdo, $userId);
echo json_encode(['response' => $response, 'users_unchanged' => $beforeUsers === $afterUsers,
    'identities_unchanged' => $beforeIdentities === $afterIdentities,
    'sessions_unchanged' => $beforeSessions === $afterSessions,
    'user_count' => count($afterUsers), 'identity_count' => count($afterIdentities),
    'session_count' => count($afterSessions), 'mail_count' => count($mail),
    'authenticated_email' => $authenticated['email'] ?? null,
    'authenticated_verified' => !empty($authenticated['email_verified_at']),
    'original_email' => $afterUsers[0]['email'],
    'original_verified' => $afterUsers[0]['email_verified_at'] !== null,
    'original_hash_unchanged' => $beforeUsers[0]['password_hash'] === $afterUsers[0]['password_hash'],
    'other_unchanged' => $beforeUsers[1] === $afterUsers[1],
    'transaction_open' => $pdo->inTransaction()], JSON_THROW_ON_ERROR);
