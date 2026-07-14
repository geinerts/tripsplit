<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

class AdminSecurityTest extends TestCase
{
    public function test_session_token_is_hashed_before_storage(): void
    {
        $token = str_repeat('a', 64);

        $this->assertSame(hash('sha256', $token), admin_session_token_hash($token));
        $this->assertNotSame($token, admin_session_token_hash($token));
    }

    public function test_invalid_session_token_is_not_hashed(): void
    {
        $this->assertSame('', admin_session_token_hash('not-a-session-token'));
        $this->assertSame('', admin_session_token_hash(str_repeat('A', 64)));
    }

    public function test_totp_secret_is_encrypted_and_can_be_decrypted(): void
    {
        $secret = admin_totp_generate_secret();
        $encrypted = admin_totp_encrypt_secret($secret);

        $this->assertStringStartsWith('enc:v1:', $encrypted);
        $this->assertStringNotContainsString($secret, $encrypted);
        $this->assertSame($secret, admin_totp_decrypt_secret($encrypted));
    }

    public function test_totp_ciphertext_tampering_is_rejected(): void
    {
        $encrypted = admin_totp_encrypt_secret(admin_totp_generate_secret());
        $last = substr($encrypted, -1);
        $tampered = substr($encrypted, 0, -1) . ($last === 'A' ? 'B' : 'A');

        $this->assertSame('', admin_totp_decrypt_secret($tampered));
    }

    public function test_legacy_admin_key_actions_are_not_routable(): void
    {
        $handlers = api_action_handlers();

        foreach ([
            'admin_summary',
            'admin_users',
            'admin_user_detail',
            'admin_delete_expense',
            'admin_update_user',
            'admin_delete_user',
            'admin_feedback_feed',
            'admin_archive_feedback',
            'admin_delete_feedback',
        ] as $action) {
            $this->assertArrayNotHasKey($action, $handlers);
        }
    }
}
