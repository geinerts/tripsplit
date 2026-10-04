<?php
declare(strict_types=1);

// Shared CLI-only adapters. Callers provide a synthetic PDO connection and $hasNames.
if (PHP_SAPI !== 'cli') {
    http_response_code(404);
    exit;
}

final class RegistrationResponse extends RuntimeException
{
    public function __construct(public array $payload, public int $status)
    {
        parent::__construct('Test response');
    }
}

define('REGISTER_PROOF_SECRET', str_repeat('synthetic-registration-only-', 2));
define('REGISTER_PROOF_MAX_AGE_SEC', 900);
foreach (['RATE_LIMIT_REGISTER_PROOF_IP_MAX', 'RATE_LIMIT_REGISTER_PROOF_TOKEN_MAX',
    'RATE_LIMIT_REGISTER_IP_MAX', 'RATE_LIMIT_REGISTER_TOKEN_MAX',
    'RATE_LIMIT_REGISTER_WINDOW_SEC'] as $name) {
    define($name, 100);
}

$authIssued = [];
$verificationMail = [];
$events = [];
$rateCalls = [];
$requestBody = [];
function db(): PDO { return $GLOBALS['pdo']; }
function table_name(string $key): string { return 'trip_' . $key; }
function json_out(array $payload, int $status = 200): void { throw new RegistrationResponse($payload, $status); }
function require_post(): void {}
function read_json(): array { return $GLOBALS['requestBody']; }
function client_ip_address(): string { return '192.0.2.1'; }
function enforce_rate_limit(PDO $pdo, string $scope, ...$args): void { $GLOBALS['rateCalls'][] = $scope; }
function users_name_columns_available(PDO $pdo): bool { return $GLOBALS['hasNames']; }
function validate_token(string $token): string {
    if (!preg_match('/^[a-f0-9]{64}$/', $token)) { json_out(['ok' => false], 400); }
    return $token;
}
function token_from_header(): string { return validate_token($_SERVER['HTTP_X_DEVICE_TOKEN'] ?? ''); }
function credential_password_algo(): string { return PASSWORD_BCRYPT; }
function fetch_me_row_by_id(PDO $pdo, int $id): ?array {
    $stmt = $pdo->prepare('SELECT * FROM trip_users WHERE id = ?');
    $stmt->execute([$id]);
    return $stmt->fetch() ?: null;
}
function assert_user_account_is_active(array $user): void {
    if ($user['account_status'] !== 'active') { json_out(['ok' => false], 403); }
}
function user_requires_email_verification(array $user): bool {
    return !empty($user['email']) && empty($user['email_verified_at']);
}
function send_email_verification_link_for_user(PDO $pdo, array $user): void {
    $GLOBALS['verificationMail'][] = (int) $user['id'];
}
function build_me_payload(array $user, ?PDO $pdo = null): array { return ['id' => (int) $user['id']]; }
function issue_auth_payload(PDO $pdo, int $userId): array {
    $GLOBALS['authIssued'][] = $userId;
    return ['synthetic_user_id' => $userId];
}
function app_event(PDO $pdo, int $userId, ...$args): void { $GLOBALS['events'][] = $userId; }

require __DIR__ . '/../../lib/helpers/helper_validation.php';
require __DIR__ . '/../../config/config_user_validation.php';
require __DIR__ . '/../../lib/actions/auth_actions.php';

function runRegistrationHandler(callable $handler): array {
    try { $handler(); } catch (RegistrationResponse $response) {
        return ['status' => $response->status, 'payload' => $response->payload];
    }
    throw new RuntimeException('Handler did not respond');
}
