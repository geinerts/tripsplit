<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

require_once __DIR__ . '/../../lib/helpers/helper_receipt_ownership.php';
require_once __DIR__ . '/../../lib/helpers/helper_auth_user.php';
require_once __DIR__ . '/../../lib/actions/friends/friends_helpers.php';

if (!defined('AUTH_ACCESS_TOKEN_SECRET')) {
    define('AUTH_ACCESS_TOKEN_SECRET', str_repeat('unit-test-only-', 4));
}

final class BackendDataIsolationTest extends TestCase
{
    public function test_uploader_can_attach_own_receipt(): void
    {
        $path = receipt_owned_upload_path('uploads/receipts/20260918_120000_0123456789abcdef.webp', 7);
        assert_receipt_attachment_owned($path, 7);
        self::assertNotSame($path, receipt_owned_upload_path('uploads/receipts/20260918_120000_0123456789abcdef.webp', 8));
    }

    public function test_known_receipt_path_cannot_be_attached_by_another_user(): void
    {
        $path = receipt_owned_upload_path('uploads/receipts/test.webp', 7);
        $this->expectException(ApiResponseException::class);
        $this->expectExceptionCode(403);
        assert_receipt_attachment_owned($path, 8);
    }

    public function test_receipt_name_tampering_cannot_reuse_ownership_signature(): void
    {
        $path = receipt_owned_upload_path('uploads/receipts/test.webp', 7);
        $this->expectException(ApiResponseException::class);
        $this->expectExceptionCode(403);
        assert_receipt_attachment_owned(str_replace('/test_', '/victim_', $path), 7);
    }

    public function test_unowned_legacy_receipt_cannot_be_newly_attached(): void
    {
        $this->expectException(ApiResponseException::class);
        $this->expectExceptionCode(403);
        assert_receipt_attachment_owned('uploads/receipts/legacy.webp', 7);
    }

    public function test_unchanged_legacy_attachment_and_removal_remain_supported(): void
    {
        assert_receipt_attachment_owned('uploads/receipts/legacy.webp', 7, 'uploads/receipts/legacy.webp');
        assert_receipt_attachment_owned('', 7);
        $this->addToAssertionCount(2);
    }

    public function test_shared_receipt_is_not_deleted(): void
    {
        $statement = $this->createMock(PDOStatement::class);
        $statement->expects(self::once())->method('execute')->with(['path' => 'uploads/receipts/shared.webp']);
        $statement->method('fetchColumn')->willReturn(1);
        $pdo = $this->createMock(PDO::class);
        $pdo->expects(self::once())->method('prepare')
            ->with('SELECT 1 FROM trip_expenses WHERE receipt_path = :path LIMIT 1')->willReturn($statement);
        // No filesystem configuration is loaded; attempting deletion would fail this test.
        delete_unreferenced_receipt($pdo, 'uploads/receipts/shared.webp');
    }

    public function test_public_and_pending_friend_payloads_exclude_financial_details(): void
    {
        $row = ['id' => 7, 'nickname' => 'Test', 'bank_iban' => 'PRIVATE_IBAN',
            'bank_bic' => 'PRIVATE_BIC', 'bank_account_number' => 'PRIVATE_ACCOUNT',
            'paypal_me_link' => 'PRIVATE_PAYPAL', 'revolut_handle' => 'PRIVATE_REVOLUT',
            'wise_pay_link' => 'PRIVATE_WISE', 'email' => 'private@example.test',
            'password_hash' => 'PRIVATE_HASH'];
        $public = friend_user_payload_from_row($row);
        foreach (array_keys($row) as $key) {
            if (!in_array($key, ['id', 'nickname'], true)) {
                self::assertArrayNotHasKey($key, $public);
            }
        }
        self::assertSame('PRIVATE_IBAN', friend_user_payload_from_row($row, true)['bank_iban']);
        self::assertArrayNotHasKey('password_hash', friend_user_payload_from_row($row, true));
    }
}
