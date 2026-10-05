<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/../Fixtures/credentials_harness.php';
$pdo = isolated_test_mysql();
$scenario = $argv[1];
$index = (int) $argv[2];
$accessToken = create_access_token_for_user(1, 1);
$requestBody = ['email' => $scenario === 'enroll' ? "guest$index@example.invalid" : 'owner@example.invalid',
    'password' => "New-password-456-$index", 'current_password' => ' Current-password-123 '];
echo "READY\n";
flush();
if (trim((string) fgets(STDIN)) !== 'GO') { throw new RuntimeException('Missing barrier release'); }
$response = credential_test_response($scenario === 'enroll' ? 'set_credentials_action' : 'update_profile_action');
echo json_encode(['status' => $response['status'], 'mail_count' => count($mail),
    'auth' => isset($response['payload']['auth']), 'index' => $index], JSON_THROW_ON_ERROR) . "\n";
