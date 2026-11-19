<?php
declare(strict_types=1);
// Runs one admin login / 2FA scenario in its own process and prints JSON.
// SQLite only checks handler behavior; the real limits table is MySQL.
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }

require __DIR__ . '/../bootstrap.php';
foreach (['RATE_LIMIT_ADMIN_PANEL_LOGIN_IP_MAX' => 20, 'RATE_LIMIT_ADMIN_PANEL_LOGIN_USERNAME_MAX' => 10,
    'RATE_LIMIT_ADMIN_PANEL_2FA_IP_MAX' => 24, 'RATE_LIMIT_ADMIN_PANEL_2FA_TOKEN_MAX' => 12,
    'RATE_LIMIT_ADMIN_PANEL_WINDOW_SEC' => 900] as $name => $value) {
    if (!defined($name)) { define($name, $value); }
}
require_once __DIR__ . '/../../lib/helpers/helper_admin_totp.php';
require_once __DIR__ . '/../../lib/actions/admin_panel_actions.php';

final class AdminLoginSQLite extends PDO
{
    public function prepare(string $query, array $options = []): PDOStatement|false
    {
        $query = str_replace([' FOR UPDATE', 'UTC_TIMESTAMP()'], ['', "datetime('now')"], $query);
        $query = preg_replace(
            '/DELETE FROM (\S+) WHERE admin_user_id = \? ORDER BY last_active_at ASC LIMIT 1/',
            'DELETE FROM $1 WHERE token IN (SELECT token FROM $1 WHERE admin_user_id = ? ORDER BY last_active_at ASC LIMIT 1)',
            $query
        );
        return parent::prepare($query, $options);
    }

    public function query(string $query, ?int $fetchMode = null, mixed ...$args): PDOStatement|false
    {
        return parent::query(str_replace(' FOR UPDATE', '', $query));
    }
}

$pdo = new AdminLoginSQLite('sqlite::memory:', null, null, [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
]);
// NOCASE stands in for the MySQL utf8mb4_unicode_ci column (case-insensitive).
$pdo->exec('CREATE TABLE trip_admin_users (id INTEGER PRIMARY KEY, username TEXT COLLATE NOCASE UNIQUE,
    email TEXT, password_hash TEXT, role TEXT, is_active INTEGER DEFAULT 1, totp_enabled INTEGER DEFAULT 0,
    totp_secret TEXT, totp_pending_secret TEXT, totp_pending_created_at TEXT, totp_last_counter INTEGER,
    last_login_at TEXT, failed_login_count INTEGER NOT NULL DEFAULT 0, locked_until TEXT)');
$pdo->exec('CREATE TABLE trip_admin_sessions (token TEXT PRIMARY KEY, admin_user_id INTEGER, ip_address TEXT,
    user_agent TEXT, is_2fa_verified INTEGER DEFAULT 0, expires_at TEXT,
    last_active_at TEXT DEFAULT CURRENT_TIMESTAMP, created_at TEXT DEFAULT CURRENT_TIMESTAMP)');
$pdo->exec('CREATE TABLE trip_admin_audit_log (id INTEGER PRIMARY KEY AUTOINCREMENT, admin_user_id INTEGER,
    admin_username TEXT, action TEXT, target_type TEXT, target_id INTEGER, details TEXT, ip_address TEXT)');

const ADMIN_TEST_PASSWORD = 'correct horse battery staple';
$secret = admin_totp_generate_secret();
$pdo->prepare('INSERT INTO trip_admin_users (id, username, email, password_hash, role, totp_enabled, totp_secret)
    VALUES (1, ?, ?, ?, ?, 1, ?)')->execute(['owner', 'owner@example.invalid',
    password_hash(ADMIN_TEST_PASSWORD, PASSWORD_BCRYPT, ['cost' => 4]), 'superadmin', admin_totp_encrypt_secret($secret)]);

$GLOBALS['pdo'] = $pdo;
$GLOBALS['ip'] = '192.0.2.10';
$GLOBALS['requestBody'] = [];
$GLOBALS['limits'] = [];
function db(): PDO { return $GLOBALS['pdo']; }
function require_post(): void {}
function read_json(): array { return $GLOBALS['requestBody']; }
function client_ip_address(): string { return $GLOBALS['ip']; }
function enforce_rate_limit(PDO $pdo, string $scope, string $subject, int $maxHits, int $windowSeconds, bool $failClosed = false): void
{
    $key = $scope . '|' . strtolower(trim($subject));
    $GLOBALS['limits'][$key] = ($GLOBALS['limits'][$key] ?? 0) + 1;
    if ($GLOBALS['limits'][$key] > $maxHits) {
        json_out(['ok' => false, 'error' => 'Too many requests. Try again later.'], 429);
    }
}

function call_admin(callable $action, array $body, string $ip): array
{
    $GLOBALS['requestBody'] = $body;
    $GLOBALS['ip'] = $ip;
    try {
        $action();
        return ['status' => 200, 'payload' => []];
    } catch (ApiResponseException $response) {
        return ['status' => $response->statusCode, 'payload' => $response->payload];
    }
}

function login(string $username, string $password, string $ip): array
{
    return call_admin('admin_panel_login_action', ['username' => $username, 'password' => $password], $ip);
}

function newest_session_token(PDO $pdo): string
{
    // Tests cannot read the cookie, so mint a session for the known admin the
    // same way login does and return its raw token.
    return admin_create_session($pdo, 1, false);
}

function user_row(PDO $pdo): array
{
    return $pdo->query('SELECT * FROM trip_admin_users WHERE id = 1')->fetch();
}

$scenario = $argv[1] ?? '';
$out = [];
switch ($scenario) {
    case 'unknown_matches_wrong_password':
        $out['unknown'] = login('nobody', 'wrong-password-1', '192.0.2.20');
        $out['wrong'] = login('owner', 'wrong-password-1', '192.0.2.21');
        break;

    case 'others_cannot_lock_out_owner':
        for ($i = 0; $i < 12; $i++) {
            $out['attacker'][] = login('owner', 'guess-' . $i, '198.51.100.7')['status'];
        }
        $out['owner'] = login('owner', ADMIN_TEST_PASSWORD, '192.0.2.10');
        $out['user'] = user_row($pdo);
        break;

    case 'case_variants_share_one_limit':
        for ($i = 0; $i < 10; $i++) {
            login('owner', 'guess-' . $i, '198.51.100.7');
        }
        $out['variant'] = login('OWNER', 'guess-x', '198.51.100.7');
        break;

    case 'failures_are_counted':
        login('owner', 'guess-1', '198.51.100.7');
        login('owner', 'guess-2', '198.51.100.8');
        $out['user'] = user_row($pdo);
        break;

    case 'old_hash_is_upgraded':
        login('owner', ADMIN_TEST_PASSWORD, '192.0.2.10');
        $out['cost'] = password_get_info(user_row($pdo)['password_hash'])['options']['cost'] ?? null;
        $out['still_valid'] = password_verify(ADMIN_TEST_PASSWORD, user_row($pdo)['password_hash']);
        break;

    case 'twofa_limit_spans_sessions':
        $statuses = [];
        for ($session = 0; $session < 4; $session++) {
            $_COOKIE[ADMIN_SESSION_COOKIE] = newest_session_token($pdo);
            for ($i = 0; $i < 3; $i++) {
                $statuses[] = call_admin('admin_panel_verify_2fa_action', ['code' => '000000'],
                    '203.0.113.' . (10 + $session))['status'];
            }
        }
        $out['statuses'] = $statuses;
        $_COOKIE[ADMIN_SESSION_COOKIE] = newest_session_token($pdo);
        $out['correct_after_limit'] = call_admin('admin_panel_verify_2fa_action',
            ['code' => admin_totp_code($secret, intdiv(time(), 30))], '203.0.113.99')['status'];
        break;

    case 'twofa_correct_code_works':
        $_COOKIE[ADMIN_SESSION_COOKIE] = newest_session_token($pdo);
        $out['status'] = call_admin('admin_panel_verify_2fa_action',
            ['code' => admin_totp_code($secret, intdiv(time(), 30))], '203.0.113.5')['status'];
        break;

    default:
        fwrite(STDERR, "Unknown scenario\n");
        exit(1);
}
echo json_encode($out);
