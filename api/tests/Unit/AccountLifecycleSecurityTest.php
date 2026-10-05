<?php
declare(strict_types=1);
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

final class AccountLifecycleSecurityTest extends TestCase
{
    private function scenario(string $action, string $scenario): array
    {
        $p=proc_open([PHP_BINARY,__DIR__.'/../Fixtures/lifecycle_security.php',$action,$scenario],
            [0=>['pipe','r'],1=>['pipe','w'],2=>['pipe','w']],$pipes);
        self::assertIsResource($p); fclose($pipes[0]);
        $out=stream_get_contents($pipes[1]);$err=stream_get_contents($pipes[2]);
        fclose($pipes[1]);fclose($pipes[2]);
        self::assertSame(0,proc_close($p),$err.$out);self::assertSame('',$err);
        $r=json_decode($out,true,512,JSON_THROW_ON_ERROR);
        self::assertFalse($r['open']);self::assertTrue($r['other_unchanged']);
        return $r;
    }
    public static function denied(): iterable
    {
        foreach(['delete','reactivate'] as $action) {
            foreach(['legacy','expired','used','wrong_purpose','wrong_user','changed_email','changed_password',
                'changed_epoch','changed_verification','unverified','guest','wrong_status','deleted','malformed','newline'] as $s) yield [$action,$s,400];
            foreach(['missing_schema','missing_sessions'] as $s) yield [$action,$s,503];
        }
        foreach(['request_wrong_password','request_missing_password','request_social_wrong_password',
            'request_unverified','request_guest','request_wrong_status','request_deleted'] as $s) yield ['delete',$s,403];
        yield ['delete','request_anonymous',401];
    }
    #[DataProvider('denied')]
    public function test_invalid_proofs_and_ineligible_requests_do_not_mutate(string $action,string $scenario,int $status): void
    {
        $r=$this->scenario($action,$scenario);self::assertSame($status,$r['response']['status']);
        self::assertTrue($r['unchanged']);self::assertSame(0,$r['mail']);
    }
    public static function confirmations(): iterable
    {
        foreach(['delete','reactivate'] as $a) foreach(['confirm','confirm_social','replay','old_link_after_new_state'] as $s) yield [$a,$s];
    }
    #[DataProvider('confirmations')]
    public function test_confirmation_consumes_all_proofs_and_revokes_owner_access(string $action,string $scenario): void
    {
        $r=$this->scenario($action,$scenario);self::assertSame(200,$r['response']['status']);
        self::assertSame(0,$r['sessions']);self::assertSame(0,$r['push']);self::assertSame(0,$r['mail']);
        foreach($r['proofs'] as $proof)self::assertNotNull($proof['used_at']);
        if($scenario==='old_link_after_new_state'){self::assertSame(400,$r['second']['status']);return;}
        self::assertSame($action==='delete'?'deleted':'active',$r['user']['account_status']);
        if($action==='delete') {
            foreach(['email','password_hash','email_verified_at','avatar_path','bank_iban','wise_pay_link'] as $field)self::assertNull($r['user'][$field]);
            self::assertSame(0,$r['friends']);self::assertSame(0,$r['identities']);
        }
        if($scenario==='replay')self::assertSame(400,$r['second']['status']);
    }
    public static function requests(): iterable
    { foreach(['delete','reactivate'] as $a)foreach(['request','request_social','request_cooldown','request_prior','request_limit','request_mail_failure'] as $s)yield[$a,$s]; }
    #[DataProvider('requests')]
    public function test_request_is_non_mutating_and_preserves_prior_links(string $action,string $scenario): void
    {
        $r=$this->scenario($action,$scenario);
        self::assertSame($action==='delete'&&$scenario==='request_mail_failure'?503:200,$r['response']['status']);
        self::assertSame($action==='delete'?'active':'deactivated',$r['user']['account_status']);
        self::assertSame(2,$r['sessions']);self::assertSame(1,$r['push']);
        if($scenario==='request_limit'){self::assertSame(0,$r['mail']);self::assertTrue($r['unchanged']);return;}
        self::assertSame(1,$r['mail']);self::assertSame(['owner@example.invalid'],$r['recipients']);
        $new=end($r['proofs']);
        self::assertMatchesRegularExpression('/^[a-f0-9]{64}$/',$new['credential_state_hash']);
        parse_str((string)parse_url($r['mail_body'],PHP_URL_QUERY),$query);
        self::assertSame(hash('sha256',$query['token']),$new['token_hash']);
        if($scenario==='request_mail_failure'){self::assertNotNull($new['used_at']);self::assertNull($r['proofs'][0]['used_at']);}
        else foreach($r['proofs'] as $p)self::assertNull($p['used_at']);
    }
    public static function hiddenAccounts(): iterable
    { foreach(['request_unknown','request_unverified','request_guest','request_wrong_status','request_deleted'] as $s)yield[$s]; }
    #[DataProvider('hiddenAccounts')]
    public function test_reactivation_does_not_reveal_ineligible_accounts(string $scenario): void
    {
        $r=$this->scenario('reactivate',$scenario);self::assertSame(['status'=>200,'payload'=>['ok'=>true]],$r['response']);
        self::assertTrue($r['unchanged']);self::assertSame(0,$r['mail']);
    }
    public static function failures(): iterable
    {
        foreach(['delete','reactivate'] as $a)foreach(['session_failure','proof_failure','push_failure','user_failure'] as $s)yield[$a,$s];
        yield ['delete','friend_failure'];yield ['delete','identity_failure'];
    }
    #[DataProvider('failures')]
    public function test_transaction_failure_rolls_back_every_change(string $action,string $scenario): void
    {
        $r=$this->scenario($action,$scenario);self::assertTrue($r['failure']);self::assertTrue($r['unchanged']);
    }
}
