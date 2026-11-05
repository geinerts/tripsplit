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
                'linked_changed_email', 'linked_unverified', 'linked_password_set', 'linked_placeholder'] as $scenario) { yield "$provider/$scenario" => [$provider, $scenario]; }
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
        self::assertSame(match ($scenario) {
            'linked_password_set' => true, 'linked_placeholder' => false, default => null,
        }, $r['response']['payload']['me']['has_password']);
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
                self::assertFalse($r['response']['payload']['me']['has_password']);
                self::assertSame('new@example.invalid', $r['authenticated_email']);
                self::assertTrue($r['authenticated_verified']);
                self::assertSame('owner@example.invalid', $r['original_email']);
                self::assertTrue($r['original_hash_unchanged']);
                self::assertSame(3, $r['user_count']);
                self::assertSame(1, $r['identity_count']);
            }
        }
    }
    public function test_authorization_code_is_exchanged_once_and_stored_only_encrypted(): void
    {
        foreach (['apple', 'google'] as $provider) {
            $r = $this->scenario($provider, 'linked_code');
            self::assertSame(200, $r['response']['status']);
            self::assertStringNotContainsString('synthetic-refresh-token', json_encode($r['response']));
            self::assertCount(1, $r['token_http']);
            $call = $r['token_http'][0];
            self::assertSame('synthetic-one-time-code', $call['fields']['code']);
            self::assertSame('authorization_code', $call['fields']['grant_type']);
            $stored = $r['stored_token'][0];
            self::assertStringStartsWith('enc:v1:', $stored['raw']);
            self::assertStringNotContainsString('synthetic-refresh-token', $stored['raw']);
            self::assertSame('synthetic-refresh-token', $stored['opened']['t']);
            if ($provider === 'apple') {
                self::assertSame('https://appleid.apple.com/auth/token', $call['url']);
                self::assertSame('synthetic-apple-client', $call['fields']['client_id']);
                self::assertSame('synthetic-apple-client', $stored['opened']['c']);
                self::assertSame(['alg' => 'ES256', 'kid' => 'SYNTHKEY'], $call['jwt']['header']);
                self::assertSame('SYNTHTEAM', $call['jwt']['claims']['iss']);
                self::assertSame('synthetic-apple-client', $call['jwt']['claims']['sub']);
                self::assertSame('https://appleid.apple.com', $call['jwt']['claims']['aud']);
                self::assertSame(64, $call['jwt']['signature_bytes']);
            } else {
                self::assertSame('https://oauth2.googleapis.com/token', $call['url']);
                self::assertSame('synthetic-web-client', $call['fields']['client_id']);
                self::assertSame('synthetic-web-secret', $call['fields']['client_secret']);
                self::assertSame('synthetic-web-client', $stored['opened']['c']);
            }
        }
    }
    public function test_new_account_also_stores_the_provider_token(): void
    {
        foreach (['apple', 'google'] as $provider) {
            $r = $this->scenario($provider, 'new_code_verified');
            self::assertSame(200, $r['response']['status']);
            self::assertSame('synthetic-refresh-token', $r['stored_token'][0]['opened']['t']);
        }
    }
    public static function loginNeverDependsOnTheExchange(): iterable
    {
        foreach (['apple', 'google'] as $provider) {
            foreach (['linked_code_refused', 'linked_code_throws', 'linked_code_unconfigured'] as $scenario) {
                yield "$provider/$scenario" => [$provider, $scenario];
            }
        }
    }
    #[DataProvider('loginNeverDependsOnTheExchange')]
    public function test_login_succeeds_without_storing_when_the_exchange_fails(string $provider, string $scenario): void
    {
        $r = $this->scenario($provider, $scenario);
        self::assertSame(200, $r['response']['status']);
        self::assertArrayHasKey('auth', $r['response']['payload']);
        self::assertNull($r['stored_token'][0]['raw']);
    }
    public static function codesNotExchanged(): iterable
    {
        foreach (['apple', 'google'] as $provider) {
            foreach (['linked_code_oversized', 'linked_code_not_string'] as $scenario) {
                yield "$provider/$scenario" => [$provider, $scenario];
            }
        }
    }
    #[DataProvider('codesNotExchanged')]
    public function test_malformed_code_is_ignored_without_calling_the_provider(string $provider, string $scenario): void
    {
        $r = $this->scenario($provider, $scenario);
        self::assertSame(200, $r['response']['status']);
        self::assertSame([], $r['token_http']);
        self::assertNull($r['stored_token'][0]['raw']);
    }
    public function test_existing_token_is_kept_without_another_exchange(): void
    {
        $r = $this->scenario('apple', 'linked_code_stored');
        self::assertSame(200, $r['response']['status']);
        self::assertSame([], $r['token_http']);
        self::assertSame('earlier-refresh-token', $r['stored_token'][0]['opened']['t']);
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
