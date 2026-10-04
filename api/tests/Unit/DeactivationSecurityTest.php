<?php
declare(strict_types=1);
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;
final class DeactivationSecurityTest extends TestCase
{
    private function scenario(string $name): array
    {
        $p = proc_open([PHP_BINARY, __DIR__ . '/../Fixtures/deactivation_security.php', $name],
            [0 => ['pipe','r'],1 => ['pipe','w'],2 => ['pipe','w']], $pipes);
        self::assertIsResource($p); fclose($pipes[0]);
        $out = stream_get_contents($pipes[1]); $err = stream_get_contents($pipes[2]);
        fclose($pipes[1]); fclose($pipes[2]);
        self::assertSame(0, proc_close($p), $err . $out); self::assertSame('', $err);
        $r = json_decode($out, true, 512, JSON_THROW_ON_ERROR);
        self::assertFalse($r['transaction_open']); self::assertTrue($r['other_unchanged']);
        self::assertTrue($r['password_unchanged']);
        return $r;
    }
    public static function denied(): iterable
    {
        foreach (['legacy','expired','used','purpose','changed_email','changed_password','reactivated',
            'unverified','inactive','guest','malformed'] as $name) { yield [$name,400]; }
        foreach (['direct_social','direct_empty','request_unverified','request_inactive'] as $name) { yield [$name,403]; }
        yield ['request_anonymous',401]; yield ['missing_schema',503];
    }
    #[DataProvider('denied')]
    public function test_no_deactivation_without_valid_current_ownership_proof(string $name, int $status): void
    {
        $r=$this->scenario($name); self::assertSame($status,$r['response']['status']);
        self::assertTrue($r['unchanged']); self::assertSame(0,$r['mail_count']);
    }
    public static function success(): iterable
    { yield ['confirm']; yield ['confirm_social']; yield ['direct_password']; yield ['replay']; }
    #[DataProvider('success')]
    public function test_deactivation_consumes_proofs_and_revokes_only_owner_sessions_and_push(string $name): void
    {
        $r=$this->scenario($name); self::assertSame(200,$r['response']['status']);
        self::assertSame('deactivated',$r['status']); self::assertSame(0,$r['active_sessions']);
        self::assertSame(0,$r['push_active']); self::assertSame(0,$r['unused']);
        if($name==='replay') { self::assertSame(400,$r['second']['status']); }
    }
    public static function failures(): iterable
    { yield ['session_failure']; yield ['push_failure']; yield ['token_failure']; }
    #[DataProvider('failures')]
    public function test_failed_write_rolls_back_all_deactivation_changes(string $name): void
    {
        $r=$this->scenario($name); self::assertTrue($r['failure']); self::assertTrue($r['unchanged']);
    }
    public static function requests(): iterable
    { yield ['request']; yield ['request_social']; yield ['request_cooldown']; }
    #[DataProvider('requests')]
    public function test_request_sends_to_stored_email_without_deactivating_or_switching_account(string $name): void
    {
        $r=$this->scenario($name); self::assertSame(200,$r['response']['status']);
        self::assertSame('active',$r['status']); self::assertSame(2,$r['active_sessions']);
        self::assertSame(1,$r['push_active']); self::assertSame(1,$r['mail_count']);
        self::assertSame(['owner@example.invalid'],$r['recipients']); self::assertSame(1,$r['tokens']);
    }
    public function test_failed_delivery_invalidates_only_issued_proof(): void
    {
        $r=$this->scenario('request_mail_failure'); self::assertSame(503,$r['response']['status']);
        self::assertSame('active',$r['status']); self::assertSame(0,$r['unused']);
    }
    public function test_rolling_request_budget(): void
    {
        $r=$this->scenario('request_limit'); self::assertSame(200,$r['response']['status']);
        self::assertTrue($r['unchanged']); self::assertSame(0,$r['mail_count']);
    }
}
