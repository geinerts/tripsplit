<?php
declare(strict_types=1);
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

final class SessionRevocationSecurityTest extends TestCase
{
    public static function scenarios(): iterable
    {
        foreach (['reset','deactivate','reactivate','logout','rotate','expired','wrong_owner',
            'legacy','password_change','stale_sensitive_request','session_limit'] as $scenario) yield [$scenario];
    }
    #[DataProvider('scenarios')]
    public function test_access_is_bound_to_a_live_owned_session(string $scenario): void
    {
        $p = proc_open([PHP_BINARY, __DIR__.'/../Fixtures/session_security.php', $scenario],
            [0=>['pipe','r'],1=>['pipe','w'],2=>['pipe','w']], $pipes);
        self::assertIsResource($p); fclose($pipes[0]);
        $out=stream_get_contents($pipes[1]); $err=stream_get_contents($pipes[2]);
        fclose($pipes[1]); fclose($pipes[2]);
        self::assertSame(0, proc_close($p), $err.$out); self::assertSame('', $err);
        $r=json_decode($out,true,512,JSON_THROW_ON_ERROR);
        self::assertSame(1,$r['before']); self::assertSame(0,$r['after']);
        self::assertSame(2,$r['other']); self::assertFalse($r['open']);
        if (isset($r['response'])) self::assertSame($scenario==='stale_sensitive_request'?401:200,$r['response']['status']);
        if (array_key_exists('refresh',$r)) self::assertNull($r['refresh']);
        if (array_key_exists('replay',$r)) self::assertNull($r['replay']);
        if (isset($r['new_access'])) self::assertSame(1,$r['new_access']);
        if (isset($r['reactivated'])) self::assertSame(200,$r['reactivated']);
    }
}
