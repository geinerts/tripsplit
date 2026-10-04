<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/../Fixtures/deactivation_harness.php';
$pdo = isolated_test_mysql();
$mode = $argv[1];
$index = (int) $argv[2];
$accessToken = create_access_token_for_user(1);
$requestBody = ['token' => str_repeat($mode === 'different_links' && $index % 2 ? 'b' : 'a', 64)];
echo "READY\n"; flush();
if (trim((string) fgets(STDIN)) !== 'GO') { throw new RuntimeException('Missing barrier'); }
$r = credential_test_response($mode === 'request' ? 'request_deactivation_link_action' : 'confirm_deactivation_action');
echo json_encode(['status' => $r['status'], 'mail' => count($mail), 'open' => $pdo->inTransaction()]) . "\n";
