<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/../Fixtures/credentials_harness.php';
$pdo = isolated_test_mysql();
reset_credentials_test_schema($pdo);
seed_credential_user($pdo, 'inactive');
$before = $pdo->query('SELECT id, account_status FROM trip_users ORDER BY id')->fetchAll();
$migration = file_get_contents(__DIR__ . '/../../../sql/migrations/2026-11-18-email-verification-reactivation-permission.sql');
$pdo->exec($migration);
$pdo->exec($migration);
if ($before !== $pdo->query('SELECT id, account_status FROM trip_users ORDER BY id')->fetchAll()
    || (int) $pdo->query('SELECT SUM(email_verification_can_reactivate) FROM trip_users')->fetchColumn() !== 0) {
    throw new RuntimeException('Migration changed account state or authorized legacy reactivation');
}
echo "PASS: reactivation migration applied twice, legacy accounts remain unauthorized\n";
foreach ([[PHP_BINARY, 'vendor/bin/phpunit', '--do-not-cache-result', '--filter', 'EmailSuspensionSecurityTest|SocialIdentitySecurityTest'],
    [PHP_BINARY, __DIR__ . '/verify_social_preverification_limit.php']] as $command) {
    $process = proc_open($command, [STDIN, STDOUT, STDERR], $pipes);
    if (!is_resource($process) || proc_close($process) !== 0) {
        throw new RuntimeException('Security fix regression check failed');
    }
}
