<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

require_once __DIR__ . '/../../lib/helpers/helper_subscription_sandbox.php';

/** SQLite exercises real SQL/rollback/uniqueness, not MySQL lock semantics. */
final class SubscriptionTestDatabase extends PDO
{
    public function __construct()
    {
        parent::__construct('sqlite::memory:', null, null, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
        $this->exec('PRAGMA foreign_keys = ON');
        $this->exec('CREATE TABLE trip_users (id INTEGER PRIMARY KEY, account_status TEXT NOT NULL)');
        $this->exec("INSERT INTO trip_users VALUES (7, 'active'), (8, 'active'), (9, 'deleted')");
        $this->exec('CREATE TABLE trip_subscription_accounts (user_id INTEGER PRIMARY KEY REFERENCES trip_users(id),
            account_token TEXT NOT NULL UNIQUE, verification_sequence INTEGER NOT NULL DEFAULT 0)');
        $this->exec('CREATE TABLE trip_subscription_sandbox_attempts (account_token TEXT REFERENCES trip_subscription_accounts(account_token),
            request_hash TEXT, reference_hash TEXT, verification_sequence INTEGER, status TEXT,
            PRIMARY KEY (account_token, request_hash))');
        $this->exec('CREATE TABLE trip_subscription_sandbox_purchases (purchase_hash TEXT PRIMARY KEY,
            account_token TEXT REFERENCES trip_subscription_accounts(account_token), store TEXT, product_id TEXT,
            expires_at_ms INTEGER, access_allowed INTEGER, provider_status TEXT, auto_renew INTEGER,
            verified_at_ms INTEGER, verification_sequence INTEGER)');
    }

    public function prepare(string $query, array $options = []): PDOStatement|false
    {
        $query = str_replace(' FOR UPDATE', '', $query);
        $query = str_replace(' ON DUPLICATE KEY UPDATE purchase_hash = purchase_hash',
            ' ON CONFLICT(purchase_hash) DO NOTHING', $query);
        return parent::prepare($query, $options);
    }
}

final class SubscriptionTestVerifier implements SubscriptionSandboxVerifier
{
    public int $calls = 0;
    public function __construct(private Closure $callback) {}
    public function verify(string $accountToken, string $purchaseReference): array
    {
        $this->calls++;
        return ($this->callback)($accountToken, $purchaseReference);
    }
}

final class SubscriptionSandboxTest extends TestCase
{
    private const PRODUCTS = ['app_store' => ['prodmonthly', 'prodyearly']];
    private SubscriptionTestDatabase $pdo;

    protected function setUp(): void
    {
        $this->pdo = new SubscriptionTestDatabase();
    }

    private function verified(string $token, array $overrides = []): array
    {
        return array_replace([
            'environment' => 'sandbox', 'account_token' => $token,
            'store' => 'app_store', 'product_id' => 'prodmonthly',
            'original_purchase_id' => 'stable-original-purchase',
            'expires_at_ms' => 1900000000000, 'access_allowed' => true,
            'provider_status' => 'active', 'auto_renew' => true,
        ], $overrides);
    }

    private function verifier(array $overrides = []): SubscriptionTestVerifier
    {
        return new SubscriptionTestVerifier(fn($token) => $this->verified($token, $overrides));
    }

    private function verify(SubscriptionSandboxVerifier $verifier, string $key = 'request-0001', int $userId = 7): array
    {
        return subscription_sandbox_verify($this->pdo, $userId, $verifier, 'subtest', $key, self::PRODUCTS);
    }

    public function test_identity_is_random_stable_and_account_specific(): void
    {
        $first = subscription_sandbox_identity($this->pdo, 7);
        self::assertMatchesRegularExpression('/^[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$/', $first['account_token']);
        self::assertSame($first['account_token'], subscription_sandbox_identity($this->pdo, 7)['account_token']);
        self::assertNotSame($first['account_token'], subscription_sandbox_identity($this->pdo, 8)['account_token']);
    }

    public function test_deleted_account_cannot_start_verification(): void
    {
        $verifier = $this->verifier();
        try {
            $this->verify($verifier, userId: 9);
            self::fail('Deleted account was accepted.');
        } catch (DomainException $error) {
            self::assertSame(0, $verifier->calls);
            self::assertFalse($this->pdo->inTransaction());
        }
    }

    public function test_verified_purchase_is_applied_once_and_raw_reference_not_stored(): void
    {
        $verifier = $this->verifier();
        self::assertSame(['status' => 'applied', 'duplicate' => false], $this->verify($verifier));
        self::assertSame(['status' => 'applied', 'duplicate' => true], $this->verify($verifier));
        self::assertSame(1, $verifier->calls);
        $rows = $this->pdo->query('SELECT * FROM trip_subscription_sandbox_purchases')->fetchAll(PDO::FETCH_ASSOC);
        self::assertCount(1, $rows);
        self::assertStringNotContainsString('stable-original-purchase', json_encode($rows));
        $attempts = $this->pdo->query('SELECT * FROM trip_subscription_sandbox_attempts')->fetchAll(PDO::FETCH_ASSOC);
        self::assertStringNotContainsString('subtest', json_encode($attempts));
    }

    public function test_same_request_key_cannot_be_reused_for_another_reference(): void
    {
        $verifier = $this->verifier();
        $this->verify($verifier);
        $this->expectException(DomainException::class);
        subscription_sandbox_verify($this->pdo, 7, $verifier, 'subdifferent', 'request-0001', self::PRODUCTS);
    }

    public function test_same_purchase_cannot_be_claimed_by_another_account(): void
    {
        $this->verify($this->verifier());
        try {
            $this->verify($this->verifier(), userId: 8);
            self::fail('Purchase changed owner.');
        } catch (DomainException $error) {
            $row = $this->pdo->query('SELECT account_token FROM trip_subscription_sandbox_purchases')->fetchColumn();
            self::assertSame(subscription_sandbox_identity($this->pdo, 7)['account_token'], $row);
            self::assertSame(1, (int) $this->pdo->query('SELECT COUNT(*) FROM trip_subscription_sandbox_purchases')->fetchColumn());
        }
    }

    public function test_older_provider_response_cannot_overwrite_newer_verification(): void
    {
        $older = new SubscriptionTestVerifier(function ($token) {
            self::assertFalse($this->pdo->inTransaction());
            $this->verify($this->verifier(['access_allowed' => false, 'provider_status' => 'expired']), 'request-0002');
            return $this->verified($token);
        });
        self::assertSame('superseded', $this->verify($older)['status']);
        self::assertSame(0, (int) $this->pdo->query('SELECT access_allowed FROM trip_subscription_sandbox_purchases')->fetchColumn());
    }

    public function test_concurrent_checks_of_different_purchases_are_both_retained(): void
    {
        $older = new SubscriptionTestVerifier(function ($token) {
            $this->verify($this->verifier(['original_purchase_id' => 'different']), 'request-0002');
            return $this->verified($token);
        });
        self::assertSame('applied', $this->verify($older)['status']);
        self::assertSame(2, (int) $this->pdo->query('SELECT COUNT(*) FROM trip_subscription_sandbox_purchases')->fetchColumn());
    }

    public function test_failed_provider_does_not_replace_previous_state_and_can_retry_with_new_key(): void
    {
        $this->verify($this->verifier());
        $failure = new SubscriptionTestVerifier(static fn() => throw new RuntimeException('Unavailable'));
        try {
            $this->verify($failure, 'request-0002');
            self::fail('Expected provider error.');
        } catch (RuntimeException $error) {
            self::assertSame('failed', $this->verify($failure, 'request-0002')['status']);
            self::assertSame(1, $failure->calls);
            self::assertSame(1, (int) $this->pdo->query('SELECT access_allowed FROM trip_subscription_sandbox_purchases')->fetchColumn());
        }
        self::assertSame('applied', $this->verify($this->verifier(), 'request-0003')['status']);
    }

    public function test_account_deleted_while_provider_responds_cannot_store_purchase(): void
    {
        $verifier = new SubscriptionTestVerifier(function ($token) {
            $this->pdo->exec("UPDATE trip_users SET account_status = 'deleted' WHERE id = 7");
            return $this->verified($token);
        });
        try {
            $this->verify($verifier);
            self::fail('Deleted account accepted.');
        } catch (DomainException $error) {
            self::assertSame(0, (int) $this->pdo->query('SELECT COUNT(*) FROM trip_subscription_sandbox_purchases')->fetchColumn());
        }
    }

    public function test_wrong_environment_account_product_store_or_types_fail_closed(): void
    {
        $token = subscription_account_token();
        foreach ([['environment' => 'production'], ['account_token' => subscription_account_token()],
            ['product_id' => 'unknown'], ['store' => 'promotional'], ['expires_at_ms' => '1900000000000'],
            ['expires_at_ms' => -1], ['access_allowed' => 'true'], ['auto_renew' => 1],
            ['provider_status' => 'invented'], ['original_purchase_id' => '']] as $invalid) {
            try {
                subscription_sandbox_observation($this->verified($token, $invalid), $token, self::PRODUCTS, 1800000000000);
                self::fail('Malformed verified state accepted.');
            } catch (DomainException $error) {
                $this->addToAssertionCount(1);
            }
        }
    }

    public function test_cancellation_does_not_remove_remaining_paid_time_but_access_denial_does(): void
    {
        $token = subscription_account_token();
        $now = 1800000000000;
        $state = subscription_sandbox_observation($this->verified($token, ['auto_renew' => false]), $token, self::PRODUCTS, $now);
        self::assertSame('active', subscription_sandbox_state($state, $now));
        $state['access_allowed'] = 0;
        self::assertSame('inactive', subscription_sandbox_state($state, $now));
    }

    public function test_grace_expiry_and_freshness_are_not_permanent_access(): void
    {
        $now = 1800000000000;
        $token = subscription_account_token();
        $state = subscription_sandbox_observation($this->verified($token,
            ['provider_status' => 'in_grace_period', 'expires_at_ms' => $now - 1]), $token, self::PRODUCTS, $now);
        self::assertSame('grace_period', subscription_sandbox_state($state, $now));
        self::assertSame('needs_verification', subscription_sandbox_state($state, $now + 300000));
        self::assertSame('needs_verification', subscription_sandbox_state($state, $now - 1));
        $state['provider_status'] = 'active';
        self::assertSame('needs_verification', subscription_sandbox_state($state, $now));
    }
}
