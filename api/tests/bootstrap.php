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
// Stub: DB table name helper (not needed for pure logic tests)
function table_name(string $key): string
{
    return 'trip_' . $key;
}

if (!defined('DB_TABLE_PREFIX')) {
    define('DB_TABLE_PREFIX', 'trip_');
}
if (!defined('APP_BASE_URL')) {
    define('APP_BASE_URL', 'https://splyto.eu');
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
if (!defined('ADMIN_TOTP_ENCRYPTION_KEY')) {
    define('ADMIN_TOTP_ENCRYPTION_KEY', str_repeat('test-key-', 8));
}
if (!defined('RECEIPTS_REL_DIR')) {
    define('RECEIPTS_REL_DIR', 'uploads/receipts');
}
if (!defined('PRIVATE_MEDIA_SIGNING_SECRET')) {
    define('PRIVATE_MEDIA_SIGNING_SECRET', str_repeat('private-media-test-', 3));
}
if (!defined('PRIVATE_MEDIA_URL_TTL_SEC')) {
    define('PRIVATE_MEDIA_URL_TTL_SEC', 900);
}
if (!defined('APP_DEBUG')) {
    define('APP_DEBUG', false);
}
if (!defined('AUTH_MAX_ACTIVE_SESSIONS')) {
    define('AUTH_MAX_ACTIVE_SESSIONS', 8);
}

// Load pure math + validation helpers
require_once __DIR__ . '/../config/config_user_validation.php';
require_once __DIR__ . '/../lib/helpers/helper_validation.php';
require_once __DIR__ . '/../lib/helpers/helper_account_lifecycle.php';
require_once __DIR__ . '/../lib/helpers/helper_notification_preferences.php';
require_once __DIR__ . '/../lib/helpers/push/push_localization.php';
require_once __DIR__ . '/../lib/helpers/helper_admin_auth.php';
require_once __DIR__ . '/../lib/helpers/helper_auth_tokens.php';
require_once __DIR__ . '/../lib/http/action_router.php';
require_once __DIR__ . '/../config/config_uploads.php';

// Load settlements pure logic
require_once __DIR__ . '/../lib/actions/settlements/settlements_core.php';
require_once __DIR__ . '/../lib/actions/settlements/settlements_algorithm.php';
require_once __DIR__ . '/../lib/actions/settlements/settlements_payments.php';

// Load trip helpers (pure functions only)
require_once __DIR__ . '/../lib/helpers/helper_trip.php';
