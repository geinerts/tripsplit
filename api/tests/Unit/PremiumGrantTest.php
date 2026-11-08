<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

require_once __DIR__ . '/../../lib/helpers/helper_premium.php';
require_once __DIR__ . '/../../lib/actions/premium_actions.php';
require_once __DIR__ . '/../../config/config_auth_logging_rate.php';
if (!defined('TRUST_PROXY_HEADERS')) define('TRUST_PROXY_HEADERS', false);

/** Real transactions and constraints; MySQL row locking still needs staging verification. */
final class PremiumTestDatabase extends PDO
{
    public function __construct()
    {
        parent::__construct('sqlite::memory:', null, null, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
        $this->exec('PRAGMA foreign_keys = ON');
        $this->exec('CREATE TABLE trip_users (id INTEGER PRIMARY KEY, account_status TEXT)');
        $this->exec("INSERT INTO trip_users VALUES (7, 'active'), (8, 'active'), (9, 'deleted')");
        $this->exec('ALTER TABLE trip_users ADD COLUMN nickname TEXT');
        $this->exec('ALTER TABLE trip_users ADD COLUMN email TEXT');
        $this->exec("UPDATE trip_users SET nickname = 'Test user', email = 'tester@example.test'");
        $this->exec('CREATE TABLE trip_admin_users (id INTEGER PRIMARY KEY, role TEXT, is_active INTEGER, totp_enabled INTEGER)');
        $this->exec("INSERT INTO trip_admin_users VALUES (1, 'superadmin', 1, 1)");
        $this->exec('CREATE TABLE trip_premium_partners (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE, created_at TEXT)');
        $this->exec('CREATE TABLE trip_premium_grants (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER REFERENCES trip_users(id) ON DELETE CASCADE,
            partner_id INTEGER REFERENCES trip_premium_partners(id), source TEXT, starts_at TEXT, ends_at TEXT, reason TEXT,
            revoked_at TEXT, version INTEGER DEFAULT 1, created_at TEXT)');
        $this->exec('CREATE TABLE trip_premium_events (id INTEGER PRIMARY KEY AUTOINCREMENT, request_id TEXT UNIQUE, request_hash TEXT,
            admin_user_id INTEGER, admin_username TEXT, user_id INTEGER, grant_id INTEGER, partner_id INTEGER,
            action TEXT, reason TEXT, before_json TEXT, after_json TEXT, created_at TEXT)');
        $this->exec('CREATE TABLE trip_trips (id INTEGER PRIMARY KEY, name TEXT)');
        $this->exec("INSERT INTO trip_trips VALUES (20, 'Rome'), (21, 'Oslo')");
        $this->exec('CREATE TABLE trip_trip_members (trip_id INTEGER REFERENCES trip_trips(id) ON DELETE CASCADE, user_id INTEGER)');
        $this->exec('INSERT INTO trip_trip_members VALUES (20, 7), (20, 8), (21, 8)');
        $this->exec('CREATE TABLE trip_premium_trip_grants (id INTEGER PRIMARY KEY AUTOINCREMENT,
            trip_id INTEGER NOT NULL REFERENCES trip_trips(id) ON DELETE CASCADE, source TEXT NOT NULL, reason TEXT NOT NULL,
            revoked_at TEXT, version INTEGER NOT NULL DEFAULT 1, created_at TEXT NOT NULL)');
        $this->exec('CREATE TABLE trip_admin_audit_log (id INTEGER PRIMARY KEY AUTOINCREMENT, admin_user_id INTEGER,
            admin_username TEXT, action TEXT, target_type TEXT, target_id INTEGER, details TEXT, ip_address TEXT)');
    }

    public function prepare(string $query, array $options = []): PDOStatement|false
    {
        return parent::prepare(str_replace(' FOR UPDATE', '', $query), $options);
    }
}

final class PremiumGrantTest extends TestCase
{
    private PremiumTestDatabase $pdo;
    private int $now;
    private int $sequence = 0;
    private array $session = ['admin_user_id' => 1, 'username' => 'Test admin', 'role' => 'superadmin',
        'totp_enabled' => 1, 'is_2fa_verified' => 1, 'token' => 'session-hash'];

    protected function setUp(): void
    {
        $this->pdo = new PremiumTestDatabase();
        $this->now = strtotime('2026-09-23T12:00:00Z');
    }

    private function body(array $overrides = []): array
    {
        return array_replace(['operation' => 'grant_create', 'user_id' => 7, 'source' => 'testing',
            'ends_at' => '2026-10-23T12:00:00Z', 'reason' => 'Partner pilot',
            'request_id' => sprintf('00000000-0000-4000-8000-%012d', ++$this->sequence)], $overrides);
    }

    private function mutate(array $body): array
    {
        return premium_mutate($this->pdo, $this->session, premium_csrf_token($this->session), $body, $this->now);
    }

    public function test_grant_expiry_account_scope_and_public_payload(): void
    {
        $this->mutate($this->body());
        $access = premium_access_for_user($this->pdo, 7, $this->now);
        self::assertSame('premium', $access['plan']);
        self::assertSame('2026-10-23T12:00:00Z', $access['expires_at']);
        self::assertFalse($access['billing_enabled']);
        self::assertFalse($access['limits_enforced']);
        self::assertArrayNotHasKey('reason', $access);
        self::assertArrayNotHasKey('partner_name', $access);
        self::assertSame('free', premium_access_for_user($this->pdo, 8, $this->now)['plan']);
        self::assertSame('free', premium_access_for_user($this->pdo, 7, strtotime($access['expires_at']))['plan']);
        self::assertSame(1, (int) $this->pdo->query('SELECT COUNT(*) FROM trip_admin_audit_log')->fetchColumn());
    }

    public function test_feature_list_decides_each_feature_and_refuses_unlisted_ones(): void
    {
        self::assertSame([
            'trip_export' => ['tier' => 'premium', 'scope' => 'trip'],
            'year_summary' => ['tier' => 'premium', 'scope' => 'account'],
        ], premium_feature_catalog());
        $free = premium_access_for_user($this->pdo, 8, $this->now, ['enabled' => false]);
        self::assertSame(['trip_export' => false, 'year_summary' => false], $free['features']);
        self::assertFalse(premium_feature_allowed($free, 'trip_export'));
        $this->mutate($this->body());
        $premium = premium_access_for_user($this->pdo, 7, $this->now, ['enabled' => false]);
        self::assertTrue(premium_feature_allowed($premium, 'trip_export'));
        self::assertTrue(premium_feature_allowed($premium, 'year_summary'));
        self::assertFalse(premium_feature_allowed($premium, 'unlisted'));
        self::assertFalse(premium_feature_allowed(['features' => ['trip_export' => 'yes']], 'trip_export'));
    }

    public function test_premium_for_everyone_covers_active_accounts_until_its_end(): void
    {
        $open = ['enabled' => true, 'until' => ''];
        $access = premium_access_for_user($this->pdo, 8, $this->now, $open);
        self::assertSame('premium', $access['plan']);
        self::assertSame('launch', $access['source']);
        self::assertNull($access['expires_at']);
        self::assertTrue(premium_feature_allowed($access, 'trip_export'));
        self::assertSame('free', premium_access_for_user($this->pdo, 9, $this->now, $open)['plan']);

        $until = ['enabled' => true, 'until' => '2026-12-31T00:00:00Z'];
        self::assertSame('2026-12-31T00:00:00Z', premium_access_for_user($this->pdo, 8, $this->now, $until)['expires_at']);
        self::assertSame('free', premium_access_for_user($this->pdo, 8, strtotime('2026-12-31T00:00:00Z'), $until)['plan']);
        foreach (['2026-12-31', '2026-12-31T00:00:00+02:00', 'tomorrow'] as $invalid) {
            self::assertSame('free', premium_access_for_user($this->pdo, 8, $this->now,
                ['enabled' => true, 'until' => $invalid])['plan'], $invalid);
        }
        self::assertSame('free', premium_access_for_user($this->pdo, 8, $this->now, ['enabled' => false, 'until' => ''])['plan']);
    }

    public function test_admin_grant_takes_precedence_and_switch_survives_missing_grant_table(): void
    {
        $this->mutate($this->body());
        $open = ['enabled' => true, 'until' => ''];
        $access = premium_access_for_user($this->pdo, 7, $this->now, $open);
        self::assertSame('admin_grant', $access['source']);
        self::assertSame('2026-10-23T12:00:00Z', $access['expires_at']);
        $this->pdo->exec('DROP TABLE trip_premium_grants');
        self::assertSame('launch', premium_access_for_user($this->pdo, 7, $this->now, $open)['source']);
        self::assertSame('unknown', premium_access_for_user($this->pdo, 7, $this->now, ['enabled' => false])['plan']);
        $this->pdo->exec('DROP TABLE trip_users');
        self::assertSame('unknown', premium_access_for_user($this->pdo, 7, $this->now, $open)['plan']);
        self::assertFalse(premium_feature_allowed(premium_access_for_user($this->pdo, 7, $this->now, $open), 'trip_export'));
    }

    public function test_trip_premium_covers_members_only_for_trip_features(): void
    {
        $off = ['enabled' => false];
        $free = premium_access_for_user($this->pdo, 8, $this->now, $off);
        self::assertSame([20 => ['trip_export' => false], 21 => ['trip_export' => false]],
            premium_trip_features($this->pdo, $free, [20, 21]));
        $grant = $this->mutate($this->body(['operation' => 'trip_grant_create', 'trip_id' => 20, 'source' => 'testing']));
        self::assertSame([20 => ['trip_export' => true], 21 => ['trip_export' => false]],
            premium_trip_features($this->pdo, $free, [20, 21]));
        self::assertTrue(premium_feature_allowed_for($this->pdo, $free, 'trip_export', 20));
        self::assertFalse(premium_feature_allowed_for($this->pdo, $free, 'trip_export', 21));
        self::assertFalse(premium_feature_allowed_for($this->pdo, $free, 'trip_export'));
        self::assertFalse(premium_feature_allowed_for($this->pdo, $free, 'year_summary', 20));
        self::assertFalse(premium_feature_allowed_for($this->pdo, $free, 'unlisted', 20));
        $launch = premium_access_for_user($this->pdo, 8, $this->now, ['enabled' => true, 'until' => '']);
        self::assertTrue(premium_feature_allowed_for($this->pdo, $launch, 'trip_export', 21));

        $detail = premium_user_detail($this->pdo, 8, $this->session);
        self::assertSame([20], array_map('intval', array_column($detail['trip_grants'], 'trip_id')));
        self::assertSame([], premium_user_detail($this->pdo, 8, array_replace($this->session, ['role' => 'support']))['trip_grants']);
        $event = $this->pdo->query("SELECT * FROM trip_premium_events WHERE action = 'trip_grant_create'")->fetch(PDO::FETCH_ASSOC);
        self::assertNull($event['user_id']);
        self::assertSame(20, json_decode($event['after_json'], true)['trip_id']);
        self::assertSame('premium_trip_grant', $this->pdo->query('SELECT target_type FROM trip_admin_audit_log')->fetchColumn());

        $this->mutate($this->body(['operation' => 'trip_grant_revoke', 'trip_grant_id' => $grant['grant_id'], 'version' => 1]));
        self::assertFalse(premium_feature_allowed_for($this->pdo, $free, 'trip_export', 20));
        self::assertSame([], premium_user_detail($this->pdo, 8, $this->session)['trip_grants']);
    }

    public function test_trip_premium_rejects_duplicates_bad_input_and_stale_revokes(): void
    {
        $grant = $this->mutate($this->body(['operation' => 'trip_grant_create', 'trip_id' => 20, 'source' => 'compensation']));
        foreach ([
            [DomainException::class, ['operation' => 'trip_grant_create', 'trip_id' => 20, 'source' => 'testing']],
            [DomainException::class, ['operation' => 'trip_grant_create', 'trip_id' => 999, 'source' => 'testing']],
            [InvalidArgumentException::class, ['operation' => 'trip_grant_create', 'trip_id' => 21, 'source' => 'partner']],
            [InvalidArgumentException::class, ['operation' => 'trip_grant_create', 'trip_id' => '21', 'source' => 'testing']],
            [DomainException::class, ['operation' => 'trip_grant_revoke', 'trip_grant_id' => $grant['grant_id'], 'version' => 2]],
            [DomainException::class, ['operation' => 'trip_grant_revoke', 'trip_grant_id' => 999, 'version' => 1]],
        ] as [$expected, $change]) {
            try {
                $this->mutate($this->body($change));
                self::fail('Invalid trip grant accepted.');
            } catch (DomainException | InvalidArgumentException $error) {
                self::assertInstanceOf($expected, $error);
            }
        }
        self::assertSame(1, (int) $this->pdo->query('SELECT COUNT(*) FROM trip_premium_trip_grants')->fetchColumn());
        $this->pdo->exec('DELETE FROM trip_trips WHERE id = 20');
        self::assertSame(0, (int) $this->pdo->query('SELECT COUNT(*) FROM trip_premium_trip_grants')->fetchColumn());
    }

    public function test_missing_trip_premium_table_means_only_own_premium_counts(): void
    {
        $this->pdo->exec('DROP TABLE trip_premium_trip_grants');
        $free = premium_access_for_user($this->pdo, 8, $this->now, ['enabled' => false]);
        self::assertSame([20 => ['trip_export' => false]], premium_trip_features($this->pdo, $free, [20]));
        self::assertSame([], premium_user_detail($this->pdo, 8, $this->session)['trip_grants']);
        $this->expectException(PDOException::class);
        $this->mutate($this->body(['operation' => 'trip_grant_create', 'trip_id' => 20, 'source' => 'testing']));
    }

    public function test_idempotent_retries_and_request_key_mismatch(): void
    {
        $body = $this->body();
        self::assertFalse($this->mutate($body)['replayed']);
        self::assertTrue($this->mutate($body)['replayed']);
        self::assertSame(1, (int) $this->pdo->query('SELECT COUNT(*) FROM trip_premium_events')->fetchColumn());
        $body['user_id'] = 8;
        $this->expectException(DomainException::class);
        $this->mutate($body);
    }

    public function test_missing_audit_or_event_storage_rolls_back_everything(): void
    {
        foreach (['trip_admin_audit_log', 'trip_premium_events'] as $table) {
            $this->pdo = new PremiumTestDatabase();
            $this->pdo->exec('DROP TABLE ' . $table);
            try {
                $this->mutate($this->body());
                self::fail('Saved without an audit record.');
            } catch (PDOException $error) {
                self::assertFalse($this->pdo->inTransaction());
                self::assertSame(0, (int) $this->pdo->query('SELECT COUNT(*) FROM trip_premium_grants')->fetchColumn());
                if ($table === 'trip_admin_audit_log') self::assertSame(0, (int) $this->pdo->query('SELECT COUNT(*) FROM trip_premium_events')->fetchColumn());
            }
        }
    }

    public function test_permissions_require_superadmin_enabled_verified_2fa_and_csrf(): void
    {
        foreach ([['role' => 'admin'], ['role' => 'support'], ['role' => 'ops'], ['role' => 'readonly'],
            ['totp_enabled' => 0], ['is_2fa_verified' => 0], ['token' => '']] as $change) {
            try {
                premium_assert_write(array_replace($this->session, $change), premium_csrf_token($this->session));
                self::fail('Unauthorized grant allowed.');
            } catch (DomainException $error) { $this->addToAssertionCount(1); }
        }
        $this->expectException(DomainException::class);
        premium_assert_write($this->session, 'wrong-token');
    }

    public function test_permissions_are_rechecked_under_lock(): void
    {
        $this->pdo->exec("UPDATE trip_admin_users SET role = 'support' WHERE id=1");
        $this->expectException(DomainException::class);
        $this->mutate($this->body());
    }

    public function test_invalid_expiry_reason_or_source_never_creates_grant(): void
    {
        foreach ([['ends_at' => '2026-09-23T12:00:00Z'], ['ends_at' => '2026-02-30T12:00:00Z'],
            ['ends_at' => '2026-10-23T14:00:00+02:00'], ['ends_at' => '2033-01-01T00:00:00Z'],
            ['source' => 'paid'], ['reason' => ' '], ['reason' => str_repeat('x', 501)], ['reason' => "\xFF"]] as $change) {
            try { $this->mutate($this->body($change)); self::fail('Invalid grant accepted.'); }
            catch (InvalidArgumentException | JsonException $error) { $this->addToAssertionCount(1); }
        }
        self::assertSame(0, (int) $this->pdo->query('SELECT COUNT(*) FROM trip_premium_grants')->fetchColumn());
    }

    public function test_partner_creation_and_grant_history(): void
    {
        $partner = $this->mutate($this->body(['operation' => 'partner_create', 'name' => 'Travel partner']));
        $this->mutate($this->body(['source' => 'partner', 'partner_id' => $partner['partner_id']]));
        $detail = premium_user_detail($this->pdo, 7, $this->session);
        self::assertSame('Travel partner', $detail['grants'][0]['partner_name']);
        self::assertSame('Test admin', $detail['history'][0]['admin_username']);
        self::assertTrue($detail['can_manage']);
        $support = premium_user_detail($this->pdo, 7, array_replace($this->session, ['role' => 'support']));
        self::assertSame([], $support['history']);
        self::assertSame([], $support['grants']);
        self::assertNull($support['csrf_token']);
    }

    public function test_nonexistent_partner_rejected(): void
    {
        $this->expectException(DomainException::class);
        $this->mutate($this->body(['source' => 'partner', 'partner_id' => 999]));
    }

    public function test_hard_account_deletion_removes_access_without_destroying_audit(): void
    {
        $this->mutate($this->body());
        $this->pdo->exec('DELETE FROM trip_users WHERE id = 7');
        self::assertSame(0, (int) $this->pdo->query('SELECT COUNT(*) FROM trip_premium_grants')->fetchColumn());
        self::assertSame(1, (int) $this->pdo->query('SELECT COUNT(*) FROM trip_premium_events')->fetchColumn());
        self::assertSame('free', premium_access_for_user($this->pdo, 7, $this->now)['plan']);
    }

    public function test_extend_version_conflict_and_revoke_preserves_other_grants(): void
    {
        $id = $this->mutate($this->body())['grant_id'];
        $this->mutate($this->body(['operation' => 'grant_extend', 'grant_id' => $id, 'version' => 1,
            'ends_at' => '2026-11-23T12:00:00Z']));
        try {
            $this->mutate($this->body(['operation' => 'grant_revoke', 'grant_id' => $id, 'version' => 1]));
            self::fail('Stale version accepted.');
        } catch (DomainException $error) { $this->addToAssertionCount(1); }
        $this->mutate($this->body());
        $this->mutate($this->body(['operation' => 'grant_revoke', 'grant_id' => $id, 'version' => 2]));
        self::assertSame('2026-10-23T12:00:00Z', premium_access_for_user($this->pdo, 7, $this->now)['expires_at']);
        $events = $this->pdo->query('SELECT * FROM trip_premium_events ORDER BY id')->fetchAll(PDO::FETCH_ASSOC);
        self::assertCount(4, $events);
        self::assertSame(1, json_decode($events[1]['before_json'], true)['version']);
        self::assertSame(2, json_decode($events[1]['after_json'], true)['version']);
    }

    public function test_deleted_account_cannot_receive_grant_and_missing_schema_is_unknown(): void
    {
        try { $this->mutate($this->body(['user_id' => 9])); self::fail('Deleted user accepted.'); }
        catch (DomainException $error) { $this->addToAssertionCount(1); }
        $this->pdo->exec('DROP TABLE trip_premium_grants');
        self::assertSame('unknown', premium_access_for_user($this->pdo, 7, $this->now)['plan']);
        self::assertFalse(premium_user_detail($this->pdo, 7, $this->session)['can_manage']);
    }

    public function test_admin_detail_query_has_explicit_private_data_allowlist(): void
    {
        $source = file_get_contents(__DIR__ . '/../../lib/actions/admin_panel_actions.php');
        $detail = explode('function admin_panel_user_suspend_action', explode('function admin_panel_user_detail_action', $source)[1])[0];
        self::assertStringNotContainsString('SELECT *', $detail);
        self::assertStringNotContainsString('token_preview', $detail);
        self::assertStringNotContainsString('password_hash', $detail);
        self::assertStringNotContainsString('note AS description', $detail);
        self::assertStringContainsString('SELECT id, nickname, email, account_status, created_at', $detail);
    }

    public function test_list_filters_and_pagination_use_real_query_results(): void
    {
        $this->now = time();
        $end = gmdate('Y-m-d\TH:i:s\Z', $this->now + 7 * 86400);
        $partner = $this->mutate($this->body(['operation' => 'partner_create', 'name' => 'Travel partner']))['partner_id'];
        $this->mutate($this->body(['source' => 'partner', 'partner_id' => $partner, 'ends_at' => $end]));
        $late = $this->mutate($this->body(['ends_at' => gmdate('Y-m-d\TH:i:s\Z', $this->now + 30 * 86400)]))['grant_id'];
        self::assertCount(2, premium_admin_list($this->pdo, ['status' => 'active'])['rows']);
        self::assertCount(1, premium_admin_list($this->pdo, ['status' => 'expiring'])['rows']);
        self::assertCount(1, premium_admin_list($this->pdo, ['partner_id' => $partner])['rows']);
        self::assertCount(0, premium_admin_list($this->pdo, ['q' => "' OR 1=1 --"])['rows']);
        self::assertSame(1, (int) premium_admin_list($this->pdo, ['kind' => 'partners'])['rows'][0]['active_grants']);
        $this->mutate($this->body(['operation' => 'grant_revoke', 'grant_id' => $late, 'version' => 1]));
        self::assertCount(1, premium_admin_list($this->pdo, ['status' => 'revoked'])['rows']);
        $this->pdo->exec("UPDATE trip_premium_grants SET ends_at = '2020-01-01 00:00:00' WHERE revoked_at IS NULL");
        self::assertCount(1, premium_admin_list($this->pdo, ['status' => 'expired'])['rows']);
        self::assertCount(0, premium_admin_list($this->pdo, ['status' => 'expiring'])['rows']);
        for ($i = 0; $i < 41; $i++) $this->mutate($this->body(['ends_at' => $end]));
        $first = premium_admin_list($this->pdo, ['status' => 'active']);
        self::assertTrue($first['has_more']);
        self::assertCount(40, $first['rows']);
        $last = premium_admin_list($this->pdo, ['status' => 'active', 'offset' => 40]);
        self::assertFalse($last['has_more']);
        self::assertCount(1, $last['rows']);
        self::assertNotContains($last['rows'][0]['id'], array_column($first['rows'], 'id'));
    }
}
