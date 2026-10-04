<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

require_once __DIR__ . '/../../lib/helpers/helper_revenuecat_sandbox.php';
require_once __DIR__ . '/../../config/config_env.php';
require_once __DIR__ . '/../../lib/actions/subscription_sandbox_actions.php';

final class RevenueCatSandboxTest extends TestCase
{
    private function response(string $token): array
    {
        return ['object' => 'subscription', 'id' => 'subtest', 'customer_id' => $token,
            'original_customer_id' => $token, 'ownership' => 'purchased', 'environment' => 'sandbox',
            'store' => 'app_store', 'product_id' => 'prodmonthly', 'ends_at' => 1900000000000,
            'gives_access' => true, 'auto_renewal_status' => 'will_renew', 'status' => 'active',
            'entitlements' => ['items' => [['lookup_key' => 'splyto_pro', 'project_id' => 'projtest', 'state' => 'active']]]];
    }

    private function verifier(array $response): RevenueCatSandboxVerifier
    {
        return new RevenueCatSandboxVerifier('projtest', str_repeat('test-only-', 4), 'splyto_pro',
            static function ($url, $key) use ($response): array {
                self::assertSame('https://api.revenuecat.com/v2/projects/projtest/subscriptions/subtest', $url);
                self::assertSame(str_repeat('test-only-', 4), $key);
                return $response;
            });
    }

    public function test_only_authoritative_response_is_normalized_and_renewal_id_is_not_identity(): void
    {
        $token = subscription_account_token();
        $response = $this->response($token) + ['store_subscription_identifier' => 'renewal-123'];
        $verified = $this->verifier($response)->verify($token, 'subtest');
        self::assertSame('revenuecat:projtest:subtest', $verified['original_purchase_id']);
        self::assertTrue($verified['access_allowed']);
        self::assertSame($token, $verified['account_token']);
    }

    public function test_foreign_transferred_shared_production_and_promotional_purchases_are_rejected(): void
    {
        $token = subscription_account_token();
        foreach (['customer_id' => subscription_account_token(), 'original_customer_id' => subscription_account_token(),
            'environment' => 'production', 'ownership' => 'family_shared', 'store' => 'promotional', 'id' => 'subother',
            'gives_access' => 'true', 'entitlements' => ['items' => []], 'auto_renewal_status' => 'unknown'] as $field => $bad) {
            try {
                $this->verifier(array_replace($this->response($token), [$field => $bad]))->verify($token, 'subtest');
                self::fail('Invalid binding accepted: ' . $field);
            } catch (DomainException $error) {
                $this->addToAssertionCount(1);
            }
        }
    }

    public function test_cancelled_and_revoked_access_follow_provider_not_client(): void
    {
        $token = subscription_account_token();
        $response = array_replace($this->response($token), ['auto_renewal_status' => 'will_not_renew']);
        $verified = $this->verifier($response)->verify($token, 'subtest');
        self::assertFalse($verified['auto_renew']);
        self::assertTrue($verified['access_allowed']);
        $response['gives_access'] = false;
        self::assertFalse($this->verifier($response)->verify($token, 'subtest')['access_allowed']);
    }

    public function test_invalid_reference_never_calls_provider(): void
    {
        $verifier = new RevenueCatSandboxVerifier('projtest', str_repeat('test-only-', 4), 'splyto_pro',
            static function (): array { self::fail('Unexpected provider request.'); });
        $this->expectException(DomainException::class);
        $verifier->verify(subscription_account_token(), '../../customers/victim');
    }

    public function test_transport_does_not_accept_arbitrary_hosts(): void
    {
        $this->expectException(InvalidArgumentException::class);
        revenuecat_sandbox_get('http://127.0.0.1/private', str_repeat('test-only-', 4));
    }

    public function test_sandbox_requires_explicit_enablement_testers_and_product_allowlist(): void
    {
        $before = $_ENV;
        try {
            $_ENV['TRIP_RC_SANDBOX_ENABLED'] = 'false';
            self::assertNull(revenuecat_sandbox_config());
            $_ENV['TRIP_RC_SANDBOX_ENABLED'] = 'true';
            $_ENV['TRIP_RC_PROJECT_ID'] = 'projtest';
            $_ENV['TRIP_RC_SECRET_KEY'] = str_repeat('test-only-', 4);
            $_ENV['TRIP_RC_ENTITLEMENT'] = 'splyto_pro';
            $_ENV['TRIP_RC_SANDBOX_USER_IDS'] = '7';
            $_ENV['TRIP_RC_SANDBOX_PRODUCTS'] = '{"app_store":["prodmonthly"]}';
            $config = revenuecat_sandbox_config();
            self::assertSame([7], $config['testers']);
            self::assertInstanceOf(RevenueCatSandboxVerifier::class, $config['verifier']);
            $_ENV['TRIP_RC_SANDBOX_USER_IDS'] = '*';
            self::assertNull(revenuecat_sandbox_config());
            $_ENV['TRIP_RC_SANDBOX_USER_IDS'] = '7';
            $_ENV['TRIP_RC_SANDBOX_PRODUCTS'] = '{}';
            self::assertNull(revenuecat_sandbox_config());
        } finally {
            $_ENV = $before;
        }
    }
}
