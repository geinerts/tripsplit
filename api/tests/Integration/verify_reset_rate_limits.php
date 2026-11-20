<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/../bootstrap.php';
require __DIR__ . '/../Fixtures/isolated_mysql.php';
require __DIR__ . '/../../config/config_auth_logging_rate.php';
$pdo = isolated_test_mysql();
$pdo->exec('DROP TABLE IF EXISTS trip_request_limits');
$pdo->exec('CREATE TABLE trip_request_limits (scope VARCHAR(48) NOT NULL,
    subject_hash CHAR(64) NOT NULL, window_start INT UNSIGNED NOT NULL, hits INT UNSIGNED NOT NULL DEFAULT 0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (scope, subject_hash, window_start)) ENGINE=InnoDB');
foreach ([['password_reset_request_ip', 10, 900], ['password_reset_request_email', 3, 3600],
    ['password_reset_confirm_ip', 20, 900],
    ['password_reset_confirm_token', 5, 900]] as [$scope, $max, $window]) {
    for ($i = 0; $i < $max; $i++) { enforce_rate_limit($pdo, $scope, 'synthetic-subject', $max, $window, true); }
    try {
        enforce_rate_limit($pdo, $scope, 'SYNTHETIC-SUBJECT', $max, $window, true);
        throw new RuntimeException('Rate limit did not block: ' . $scope);
    } catch (ApiResponseException $e) {
        if ($e->statusCode !== 429) { throw $e; }
    }
    enforce_rate_limit($pdo, $scope, 'unrelated-subject', $max, $window, true);
}
// Storage check sees the table while it exists.
if (security_limit_storage_status($pdo)['request_limits'] !== true) {
    throw new RuntimeException('Storage check missed an existing limits table');
}
$pdo->exec('DROP TABLE trip_request_limits');
ini_set('error_log', '/dev/null'); // the refusals below are logged on purpose
// Every limit fails closed by default, and the old fail-open flag is ignored.
foreach ([[], [false], [true]] as $flag) {
    try {
        enforce_rate_limit($pdo, 'password_reset_request_ip', 'synthetic-subject', 10, 900, ...$flag);
        throw new RuntimeException('Missing limiter storage did not fail closed');
    } catch (ApiResponseException $e) {
        if ($e->statusCode !== 503) { throw $e; }
    }
}
$pdo->exec('DROP TABLE IF EXISTS trip_upload_daily_usage');
try {
    enforce_upload_daily_quota($pdo, 'user', 7, 1000, 60, 1_000_000);
    throw new RuntimeException('Missing upload quota storage did not fail closed');
} catch (ApiResponseException $e) {
    if ($e->statusCode !== 503) { throw $e; }
}
$storage = security_limit_storage_status($pdo);
if ($storage['request_limits'] !== false || $storage['upload_daily_usage'] !== false) {
    throw new RuntimeException('Storage check did not report missing limit tables');
}
echo "PASS: real MySQL limiter thresholds, subject isolation, fail-closed limits and quota, storage check\n";
