<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

require_once __DIR__ . '/../../config/config_auth_logging_rate.php';
foreach (['TRUST_PROXY_HEADERS' => false, 'AUTH_REFRESH_TOKEN_TTL_SEC' => 2592000,
    'AUTH_ACCESS_TOKEN_TTL_SEC' => 900, 'AUTH_ACCESS_TOKEN_SECRET' => str_repeat('unit-test-only-', 4)] as $name => $value) {
    if (!defined($name)) {
        define($name, $value);
    }
}

final class RefreshTokenSecurityTest extends TestCase
{
    public function test_revoked_and_expired_refresh_tokens_never_issue_a_replacement(): void
    {
        foreach ([
            ['revoked_at' => gmdate('Y-m-d H:i:s'), 'expires_at' => gmdate('Y-m-d H:i:s', time() + 3600)],
            ['revoked_at' => null, 'expires_at' => gmdate('Y-m-d H:i:s', time() - 60)],
        ] as $state) {
            $pdo = $this->createMock(PDO::class);
            $pdo->expects(self::once())->method('beginTransaction');
            $pdo->expects(self::once())->method('commit');
            $pdo->method('prepare')->willReturnCallback(function (string $sql) use ($state): PDOStatement {
                self::assertStringNotContainsString('INSERT INTO', $sql);
                $statement = $this->createMock(PDOStatement::class);
                if (str_contains($sql, 'information_schema')) {
                    $statement->method('fetchColumn')->willReturn(1);
                } elseif (str_starts_with($sql, 'SELECT user_id')) {
                    $statement->method('fetchColumn')->willReturn(7);
                } elseif (str_contains($sql, 'FROM trip_users')) {
                    $statement->method('fetch')->willReturn(['id' => 7, 'account_status' => 'active',
                        'email' => 'unit@example.invalid', 'password_hash' => 'hash',
                        'credentials_required' => 0, 'email_verified_at' => '2026-01-01']);
                } elseif (str_contains($sql, 'SELECT id, user_id')) {
                    self::assertStringContainsString('FOR UPDATE', $sql);
                    $statement->method('fetch')->willReturn($state + ['id' => 10, 'user_id' => 7]);
                } else {
                    self::assertStringContainsString('COALESCE(revoked_at, :revoked_at)', $sql);
                }
                return $statement;
            });
            self::assertNull(rotate_refresh_token($pdo, str_repeat('a', 96)));
        }
    }

    public function test_rotation_revokes_old_token_and_stores_only_new_token_hash(): void
    {
        $plain = str_repeat('b', 96);
        $inserted = null;
        $revoked = false;
        $pdo = $this->createMock(PDO::class);
        $pdo->expects(self::once())->method('beginTransaction');
        $pdo->expects(self::once())->method('commit');
        $pdo->method('lastInsertId')->willReturn('11');
        $pdo->method('prepare')->willReturnCallback(function (string $sql) use ($plain, &$inserted, &$revoked): PDOStatement {
            $statement = $this->createMock(PDOStatement::class);
            if (str_contains($sql, 'information_schema')) {
                $statement->method('fetchColumn')->willReturn(1);
            } elseif (str_starts_with($sql, 'SELECT user_id')) {
                $statement->method('fetchColumn')->willReturn(7);
            } elseif (str_contains($sql, 'FROM trip_users')) {
                $statement->method('fetch')->willReturn(['id' => 7, 'account_status' => 'active',
                    'email' => 'unit@example.invalid', 'password_hash' => 'hash',
                    'credentials_required' => 0, 'email_verified_at' => '2026-01-01']);
            } elseif (str_contains($sql, 'SELECT id, user_id')) {
                self::assertStringContainsString('FOR UPDATE', $sql);
                $statement->expects(self::once())->method('execute')->with(['token_hash' => hash('sha256', $plain)]);
                $statement->method('fetch')->willReturn(['id' => 10, 'user_id' => 7, 'revoked_at' => null,
                    'expires_at' => gmdate('Y-m-d H:i:s', time() + 3600)]);
            } elseif (str_contains($sql, 'SET revoked_at = :revoked_at')) {
                $statement->method('execute')->willReturnCallback(function (array $params) use (&$revoked): bool {
                    self::assertSame(10, $params['id']);
                    $revoked = true;
                    return true;
                });
            } elseif (str_contains($sql, 'INSERT INTO')) {
                $statement->method('execute')->willReturnCallback(function (array $params) use (&$inserted, &$revoked): bool {
                    self::assertTrue($revoked);
                    $inserted = $params;
                    return true;
                });
            } else {
                $statement->method('fetchAll')->willReturn([11]);
            }
            return $statement;
        });
        $result = rotate_refresh_token($pdo, $plain);
        self::assertSame(7, $result['user_id']);
        self::assertNotSame($plain, $result['auth']['refresh_token']);
        self::assertSame(hash('sha256', $result['auth']['refresh_token']), $inserted['token_hash']);
        self::assertSame(7, resolve_user_id_from_access_token($result['auth']['access_token'], $pdo));
    }

    public function test_expiry_is_utc_regardless_of_server_timezone(): void
    {
        $original = date_default_timezone_get();
        try {
            foreach (['UTC', 'Europe/Riga', 'America/Los_Angeles'] as $timezone) {
                date_default_timezone_set($timezone);
                self::assertTrue(refresh_token_expiry_is_valid(gmdate('Y-m-d H:i:s', time() + 60)));
                self::assertFalse(refresh_token_expiry_is_valid(gmdate('Y-m-d H:i:s', time() - 60)));
            }
        } finally {
            date_default_timezone_set($original);
        }
    }

    public function test_malformed_expiry_fails_closed(): void
    {
        foreach (['', 'tomorrow', '2099-02-31 00:00:00', '2099-01-01 00:00:00 UTC'] as $expiry) {
            self::assertFalse(refresh_token_expiry_is_valid($expiry));
        }
    }

    public function test_logout_hashes_token_and_only_revokes_matching_session(): void
    {
        $plain = str_repeat('a', 96);
        $schema = $this->createMock(PDOStatement::class);
        $schema->method('fetchColumn')->willReturn(1);
        $revoke = $this->createMock(PDOStatement::class);
        $revoke->expects(self::once())->method('execute')->with(['token_hash' => hash('sha256', $plain)]);
        $revoke->method('rowCount')->willReturn(1);
        $pdo = $this->createMock(PDO::class);
        $pdo->method('prepare')->willReturnCallback(function (string $sql) use ($schema, $revoke): PDOStatement {
            if (str_contains($sql, 'information_schema')) {
                return $schema;
            }
            self::assertStringContainsString('WHERE token_hash = :token_hash', $sql);
            self::assertStringContainsString('COALESCE(revoked_at, CURRENT_TIMESTAMP)', $sql);
            return $revoke;
        });
        self::assertTrue(revoke_refresh_token($pdo, strtoupper($plain)));
    }

    public function test_malformed_refresh_and_logout_do_not_access_database(): void
    {
        $pdo = $this->createMock(PDO::class);
        $pdo->expects(self::never())->method('prepare');
        self::assertFalse(revoke_refresh_token($pdo, 'invalid'));
        self::assertNull(rotate_refresh_token($pdo, 'invalid'));
    }
}
