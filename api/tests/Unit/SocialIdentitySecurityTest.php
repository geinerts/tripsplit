<?php
declare(strict_types=1);
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

final class SocialIdentitySecurityTest extends TestCase
{
    private function scenario(string $provider, string $scenario): array
    {
        $process = proc_open([PHP_BINARY, __DIR__ . '/../Fixtures/social_security.php', $provider, $scenario],
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
        self::assertSame(0, $result['mail_count']);
        return $result;
    }
    public static function denied(): iterable
    {
        foreach (['apple', 'google'] as $provider) {
            foreach (['collision_verified', 'collision_false', 'collision_string_false', 'collision_missing',
                'new_false', 'new_missing', 'new_no_email', 'provider_mismatch', 'linked_different_subject',
                'subject_case', 'wrong_issuer', 'wrong_audience', 'expired', 'future', 'missing_subject',
                'bad_signature', 'wrong_algorithm'] as $scenario) { yield "$provider/$scenario" => [$provider, $scenario]; }
        }
    }
    #[DataProvider('denied')]
    public function test_unlinked_or_invalid_identity_cannot_take_over_any_existing_account(string $provider, string $scenario): void
    {
        $r = $this->scenario($provider, $scenario);
        self::assertContains($r['response']['status'], [401, 409]);
        self::assertTrue($r['users_unchanged']);
        self::assertTrue($r['identities_unchanged']);
        self::assertTrue($r['sessions_unchanged']);
        self::assertArrayNotHasKey('auth', $r['response']['payload']);
    }
    public static function returning(): iterable
    {
        foreach (['apple', 'google'] as $provider) {
            foreach (['linked_verified', 'linked_false', 'linked_missing', 'linked_no_email',
                'linked_changed_email', 'linked_unverified'] as $scenario) { yield "$provider/$scenario" => [$provider, $scenario]; }
        }
    }
    #[DataProvider('returning')]
    public function test_linked_subject_is_stable_and_cannot_rewrite_or_verify_contact_email(string $provider, string $scenario): void
    {
        $r = $this->scenario($provider, $scenario);
        if ($scenario === 'linked_unverified') {
            self::assertSame(403, $r['response']['status']);
            self::assertTrue($r['users_unchanged']);
            self::assertTrue($r['sessions_unchanged']);
            self::assertArrayNotHasKey('auth', $r['response']['payload']);
            return;
        }
        self::assertSame(200, $r['response']['status']);
        self::assertSame(1, $r['response']['payload']['me']['id']);
        self::assertSame('owner@example.invalid', $r['authenticated_email']);
        self::assertSame($scenario !== 'linked_unverified', $r['original_verified']);
        self::assertTrue($r['original_hash_unchanged']);
        self::assertSame(2, $r['user_count']);
        self::assertSame(1, $r['identity_count']);
        self::assertSame(4, $r['session_count']);
    }
    public function test_new_verified_users_get_their_own_account_not_the_client_supplied_email(): void
    {
        foreach (['apple', 'google'] as $provider) {
            foreach (['new_verified', 'new_string_true'] as $scenario) {
                $r = $this->scenario($provider, $scenario);
                self::assertSame(200, $r['response']['status']);
                self::assertSame(3, $r['response']['payload']['me']['id']);
                self::assertSame('new@example.invalid', $r['authenticated_email']);
                self::assertTrue($r['authenticated_verified']);
                self::assertSame('owner@example.invalid', $r['original_email']);
                self::assertTrue($r['original_hash_unchanged']);
                self::assertSame(3, $r['user_count']);
                self::assertSame(1, $r['identity_count']);
            }
        }
    }
    public function test_inactive_linked_account_cannot_sign_in(): void
    {
        foreach (['apple', 'google'] as $provider) {
            $r = $this->scenario($provider, 'inactive');
            self::assertSame(403, $r['response']['status']);
            self::assertTrue($r['users_unchanged']);
            self::assertSame(3, $r['session_count']);
            self::assertArrayNotHasKey('auth', $r['response']['payload']);
        }
    }
}
