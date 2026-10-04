<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

require_once __DIR__ . '/../../lib/helpers/helper_auth_user.php';
require_once __DIR__ . '/../../lib/helpers/helper_currency.php';

final class SubscriptionPreviewTest extends TestCase
{
    public function test_preview_matches_shared_mobile_contract(): void
    {
        $fixture = json_decode(
            file_get_contents(__DIR__ . '/../Fixtures/subscription_preview_v1.json'),
            true,
            512,
            JSON_THROW_ON_ERROR
        );
        self::assertSame($fixture, subscription_preview_payload(7));
    }

    public function test_draft_catalog_only_limits_owned_trips_and_currency_count(): void
    {
        self::assertSame([
            'free' => ['active_owned_trips' => 1, 'currencies_per_trip' => 2],
            'pro' => ['active_owned_trips' => null, 'currencies_per_trip' => null],
        ], subscription_plan_catalog());
    }

    public function test_draft_free_limits_do_not_change_current_access(): void
    {
        $preview = subscription_preview_payload(7);
        self::assertSame('preview', $preview['mode']);
        self::assertFalse($preview['billing_enabled']);
        self::assertFalse($preview['limits_enforced']);
        self::assertNull($preview['effective_limits']['active_owned_trips']);
        self::assertNull($preview['effective_limits']['currencies_per_trip']);
    }

    public function test_catalog_cannot_be_modified_by_a_previous_caller(): void
    {
        $catalog = subscription_plan_catalog();
        $catalog['free']['active_owned_trips'] = 99;
        self::assertSame(1, subscription_plan_catalog()['free']['active_owned_trips']);
    }

    public function test_preview_requires_a_valid_account(): void
    {
        $this->expectException(InvalidArgumentException::class);
        subscription_preview_payload(0);
    }

    public function test_negative_account_is_not_accepted(): void
    {
        $this->expectException(InvalidArgumentException::class);
        subscription_preview_payload(-1);
    }

    public function test_private_me_payload_uses_its_account_and_ignores_pro_fields(): void
    {
        $user = [
            'id' => 7,
            'nickname' => 'Test',
            'plan' => 'pro',
            'is_pro' => true,
            'subscription_preview' => ['plan' => 'pro', 'account_id' => 99],
        ];
        $me = build_me_payload($user);
        self::assertSame(subscription_preview_payload(7), $me['subscription_preview']);
        self::assertSame('Test', $me['nickname']);
        self::assertArrayNotHasKey('is_pro', $me);
        $user['id'] = 8;
        self::assertSame(8, build_me_payload($user)['subscription_preview']['account_id']);
    }
}
