<?php
declare(strict_types=1);

use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

final class RegistrationSecurityTest extends TestCase
{
    private function runScenario(string $scenario, bool $hasNames = true): array
    {
        $process = proc_open([PHP_BINARY, __DIR__ . '/../Fixtures/registration_security.php',
            $scenario, $hasNames ? 'names' : 'legacy'],
            [0 => ['pipe', 'r'], 1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes);
        self::assertIsResource($process);
        fclose($pipes[0]);
        $output = stream_get_contents($pipes[1]);
        $errors = stream_get_contents($pipes[2]);
        fclose($pipes[1]);
        fclose($pipes[2]);
        self::assertSame(0, proc_close($process), $errors);
        self::assertSame('', $errors);
        return json_decode($output, true, 512, JSON_THROW_ON_ERROR);
    }

    public static function existingAccounts(): iterable
    {
        foreach ([true, false] as $hasNames) {
            foreach (['existing_guest', 'existing_credentials', 'existing_same_email',
                'existing_unverified', 'existing_inactive', 'existing_no_credentials', 'duplicate_email'] as $scenario) {
                yield $scenario . ($hasNames ? '-names' : '-legacy') => [$scenario, $hasNames];
            }
        }
    }

    #[DataProvider('existingAccounts')]
    public function test_registration_never_reuses_or_updates_an_existing_identity(string $scenario, bool $hasNames): void
    {
        $result = $this->runScenario($scenario, $hasNames);
        self::assertSame(409, $result['response']['status']);
        self::assertSame('REGISTRATION_CONFLICT', $result['response']['payload']['code']);
        self::assertArrayNotHasKey('auth', $result['response']['payload']);
        self::assertArrayNotHasKey('me', $result['response']['payload']);
        self::assertTrue($result['existing_unchanged']);
        self::assertSame(1, $result['user_count']);
        self::assertSame([], $result['auth_issued']);
        self::assertSame([], $result['mail_users']);
        self::assertSame([], $result['event_users']);
    }

    public function test_new_guest_gets_only_the_newly_created_identity(): void
    {
        foreach ([true, false] as $hasNames) {
            $result = $this->runScenario('new_guest', $hasNames);
            self::assertSame(200, $result['response']['status']);
            self::assertSame(2, $result['response']['payload']['me']['id']);
            self::assertSame([2], $result['auth_issued']);
            self::assertSame([2], $result['event_users']);
            self::assertSame(2, $result['user_count']);
            self::assertTrue($result['existing_unchanged']);
            self::assertSame(['register_proof_ip', 'register_proof_token', 'register_ip', 'register_token'],
                $result['rate_scopes']);
        }
    }

    public function test_new_credentials_still_require_email_verification(): void
    {
        foreach ([true, false] as $hasNames) {
            $result = $this->runScenario('new_credentials', $hasNames);
            self::assertSame(200, $result['response']['status']);
            self::assertSame('EMAIL_VERIFICATION_REQUIRED', $result['response']['payload']['code']);
            self::assertTrue($result['new_password_matches']);
            self::assertFalse($result['new_email_verified']);
            self::assertSame([], $result['auth_issued']);
            self::assertSame([2], $result['mail_users']);
            self::assertSame(2, $result['user_count']);
            self::assertTrue($result['existing_unchanged']);
        }
    }

    public function test_replaying_even_a_valid_registration_proof_does_not_issue_more_sessions(): void
    {
        $result = $this->runScenario('replay');
        self::assertSame(200, $result['first_response']['status']);
        self::assertSame(409, $result['response']['status']);
        self::assertSame([2], $result['auth_issued']);
        self::assertSame([2], $result['event_users']);
        self::assertSame(2, $result['user_count']);
    }

    public function test_invalid_proof_never_creates_a_user_or_session(): void
    {
        $result = $this->runScenario('invalid_proof');
        self::assertSame(400, $result['response']['status']);
        self::assertSame(1, $result['user_count']);
        self::assertTrue($result['existing_unchanged']);
        self::assertSame([], $result['auth_issued']);
    }

    public function test_database_outage_is_not_disguised_as_success_or_registration_conflict(): void
    {
        $result = $this->runScenario('database_failure');
        self::assertTrue($result['database_error_propagated']);
        self::assertSame([], $result['auth_issued']);
        self::assertSame([], $result['mail_users']);
    }
}
