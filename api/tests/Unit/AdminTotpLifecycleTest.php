<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

require_once __DIR__ . '/../../config/config_auth_logging_rate.php';
if (!defined('TRUST_PROXY_HEADERS')) define('TRUST_PROXY_HEADERS', false);
if (!defined('ADMIN_TOTP_ENCRYPTION_KEY_PREVIOUS')) define('ADMIN_TOTP_ENCRYPTION_KEY_PREVIOUS', str_repeat('old-totp-key-', 4));

/** SQLite has no row locks; the lifecycle runs in real transactions otherwise. */
final class AdminTotpTestDatabase extends PDO
{
    public function __construct()
    {
        parent::__construct('sqlite::memory:', null, null, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
        $this->exec('CREATE TABLE trip_admin_users (id INTEGER PRIMARY KEY, username TEXT, password_hash TEXT,
            is_active INTEGER, totp_enabled INTEGER DEFAULT 0, totp_secret TEXT, totp_pending_secret TEXT,
            totp_pending_created_at TEXT, totp_last_counter INTEGER)');
        $this->exec('CREATE TABLE trip_admin_sessions (token TEXT PRIMARY KEY, admin_user_id INTEGER, is_2fa_verified INTEGER)');
        $this->exec('CREATE TABLE trip_admin_audit_log (id INTEGER PRIMARY KEY AUTOINCREMENT, admin_user_id INTEGER,
            admin_username TEXT, action TEXT, target_type TEXT, target_id INTEGER, details TEXT, ip_address TEXT)');
    }

    public function prepare(string $query, array $options = []): PDOStatement|false
    {
        return parent::prepare(str_replace(' FOR UPDATE', '', $query), $options);
    }

    public function query(string $query, ?int $fetchMode = null, mixed ...$args): PDOStatement|false
    {
        return parent::query(str_replace(' FOR UPDATE', '', $query));
    }
}

final class AdminTotpLifecycleTest extends TestCase
{
    private const PASSWORD = 'correct horse battery staple';
    private AdminTotpTestDatabase $pdo;
    private int $now;

    protected function setUp(): void
    {
        $this->pdo = new AdminTotpTestDatabase();
        $this->now = 1_800_000_000;
        $hash = password_hash(self::PASSWORD, PASSWORD_BCRYPT, ['cost' => 4]);
        $this->pdo->prepare('INSERT INTO trip_admin_users (id, username, password_hash, is_active) VALUES (1, ?, ?, 1)')
            ->execute(['owner', $hash]);
        $this->pdo->exec("INSERT INTO trip_admin_sessions VALUES ('current', 1, 0), ('other', 1, 1)");
    }

    private function session(int $verified = 0): array
    {
        $user = $this->user();
        return ['token' => 'current', 'admin_user_id' => 1, 'username' => 'owner', 'role' => 'superadmin',
            'totp_enabled' => (int) $user['totp_enabled'], 'is_2fa_verified' => $verified];
    }

    private function user(): array
    {
        return $this->pdo->query('SELECT * FROM trip_admin_users WHERE id = 1')->fetch(PDO::FETCH_ASSOC);
    }

    private function sessionTokens(): array
    {
        return $this->pdo->query('SELECT token FROM trip_admin_sessions ORDER BY token')->fetchAll(PDO::FETCH_COLUMN);
    }

    private function code(string $secret, int $at): string
    {
        return admin_totp_code($secret, intdiv($at, 30));
    }

    private function expectResponse(int $status, string $code, callable $call): void
    {
        try {
            $call();
            self::fail('Expected a refused request.');
        } catch (ApiResponseException $response) {
            self::assertSame($status, $response->statusCode);
            self::assertSame($code, $response->payload['code'] ?? null);
        }
        self::assertFalse($this->pdo->inTransaction());
    }

    private function enrol(): string
    {
        $setup = admin_totp_begin_setup($this->pdo, $this->session(), ['password' => self::PASSWORD], $this->now);
        admin_totp_confirm_setup($this->pdo, $this->session(),
            ['code' => $this->code($setup['secret'], $this->now)], $this->now);
        return $setup['secret'];
    }

    public function test_password_only_session_is_refused_and_must_enrol(): void
    {
        self::assertSame('2fa_enrollment_required',
            admin_session_denial(['totp_enabled' => 0, 'is_2fa_verified' => 1])['code']);
        self::assertSame('2fa_required', admin_session_denial(['totp_enabled' => 1, 'is_2fa_verified' => 0])['code']);
        self::assertNull(admin_session_denial(['totp_enabled' => 1, 'is_2fa_verified' => '1']));
    }

    public function test_enrolment_needs_password_and_keeps_secret_pending_until_confirmed(): void
    {
        $this->expectResponse(403, 'reauthentication_required', fn() =>
            admin_totp_begin_setup($this->pdo, $this->session(), ['password' => 'wrong'], $this->now));

        $setup = admin_totp_begin_setup($this->pdo, $this->session(), ['password' => self::PASSWORD], $this->now);
        $user = $this->user();
        self::assertFalse($setup['replacing']);
        self::assertSame(0, (int) $user['totp_enabled']);
        self::assertNull($user['totp_secret']);
        self::assertStringStartsWith('enc:v1:', $user['totp_pending_secret']);
        self::assertStringNotContainsString($setup['secret'], $user['totp_pending_secret']);

        $this->expectResponse(400, '2fa_invalid', fn() =>
            admin_totp_confirm_setup($this->pdo, $this->session(), ['code' => '000000'], $this->now));

        $result = admin_totp_confirm_setup($this->pdo, $this->session(),
            ['code' => $this->code($setup['secret'], $this->now)], $this->now);
        $user = $this->user();
        self::assertSame(['replaced' => false, 'revoked_sessions' => 1], $result);
        self::assertSame(1, (int) $user['totp_enabled']);
        self::assertSame($setup['secret'], admin_totp_decrypt_secret($user['totp_secret']));
        self::assertNull($user['totp_pending_secret']);
        self::assertSame(['current'], $this->sessionTokens());
        self::assertSame(1, (int) $this->pdo->query("SELECT is_2fa_verified FROM trip_admin_sessions")->fetchColumn());
        self::assertSame('admin.totp.enable',
            $this->pdo->query('SELECT action FROM trip_admin_audit_log ORDER BY id DESC')->fetchColumn());
    }

    public function test_pending_setup_expires(): void
    {
        $setup = admin_totp_begin_setup($this->pdo, $this->session(), ['password' => self::PASSWORD], $this->now);
        $later = $this->now + ADMIN_TOTP_PENDING_TTL_SEC + 1;
        $this->expectResponse(409, 'totp_setup_expired', fn() => admin_totp_confirm_setup($this->pdo,
            $this->session(), ['code' => $this->code($setup['secret'], $later)], $later));
        self::assertSame(0, (int) $this->user()['totp_enabled']);
    }

    public function test_replacement_needs_verified_session_password_and_current_code(): void
    {
        $old = $this->enrol();
        $before = $this->user()['totp_secret'];
        $at = $this->now + 90;
        $body = ['password' => self::PASSWORD, 'current_code' => $this->code($old, $at)];

        $this->expectResponse(401, '2fa_required', fn() =>
            admin_totp_begin_setup($this->pdo, $this->session(0), $body, $at));
        $this->expectResponse(403, 'reauthentication_required', fn() => admin_totp_begin_setup(
            $this->pdo, $this->session(1), ['password' => 'wrong'] + $body, $at));
        $this->expectResponse(403, 'current_2fa_required', fn() => admin_totp_begin_setup(
            $this->pdo, $this->session(1), ['current_code' => ''] + $body, $at));
        $this->expectResponse(409, 'totp_setup_expired', fn() => admin_totp_confirm_setup(
            $this->pdo, $this->session(1), ['code' => '123456'], $at));
        self::assertSame($before, $this->user()['totp_secret']);
        self::assertNull($this->user()['totp_pending_secret']);
    }

    public function test_old_authenticator_works_until_replacement_is_confirmed(): void
    {
        $old = $this->enrol();
        $this->pdo->exec("INSERT INTO trip_admin_sessions VALUES ('laptop', 1, 1)");
        $at = $this->now + 90;
        $setup = admin_totp_begin_setup($this->pdo, $this->session(1),
            ['password' => self::PASSWORD, 'current_code' => $this->code($old, $at)], $at);
        self::assertTrue($setup['replacing']);

        $login = $at + 60;
        self::assertSame('ok', admin_totp_verify_login($this->pdo, $this->session(), $this->code($old, $login), $login));

        $confirm = $login + 30;
        $result = admin_totp_confirm_setup($this->pdo, $this->session(1),
            ['code' => $this->code($setup['secret'], $confirm)], $confirm);
        self::assertSame(['replaced' => true, 'revoked_sessions' => 1], $result);
        self::assertSame(['current'], $this->sessionTokens());

        $next = $confirm + 60;
        self::assertSame('invalid', admin_totp_verify_login($this->pdo, $this->session(), $this->code($old, $next), $next));
        self::assertSame('ok', admin_totp_verify_login($this->pdo, $this->session(),
            $this->code($setup['secret'], $next), $next));
    }

    public function test_accepted_code_cannot_be_used_again(): void
    {
        $secret = $this->enrol();
        $at = $this->now + 120;
        $code = $this->code($secret, $at);
        self::assertSame('ok', admin_totp_verify_login($this->pdo, $this->session(), $code, $at));
        self::assertSame('invalid', admin_totp_verify_login($this->pdo, $this->session(), $code, $at));
        // The confirmation code from enrolment is spent as well.
        self::assertSame('invalid', admin_totp_verify_login($this->pdo, $this->session(),
            $this->code($secret, $this->now), $this->now));
    }

    public function test_login_code_for_account_without_2fa_requires_enrolment(): void
    {
        self::assertSame('enrollment_required', admin_totp_verify_login($this->pdo, $this->session(), '123456', $this->now));
        self::assertSame(0, (int) $this->pdo->query("SELECT is_2fa_verified FROM trip_admin_sessions WHERE token = 'current'")->fetchColumn());
    }

    public function test_reset_removes_2fa_and_signs_out_everywhere(): void
    {
        $this->enrol();
        self::assertSame(1, admin_totp_reset_user($this->pdo, 1));
        $user = $this->user();
        self::assertSame(0, (int) $user['totp_enabled']);
        self::assertNull($user['totp_secret']);
        self::assertNull($user['totp_last_counter']);
        self::assertSame([], $this->sessionTokens());
    }

    public function test_key_rotation_reencrypts_with_current_key(): void
    {
        $previousKey = hash('sha256', ADMIN_TOTP_ENCRYPTION_KEY_PREVIOUS, true);
        $currentKey = admin_totp_encryption_key_bytes();
        $secret = admin_totp_generate_secret();
        $this->pdo->prepare('UPDATE trip_admin_users SET totp_enabled = 1, totp_secret = ? WHERE id = 1')
            ->execute([admin_totp_encrypt_secret($secret, $previousKey)]);
        self::assertSame('', admin_totp_decrypt_secret($this->user()['totp_secret'], [$currentKey]));
        self::assertSame($secret, admin_totp_decrypt_secret($this->user()['totp_secret']));

        $before = $this->user()['totp_secret'];
        self::assertSame(['applied' => false, 'accounts' => 1, 'unreadable' => []],
            admin_totp_reencrypt_all($this->pdo, false));
        self::assertSame($before, $this->user()['totp_secret']);

        self::assertTrue(admin_totp_reencrypt_all($this->pdo, true)['applied']);
        self::assertSame($secret, admin_totp_decrypt_secret($this->user()['totp_secret'], [$currentKey]));
    }

    public function test_key_rotation_changes_nothing_when_a_secret_is_unreadable(): void
    {
        $foreign = admin_totp_encrypt_secret(admin_totp_generate_secret(), hash('sha256', 'unrelated', true));
        $this->pdo->prepare('UPDATE trip_admin_users SET totp_enabled = 1, totp_secret = ? WHERE id = 1')
            ->execute([$foreign]);
        $result = admin_totp_reencrypt_all($this->pdo, true);
        self::assertFalse($result['applied']);
        self::assertSame(['owner:totp_secret'], $result['unreadable']);
        self::assertSame($foreign, $this->user()['totp_secret']);
    }

    public function test_disable_route_is_gone(): void
    {
        self::assertArrayNotHasKey('admin_panel_disable_totp', api_action_handlers());
    }
}
