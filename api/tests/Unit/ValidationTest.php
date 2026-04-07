<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

/**
 * Validation tests.
 * json_out() is replaced in bootstrap.php to throw ApiResponseException
 * instead of calling exit — so we can assert on error messages.
 */
class ValidationTest extends TestCase
{
    // --- validate_email_address ---

    public function test_valid_email_is_returned_lowercase(): void
    {
        $this->assertSame('user@example.com', validate_email_address('User@Example.COM'));
    }

    public function test_valid_email_with_plus(): void
    {
        $this->assertSame('user+tag@example.com', validate_email_address('user+tag@example.com'));
    }

    public function test_invalid_email_throws(): void
    {
        $this->expectException(ApiResponseException::class);
        $this->expectExceptionCode(400);
        validate_email_address('not-an-email');
    }

    public function test_empty_email_throws(): void
    {
        $this->expectException(ApiResponseException::class);
        validate_email_address('');
    }

    // --- validate_password_plain ---

    public function test_valid_password_is_returned(): void
    {
        $pass = 'Secure1!';
        $this->assertSame($pass, validate_password_plain($pass));
    }

    public function test_password_too_short_throws(): void
    {
        $this->expectException(ApiResponseException::class);
        $this->expectExceptionMessage('Password must be 8-128 chars.');
        validate_password_plain('Ab1!');
    }

    public function test_password_no_uppercase_throws(): void
    {
        $this->expectException(ApiResponseException::class);
        $this->expectExceptionMessage('Password must include at least one uppercase letter.');
        validate_password_plain('secure1!pass');
    }

    public function test_password_no_number_throws(): void
    {
        $this->expectException(ApiResponseException::class);
        $this->expectExceptionMessage('Password must include at least one number.');
        validate_password_plain('SecurePass!');
    }

    public function test_password_no_symbol_throws(): void
    {
        $this->expectException(ApiResponseException::class);
        $this->expectExceptionMessage('Password must include at least one symbol.');
        validate_password_plain('SecurePass1');
    }

    // --- validate_person_name ---

    public function test_valid_first_name(): void
    {
        $this->assertSame('Matiss', validate_person_name('Matiss', 'First name'));
    }

    public function test_name_with_hyphen(): void
    {
        $this->assertSame('Anna-Marie', validate_person_name('Anna-Marie', 'First name'));
    }

    public function test_name_trims_extra_spaces(): void
    {
        $this->assertSame('Matiss Geinerts', validate_person_name('  Matiss  Geinerts  ', 'First name'));
    }

    public function test_name_too_short_throws(): void
    {
        $this->expectException(ApiResponseException::class);
        $this->expectExceptionMessage('First name must be 2-64 chars.');
        validate_person_name('A', 'First name');
    }

    public function test_name_with_numbers_throws(): void
    {
        $this->expectException(ApiResponseException::class);
        validate_person_name('M4tiss', 'First name');
    }

    // --- base64url_encode / base64url_decode ---

    public function test_base64url_encode_decode_roundtrip(): void
    {
        $raw = 'hello world 123!@#';
        $encoded = base64url_encode($raw);
        $this->assertSame($raw, base64url_decode($encoded));
    }

    public function test_base64url_has_no_padding(): void
    {
        $encoded = base64url_encode('test');
        $this->assertStringNotContainsString('=', $encoded);
    }

    public function test_base64url_has_no_plus_or_slash(): void
    {
        $encoded = base64url_encode(str_repeat('binary', 100));
        $this->assertStringNotContainsString('+', $encoded);
        $this->assertStringNotContainsString('/', $encoded);
    }
}
