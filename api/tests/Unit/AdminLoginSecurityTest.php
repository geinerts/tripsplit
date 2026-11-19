<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

final class AdminLoginSecurityTest extends TestCase
{
    private function scenario(string $name): array
    {
        $p = proc_open([PHP_BINARY, __DIR__ . '/../Fixtures/admin_login_security.php', $name],
            [0 => ['pipe', 'r'], 1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes);
        self::assertIsResource($p);
        fclose($pipes[0]);
        $out = stream_get_contents($pipes[1]);
        $error = stream_get_contents($pipes[2]);
        fclose($pipes[1]);
        fclose($pipes[2]);
        self::assertSame(0, proc_close($p), $error . $out);
        self::assertSame('', $error);
        return json_decode($out, true, 512, JSON_THROW_ON_ERROR);
    }

    public function test_dummy_hash_uses_the_admin_cost(): void
    {
        $info = password_get_info(ADMIN_DUMMY_PASSWORD_HASH);
        self::assertSame(PASSWORD_BCRYPT, $info['algo']);
        self::assertSame(ADMIN_PASSWORD_BCRYPT_COST, $info['options']['cost']);
    }

    public function test_unknown_username_and_wrong_password_answer_the_same(): void
    {
        $r = $this->scenario('unknown_matches_wrong_password');
        self::assertSame(401, $r['unknown']['status']);
        self::assertSame($r['unknown'], $r['wrong']);
    }

    public function test_failed_logins_elsewhere_do_not_lock_out_the_owner(): void
    {
        $r = $this->scenario('others_cannot_lock_out_owner');
        self::assertSame(array_fill(0, 10, 401), array_slice($r['attacker'], 0, 10));
        self::assertSame([429, 429], array_slice($r['attacker'], 10));
        self::assertSame(200, $r['owner']['status']);
        self::assertTrue($r['owner']['payload']['ok']);
        self::assertNull($r['user']['locked_until']);
        self::assertSame(0, (int) $r['user']['failed_login_count']);
    }

    public function test_case_variants_of_a_username_share_one_limit(): void
    {
        $r = $this->scenario('case_variants_share_one_limit');
        self::assertSame(429, $r['variant']['status']);
    }

    public function test_failures_are_counted_without_locking(): void
    {
        $r = $this->scenario('failures_are_counted');
        self::assertSame(2, (int) $r['user']['failed_login_count']);
        self::assertNull($r['user']['locked_until']);
    }

    public function test_cheaper_old_hash_is_upgraded_on_login(): void
    {
        $r = $this->scenario('old_hash_is_upgraded');
        self::assertSame(ADMIN_PASSWORD_BCRYPT_COST, $r['cost']);
        self::assertTrue($r['still_valid']);
    }

    public function test_wrong_2fa_codes_are_limited_per_account_across_sessions_and_ips(): void
    {
        $r = $this->scenario('twofa_limit_spans_sessions');
        self::assertSame(array_fill(0, 10, 401), array_slice($r['statuses'], 0, 10));
        self::assertSame([429, 429], array_slice($r['statuses'], 10));
        self::assertSame(429, $r['correct_after_limit']);
    }

    public function test_correct_2fa_code_still_works(): void
    {
        self::assertSame(200, $this->scenario('twofa_correct_code_works')['status']);
    }
}
