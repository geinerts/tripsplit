<?php
declare(strict_types=1);

if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }

require __DIR__ . '/../bootstrap.php';
require __DIR__ . '/isolated_mysql.php';
require __DIR__ . '/../../lib/actions/auth_actions.php';
require __DIR__ . '/../../lib/actions/email_verification_actions.php';
require __DIR__ . '/../../lib/actions/email_change_actions.php';

foreach (['AUTH_ACCESS_TOKEN_SECRET' => str_repeat('synthetic-credentials-only-', 3),
    'AUTH_ACCESS_TOKEN_TTL_SEC' => 900, 'AUTH_REFRESH_TOKEN_TTL_SEC' => 2592000,
    'RATE_LIMIT_LOGIN_IP_MAX' => 20, 'RATE_LIMIT_LOGIN_EMAIL_MAX' => 5,
    'RATE_LIMIT_LOGIN_WINDOW_SEC' => 300, 'RATE_LIMIT_TRIP_WRITE_USER_MAX' => 20,
    'RATE_LIMIT_TRIP_WRITE_WINDOW_SEC' => 300] as $name => $value) {
    define($name, $value);
}

// SQLite only checks handler behavior; InnoDB locking is verified separately in Docker.
class_alias(class_exists('Pdo\\Sqlite') ? 'Pdo\\Sqlite' : PDO::class, 'CredentialsSQLiteBase');
final class CredentialsSQLite extends CredentialsSQLiteBase
{
    public function prepare(string $query, array $options = []): PDOStatement|false
    {
        if (str_contains($query, 'information_schema.tables')) {
            $query = "SELECT COUNT(*) FROM sqlite_master WHERE type = 'table' AND name = :table_name";
        } elseif (str_contains($query, 'information_schema.columns')) {
            if (str_starts_with($query, 'SELECT column_name')) {
                return parent::prepare('SELECT name FROM pragma_table_info(:table_name)', $options);
            }
            preg_match("/column_name = '([^']+)'/", $query, $match);
            if (!isset($match[1])) { throw new RuntimeException('Unsupported schema query'); }
            $query = "SELECT COUNT(*) FROM pragma_table_info(:table_name) WHERE name = '" . $match[1] . "'";
        }
        $query = str_replace('FOR UPDATE', '', $query);
        return parent::prepare($query, $options);
    }
}

function credentials_test_db(): PDO
{
    if (getenv('SPLYTO_ISOLATED_MYSQL') === '1') { return isolated_test_mysql(); }
    $pdo = new CredentialsSQLite('sqlite::memory:', null, null, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC]);
    $method = method_exists($pdo, 'createFunction') ? 'createFunction' : 'sqliteCreateFunction';
    $pdo->$method('UTC_TIMESTAMP', static fn(): string => gmdate('Y-m-d H:i:s'));
    return $pdo;
}

function reset_credentials_test_schema(PDO $pdo): void
{
    $mysql = $pdo->getAttribute(PDO::ATTR_DRIVER_NAME) === 'mysql';
    if ($mysql) {
        // This check must precede all destructive synthetic-schema operations.
        reset_registration_mysql_schema($pdo);
    } else {
        $pdo->exec('CREATE TABLE trip_users (id INTEGER PRIMARY KEY AUTOINCREMENT,
            nickname TEXT, first_name TEXT, last_name TEXT, email TEXT UNIQUE, password_hash TEXT,
            credentials_required INTEGER DEFAULT 1, email_verified_at TEXT,
            account_status TEXT DEFAULT \'active\', device_token TEXT UNIQUE)');
    }
    $id = $mysql ? 'INT UNSIGNED PRIMARY KEY AUTO_INCREMENT' : 'INTEGER PRIMARY KEY AUTOINCREMENT';
    foreach (['refresh_tokens', 'email_verification_tokens', 'email_change_requests'] as $table) {
        $pdo->exec('DROP TABLE IF EXISTS trip_' . $table);
    }
    $pdo->exec('CREATE TABLE trip_refresh_tokens (id ' . $id . ', user_id INT NOT NULL,
        token_hash VARCHAR(64) UNIQUE, expires_at DATETIME, revoked_at DATETIME NULL,
        user_agent VARCHAR(255), ip_address VARCHAR(45), last_used_at DATETIME)');
    $pdo->exec('CREATE TABLE trip_email_verification_tokens (id ' . $id . ', user_id INT,
        email VARCHAR(255), token_hash VARCHAR(64) UNIQUE, expires_at DATETIME, used_at DATETIME NULL)');
    $pdo->exec('CREATE TABLE trip_email_change_requests (id ' . $id . ', user_id INT,
        old_email VARCHAR(255), new_email VARCHAR(255), verify_token_hash VARCHAR(64) UNIQUE,
        cancel_token_hash VARCHAR(64) UNIQUE, expires_at DATETIME, consumed_at DATETIME NULL,
        verified_at DATETIME NULL, cancelled_at DATETIME NULL)');
}

$requestBody = $mail = $rates = [];
$mailSucceeds = true;
function db(): PDO { return $GLOBALS['pdo']; }
function require_post(): void {}
function read_json(): array { return $GLOBALS['requestBody']; }
function bearer_access_token_from_header(): string { return $GLOBALS['accessToken'] ?? ''; }
function client_ip_address(): string { return '192.0.2.1'; }
function enforce_rate_limit(PDO $pdo, string $scope, ...$args): void { $GLOBALS['rates'][] = $scope; }
function credential_password_algo(): string { return PASSWORD_BCRYPT; }
function users_name_columns_available(PDO $pdo): bool { return true; }
function users_payment_columns_available(PDO $pdo): bool { return false; }
function users_revolut_me_link_column_available(PDO $pdo): bool { return false; }
function users_wise_pay_link_column_available(PDO $pdo): bool { return false; }
function users_preferred_currency_column_available(PDO $pdo): bool { return false; }
function fetch_me_row_by_id(PDO $pdo, int $id): ?array {
    $stmt = $pdo->prepare('SELECT * FROM trip_users WHERE id = ?');
    $stmt->execute([$id]);
    return $stmt->fetch() ?: null;
}
function build_me_payload(array $user, ?PDO $pdo = null): array {
    return ['id' => (int) $user['id'], 'email' => $user['email']];
}
function build_email_verification_email(string $url, ...$args): string { return $url; }
function build_email_change_verification_email(string $url, ...$args): string { return $url; }
function build_email_change_security_email(string $url, ...$args): string { return $url; }
function send_email_via_resend(string $to, string $subject, string $html): bool {
    $GLOBALS['mail'][] = ['to' => $to, 'body' => $html];
    return $GLOBALS['mailSucceeds'];
}
function credential_test_response(callable $action): array {
    try { $action(); } catch (ApiResponseException $response) {
        return ['status' => $response->statusCode, 'payload' => $response->payload];
    }
    throw new RuntimeException('Missing handler response');
}
function seed_credential_user(PDO $pdo, string $state = 'established'): void {
    $guest = $state === 'guest';
    $hash = $guest ? null : password_hash(' Current-password-123 ', PASSWORD_BCRYPT, ['cost' => 4]);
    $email = $guest ? null : 'owner@example.invalid';
    $flag = $guest ? 1 : 0;
    $verified = $guest || $state === 'unverified' ? null : '2026-01-01 00:00:00';
    if ($state === 'partial_email') { $flag = 1; $hash = null; $verified = null; }
    if ($state === 'partial_hash') { $flag = 1; $email = null; $verified = null; }
    if ($state === 'social') { $hash = password_hash(bin2hex(random_bytes(24)), PASSWORD_BCRYPT, ['cost' => 4]); }
    $pdo->prepare('INSERT INTO trip_users (nickname, email, password_hash, credentials_required,
        email_verified_at, device_token, account_status) VALUES (?, ?, ?, ?, ?, ?, ?)')->execute([
            'Synthetic Owner', $email, $hash, $flag, $verified, str_repeat('a', 64),
            $state === 'inactive' ? 'deactivated' : 'active']);
    $pdo->prepare('INSERT INTO trip_users (nickname, email, credentials_required, device_token)
        VALUES (?, ?, 1, ?)')->execute(['Unrelated', 'other@example.invalid', str_repeat('b', 64)]);
    foreach ([1, 1, 2] as $index => $userId) {
        $pdo->prepare('INSERT INTO trip_refresh_tokens (user_id, token_hash, expires_at)
            VALUES (?, ?, ?)')->execute([$userId, hash('sha256', str_repeat((string) ($index + 1), 96)),
                gmdate('Y-m-d H:i:s', time() + 3600)]);
    }
}

function fail_credential_session_write(PDO $pdo, string $operation): void {
    $mysql = $pdo->getAttribute(PDO::ATTR_DRIVER_NAME) === 'mysql';
    $pdo->exec('CREATE TRIGGER fail_sessions BEFORE ' . $operation . ' ON trip_refresh_tokens '
        . ($mysql ? "FOR EACH ROW SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Synthetic write failure'"
            : "BEGIN SELECT RAISE(ABORT, 'Synthetic write failure'); END"));
}
