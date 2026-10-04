<?php
declare(strict_types=1);
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

final class PasswordResetSecurityTest extends TestCase
{
    private function scenario(string $name): array
    {
        $p = proc_open([PHP_BINARY, __DIR__ . '/../Fixtures/password_reset_security.php', $name],
            [0 => ['pipe', 'r'], 1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes);
        self::assertIsResource($p);
        fclose($pipes[0]);
        $out = stream_get_contents($pipes[1]); $error = stream_get_contents($pipes[2]);
        fclose($pipes[1]); fclose($pipes[2]);
        self::assertSame(0, proc_close($p), $error . $out);
        self::assertSame('', $error);
        $r = json_decode($out, true, 512, JSON_THROW_ON_ERROR);
        self::assertFalse($r['transaction_open']);
        self::assertTrue($r['other_unchanged']);
        self::assertFalse($r['plain_token_stored']);
        return $r;
    }
    public static function rejected(): iterable
    {
        foreach (['legacy', 'expired', 'used', 'changed_email', 'changed_password', 'unverified',
            'inactive', 'guest', 'unknown', 'malformed', 'invalid_password'] as $name) { yield [$name, 400]; }
        yield ['missing_schema', 503];
        yield ['missing_sessions', 503];
    }
    #[DataProvider('rejected')]
    public function test_invalid_or_stale_proof_cannot_change_credentials(string $name, int $status): void
    {
        $r = $this->scenario($name);
        self::assertSame($status, $r['response']['status']);
        self::assertTrue($r['unchanged']);
        self::assertSame(0, $r['mail_count']);
    }
    public static function successful(): iterable
    {
        yield ['reset']; yield ['reset_social']; yield ['replay'];
    }
    #[DataProvider('successful')]
    public function test_email_proof_sets_password_and_atomically_revokes_all_old_refresh_sessions(string $name): void
    {
        $r = $this->scenario($name);
        self::assertSame(200, $r['response']['status']);
        self::assertTrue($r['password_changed']);
        self::assertTrue($r['email_unchanged']);
        self::assertSame(0, $r['active_sessions']);
        self::assertSame(0, $r['active_resets']);
        self::assertArrayNotHasKey('auth', $r['response']['payload']);
        if ($name === 'replay') { self::assertSame(400, $r['second']['status']); }
    }
    public static function failures(): iterable
    {
        yield ['session_failure']; yield ['token_failure'];
    }
    #[DataProvider('failures')]
    public function test_database_failure_rolls_back_password_token_and_revocations(string $name): void
    {
        $r = $this->scenario($name);
        self::assertTrue($r['failed']);
        self::assertTrue($r['unchanged']);
    }
    public static function requests(): iterable
    {
        yield ['request_known', 1, 1, 1]; yield ['request_social', 1, 1, 1];
        yield ['request_unknown', 0, 0, 0]; yield ['request_inactive', 0, 0, 0];
        yield ['request_unverified', 0, 0, 0]; yield ['request_guest', 0, 0, 0];
        yield ['request_failed_mail', 1, 1, 0]; yield ['request_cooldown', 1, 1, 1];
        yield ['request_preserves_link', 1, 2, 2]; yield ['request_rolling_limit', 0, 3, 3];
    }
    #[DataProvider('requests')]
    public function test_requests_are_bounded_without_revealing_accounts_or_invalidating_delivered_links(
        string $name, int $mail, int $tokens, int $active): void
    {
        $r = $this->scenario($name);
        self::assertSame(['status' => 200, 'payload' => ['ok' => true]], $r['response']);
        self::assertSame($mail, $r['mail_count']);
        self::assertSame($tokens, $r['token_count']);
        self::assertSame($active, $r['active_resets']);
        self::assertSame(2, $r['active_sessions']);
        self::assertSame(['password_reset_request_ip', 'password_reset_request_email',
            'password_reset_request_global'], array_slice($r['rates'], 0, 3));
        if ($name === 'request_cooldown') { self::assertSame($r['response'], $r['second']); }
    }
    public function test_requests_fail_closed_without_migration(): void
    {
        $r = $this->scenario('request_missing_schema');
        self::assertSame(503, $r['response']['status']);
        self::assertTrue($r['unchanged']);
        self::assertSame(0, $r['mail_count']);
    }
}
