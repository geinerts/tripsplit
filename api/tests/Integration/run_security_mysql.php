<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/../Fixtures/isolated_mysql.php';
isolated_test_mysql();
foreach (['run_registration_mysql.php', 'run_credentials_mysql.php', 'run_password_reset_mysql.php',
    'verify_reset_rate_limits.php', 'run_deactivation_mysql.php', 'run_lifecycle_mysql.php', 'run_session_mysql.php'] as $script) {
    $process = proc_open([PHP_BINARY, __DIR__ . '/' . $script], [STDIN, STDOUT, STDERR], $pipes);
    if (!is_resource($process) || proc_close($process) !== 0) {
        throw new RuntimeException('Isolated suite failed: ' . $script);
    }
}
$process = proc_open([PHP_BINARY, 'vendor/bin/phpunit', '--do-not-cache-result',
    '--filter', 'SocialIdentitySecurityTest'], [STDIN, STDOUT, STDERR], $pipes);
if (!is_resource($process) || proc_close($process) !== 0) {
    throw new RuntimeException('Social identity regression suite failed');
}
require __DIR__ . '/verify_social_subject_migration.php';

$process = proc_open([PHP_BINARY, 'vendor/bin/phpunit', '--do-not-cache-result',
    '--filter', 'PaymentDetailsPrivacyTest|PaymentDetailsConsentHandlerTest'], [STDIN, STDOUT, STDERR], $pipes);
if (!is_resource($process) || proc_close($process) !== 0) {
    throw new RuntimeException('Payment details privacy regression suite failed');
}
