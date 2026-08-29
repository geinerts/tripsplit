<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

final class PrivateMediaSecurityTest extends TestCase
{
    public function test_receipt_signature_accepts_only_matching_unexpired_request(): void
    {
        $path = 'uploads/receipts/0123456789abcdef.webp';
        $expiresAt = time() + 300;
        $signature = private_receipt_signature($path, $expiresAt);

        self::assertTrue(private_receipt_request_is_valid($path, $expiresAt, $signature));
        self::assertFalse(private_receipt_request_is_valid($path . 'x', $expiresAt, $signature));
        self::assertFalse(private_receipt_request_is_valid($path, time() - 1, $signature));
    }

    public function test_receipt_path_cannot_escape_private_directory(): void
    {
        self::assertSame(
            'uploads/receipts/receipt_thumb.webp',
            normalize_private_receipt_path('uploads/receipts/receipt_thumb.webp')
        );
        self::assertNull(normalize_private_receipt_path('../.env'));
        self::assertNull(normalize_private_receipt_path('uploads/avatars/avatar.webp'));
        self::assertNull(normalize_private_receipt_path('uploads/receipts/subdir/receipt.webp'));
    }

    public function test_logout_route_and_session_cap_are_enabled(): void
    {
        self::assertArrayHasKey('logout_session', api_action_handlers());
        self::assertSame(8, auth_max_active_sessions());
    }
}
