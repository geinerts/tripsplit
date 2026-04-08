<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

final class AccountLifecycleHelpersTest extends TestCase
{
    public function test_normalize_user_account_status_defaults_to_active(): void
    {
        self::assertSame('active', normalize_user_account_status(''));
        self::assertSame('active', normalize_user_account_status(null));
        self::assertSame('active', normalize_user_account_status('other'));
    }

    public function test_normalize_user_account_status_accepts_known_values(): void
    {
        self::assertSame('active', normalize_user_account_status('active'));
        self::assertSame('deactivated', normalize_user_account_status('deactivated'));
        self::assertSame('deleted', normalize_user_account_status('deleted'));
    }

    public function test_user_account_block_error_payload_for_deactivated_account(): void
    {
        $payload = user_account_block_error_payload(['account_status' => 'deactivated']);
        self::assertSame(false, $payload['ok']);
        self::assertSame('ACCOUNT_DEACTIVATED', $payload['code']);
        self::assertNotEmpty((string) $payload['error']);
    }

    public function test_user_account_block_error_payload_for_deleted_account(): void
    {
        $payload = user_account_block_error_payload(['account_status' => 'deleted']);
        self::assertSame(false, $payload['ok']);
        self::assertSame('ACCOUNT_DELETED', $payload['code']);
        self::assertNotEmpty((string) $payload['error']);
    }

    public function test_normalize_account_action_and_ttl_values(): void
    {
        self::assertSame('reactivate', normalize_account_action('reactivate'));
        self::assertSame('delete', normalize_account_action('delete'));
        self::assertSame('', normalize_account_action('invalid'));

        self::assertSame(86400, account_action_ttl_seconds('reactivate'));
        self::assertSame(3600, account_action_ttl_seconds('delete'));
    }
}
