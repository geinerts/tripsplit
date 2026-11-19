<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/../bootstrap.php';
require __DIR__ . '/../Fixtures/isolated_mysql.php';
require __DIR__ . '/../../config/config_auth_logging_rate.php';
require __DIR__ . '/../../lib/actions/auth_social_actions.php';
define('TRUST_PROXY_HEADERS', false);
define('RATE_LIMIT_LOGIN_IP_MAX', 2);
define('RATE_LIMIT_LOGIN_WINDOW_SEC', 300);
$pdo = isolated_test_mysql();
$pdo->exec('DROP TABLE IF EXISTS trip_request_limits');
$pdo->exec('CREATE TABLE trip_request_limits (scope VARCHAR(48) NOT NULL,
    subject_hash CHAR(64) NOT NULL, window_start INT UNSIGNED NOT NULL, hits INT UNSIGNED NOT NULL DEFAULT 0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (scope, subject_hash, window_start)) ENGINE=InnoDB');
$_SERVER['REMOTE_ADDR'] = '192.0.2.1';
$_SERVER['HTTP_X_DEVICE_TOKEN'] = str_repeat('a', 64);
$providerCalls = 0;
function db(): PDO { return $GLOBALS['pdo']; }
function require_post(): void {}
function read_json(): array { return ['provider' => 'google', 'id_token' => 'synthetic-invalid-token']; }
function social_auth_provider_from_value(string $provider): string { return $provider; }
function verify_social_id_token(string $provider, string $token): array {
    $GLOBALS['providerCalls']++;
    json_out(['ok' => false, 'error' => 'Invalid social id token signature.'], 401);
}
foreach ([401, 401, 429] as $expected) {
    try { social_auth_action(); throw new RuntimeException('Expected denial'); }
    catch (ApiResponseException $e) { if ($e->statusCode !== $expected) { throw $e; } }
}
if ($providerCalls !== 2) { throw new RuntimeException('Limiter did not precede provider work'); }
$pdo->exec('DROP TABLE trip_request_limits');
try { social_auth_action(); throw new RuntimeException('Missing storage was accepted'); }
catch (ApiResponseException $e) { if ($e->statusCode !== 503) { throw $e; } }
if ($providerCalls !== 2) { throw new RuntimeException('Provider work ran without limiter storage'); }
echo "PASS: invalid social attempts consume real MySQL quota; blocked/missing-storage attempts do no provider work\n";
