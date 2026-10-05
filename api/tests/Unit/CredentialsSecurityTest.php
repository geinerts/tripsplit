<?php
declare(strict_types=1);
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

final class CredentialsSecurityTest extends TestCase
{
    private function scenario(string $scenario): array
    {
        $process = proc_open([PHP_BINARY, __DIR__ . '/../Fixtures/credentials_security.php', $scenario],
            [0 => ['pipe', 'r'], 1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes);
        self::assertIsResource($process);
        fclose($pipes[0]);
        $out = stream_get_contents($pipes[1]); $error = stream_get_contents($pipes[2]);
        fclose($pipes[1]); fclose($pipes[2]);
        self::assertSame(0, proc_close($process), $error . $out);
        self::assertSame('', $error);
        $result = json_decode($out, true, 512, JSON_THROW_ON_ERROR);
        self::assertFalse($result['transaction_open']);
        self::assertTrue($result['other_unchanged']);
        return $result;
    }

    public static function denied(): iterable
    {
        foreach (['enroll_established' => 409, 'enroll_social' => 409, 'enroll_partial_email' => 409,
            'enroll_partial_hash' => 409, 'enroll_unverified' => 403, 'enroll_inactive' => 403,
            'enroll_duplicate' => 409, 'password_missing' => 403, 'password_wrong' => 403,
            'password_trimmed' => 403, 'password_social' => 403, 'password_unverified' => 403,
            'password_email_change' => 409, 'password_partial' => 400, 'password_mixed' => 400,
            'anonymous' => 401] as $scenario => $status) { yield $scenario => [$scenario, $status]; }
    }
    #[DataProvider('denied')]
    public function test_unauthorized_credential_writes_have_no_side_effects(string $scenario, int $status): void
    {
        $result = $this->scenario($scenario);
        self::assertSame($status, $result['response']['status']);
        self::assertTrue($result['user_unchanged']);
        self::assertTrue($result['sessions_unchanged']);
        self::assertSame(0, $result['mail_count']);
        self::assertArrayNotHasKey('auth', $result['response']['payload']);
    }
    public function test_guest_enrollment_requires_verification_and_revokes_guest_sessions(): void
    {
        foreach (['enroll_success', 'enroll_mail_failure'] as $scenario) {
            $result = $this->scenario($scenario);
            self::assertSame(200, $result['response']['status']);
            self::assertTrue($result['response']['payload']['email_verification_required']);
            self::assertSame($scenario === 'enroll_success', $result['response']['payload']['verification_email_sent']);
            self::assertArrayNotHasKey('auth', $result['response']['payload']);
            self::assertTrue($result['new_password_matches']);
            self::assertFalse($result['verified']);
            self::assertSame(2, $result['old_sessions_revoked']);
            self::assertSame(0, $result['active_sessions']);
            self::assertTrue($result['other_session_active']);
            self::assertSame(['credential_change_ip', 'credential_change_user'], $result['rates']);
        }
    }
    public function test_enrollment_cannot_be_replayed_and_verification_link_still_works(): void
    {
        $replay = $this->scenario('enroll_replay');
        self::assertSame(401, $replay['response']['status']);
        self::assertSame(1, $replay['mail_count']);
        $verified = $this->scenario('enroll_verify');
        self::assertSame(200, $verified['response']['status']);
        self::assertTrue($verified['verified']);
        self::assertSame(0, $verified['active_sessions']);
    }
    public function test_password_change_requires_exact_password_and_rotates_refresh_sessions(): void
    {
        $result = $this->scenario('password_success');
        self::assertSame(200, $result['response']['status']);
        self::assertTrue($result['new_password_matches']);
        self::assertSame('owner@example.invalid', $result['email']);
        self::assertTrue($result['verified']);
        self::assertSame(2, $result['old_sessions_revoked']);
        self::assertSame(1, $result['active_sessions']);
        self::assertTrue($result['other_session_active']);
        self::assertArrayHasKey('auth', $result['response']['payload']);
        self::assertSame(['credential_change_ip', 'credential_change_user'], $result['rates']);
    }
    public function test_database_failures_roll_back_credentials_and_sessions_together(): void
    {
        foreach (['enroll_rollback', 'password_rollback', 'password_issue_failure'] as $scenario) {
            $result = $this->scenario($scenario);
            self::assertGreaterThanOrEqual(400, $result['response']['status']);
            self::assertTrue($result['user_unchanged']);
            self::assertTrue($result['sessions_unchanged']);
            self::assertSame(0, $result['mail_count']);
            self::assertFalse($result['email_change_consumed']);
        }
    }
    public function test_missing_session_storage_fails_closed(): void
    {
        $result = $this->scenario('missing_sessions');
        self::assertSame(401, $result['response']['status']);
        self::assertTrue($result['user_unchanged']);
    }
    public function test_removed_email_change_routes_reject_old_clients_and_valid_pending_links(): void
    {
        foreach (['email_success', 'email_request', 'email_cancel'] as $scenario) {
            $r = $this->scenario($scenario);
            self::assertSame(410, $r['response']['status']);
            self::assertSame('EMAIL_CHANGE_UNAVAILABLE', $r['response']['payload']['code']);
            self::assertTrue($r['user_unchanged']);
            self::assertTrue($r['sessions_unchanged']);
            self::assertFalse($r['email_change_consumed']);
            self::assertSame(0, $r['mail_count']);
        }
    }
    public function test_ordinary_profile_updates_do_not_revoke_sessions(): void
    {
        $result = $this->scenario('profile');
        self::assertSame(200, $result['response']['status']);
        self::assertTrue($result['sessions_unchanged']);
        self::assertSame('owner@example.invalid', $result['email']);
    }
}
