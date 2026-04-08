<?php
declare(strict_types=1);

/**
 * Test bootstrap — loads pure helper functions without DB or HTTP dependencies.
 *
 * json_out() is replaced with an exception so validation tests can assert
 * error messages without process exit.
 */

// Exception thrown instead of exit when json_out() is called
class ApiResponseException extends RuntimeException
{
    public function __construct(
        public readonly array $payload,
        public readonly int $statusCode,
    ) {
        parent::__construct($payload['error'] ?? 'API response', $statusCode);
    }
}

// Stub: replaces the real json_out that calls exit
function json_out(array $payload, int $status = 200): void
{
    throw new ApiResponseException($payload, $status);
}

// Stub: header() not needed in unit tests
if (!function_exists('header')) {
    function header(string $header, bool $replace = true, int $responseCode = 0): void {}
}
function request_id(): string { return 'test-request-id'; }

// Stub: DB table name helper (not needed for pure logic tests)
function table_name(string $key): string
{
    return 'trip_' . $key;
}

if (!defined('DB_TABLE_PREFIX')) {
    define('DB_TABLE_PREFIX', 'trip_');
}
if (!defined('APP_BASE_URL')) {
    define('APP_BASE_URL', 'https://splyto.egm.lv');
}
if (!defined('ACCOUNT_REACTIVATION_TOKEN_TTL_SEC')) {
    define('ACCOUNT_REACTIVATION_TOKEN_TTL_SEC', 86400);
}
if (!defined('ACCOUNT_DELETION_TOKEN_TTL_SEC')) {
    define('ACCOUNT_DELETION_TOKEN_TTL_SEC', 3600);
}
if (!defined('EMAIL_VERIFICATION_REQUIRED')) {
    define('EMAIL_VERIFICATION_REQUIRED', true);
}
if (!defined('EMAIL_VERIFICATION_TOKEN_TTL_SEC')) {
    define('EMAIL_VERIFICATION_TOKEN_TTL_SEC', 86400);
}
if (!defined('EMAIL_VERIFICATION_GRACE_DAYS')) {
    define('EMAIL_VERIFICATION_GRACE_DAYS', 7);
}
if (!defined('EMAIL_VERIFICATION_CLEANUP_BATCH_LIMIT')) {
    define('EMAIL_VERIFICATION_CLEANUP_BATCH_LIMIT', 300);
}
if (!defined('EMAIL_CHANGE_TOKEN_TTL_SEC')) {
    define('EMAIL_CHANGE_TOKEN_TTL_SEC', 86400);
}

// Load pure math + validation helpers
require_once __DIR__ . '/../config/config_user_validation.php';
require_once __DIR__ . '/../lib/helpers/helper_validation.php';
require_once __DIR__ . '/../lib/helpers/helper_account_lifecycle.php';

// Load settlements pure logic
require_once __DIR__ . '/../lib/actions/settlements/settlements_core.php';
require_once __DIR__ . '/../lib/actions/settlements/settlements_algorithm.php';

// Load trip helpers (pure functions only)
require_once __DIR__ . '/../lib/helpers/helper_trip.php';
