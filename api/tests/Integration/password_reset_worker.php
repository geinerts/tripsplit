<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/../Fixtures/password_reset_harness.php';
$pdo = isolated_test_mysql();
$mode = $argv[1];
$index = (int) $argv[2];
$requestBody = $mode === 'request' ? ['email' => 'owner@example.invalid']
    : ['token' => str_repeat($mode === 'different_links' && $index % 2 ? 'b' : 'a', 64),
        'password' => 'Race-password-456-' . $index];
echo "READY\n";
flush();
if (trim((string) fgets(STDIN)) !== 'GO') { throw new RuntimeException('Missing barrier release'); }
$response = credential_test_response($mode === 'request' ? 'forgot_password_action' : 'reset_password_action');
echo json_encode(['status' => $response['status'], 'mail_count' => count($mail),
    'index' => $index, 'transaction_open' => $pdo->inTransaction()], JSON_THROW_ON_ERROR) . "\n";
