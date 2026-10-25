<?php
declare(strict_types=1);

use PHPUnit\Framework\Attributes\PreserveGlobalState;
use PHPUnit\Framework\Attributes\RunInSeparateProcess;
use PHPUnit\Framework\TestCase;

require_once __DIR__ . '/../../lib/helpers/push/push_crypto.php';
require_once __DIR__ . '/../../lib/helpers/push/push_transport_apns_auth.php';

final class ApnsSignatureTest extends TestCase
{
    public function test_short_integers_are_padded_to_32_bytes(): void
    {
        self::assertSame(
            str_repeat("\x00", 31) . "\x01" . str_repeat("\x00", 31) . "\x02",
            push_apns_es256_signature("\x30\x06\x02\x01\x01\x02\x01\x02")
        );
    }

    public function test_sign_padding_is_removed(): void
    {
        $r = "\x80" . str_repeat("\x01", 31);
        $s = str_repeat("\x7f", 32);
        self::assertSame($r . $s, push_apns_es256_signature("\x30\x45\x02\x21\x00" . $r . "\x02\x20" . $s));
    }

    public function test_invalid_der_is_rejected(): void
    {
        $valid = "\x30\x06\x02\x01\x01\x02\x01\x02";
        foreach ([
            '', "\x30", substr($valid, 0, -1), $valid . "\x00",
            "\x30\x06\x02\x01\x80\x02\x01\x02",
            "\x30\x06\x02\x01\x00\x02\x01\x02",
            "\x30\x07\x02\x02\x00\x01\x02\x01\x02",
            "\x30\x06\x03\x01\x01\x02\x01\x02",
            "\x30\x06\x02\x7f\x01\x02\x01\x02",
            "\x30\x26\x02\x21" . str_repeat("\x01", 33) . "\x02\x01\x02",
        ] as $invalid) {
            self::assertSame('', push_apns_es256_signature($invalid));
        }
    }

    public function test_real_openssl_signatures_round_trip(): void
    {
        $key = openssl_pkey_new(['private_key_type' => OPENSSL_KEYTYPE_EC, 'curve_name' => 'prime256v1']);
        self::assertNotFalse($key);
        $publicKey = openssl_pkey_get_details($key)['key'];
        for ($i = 0; $i < 64; $i++) {
            $message = 'APNs test ' . $i;
            self::assertTrue(openssl_sign($message, $der, $key, OPENSSL_ALGO_SHA256));
            $raw = push_apns_es256_signature($der);
            self::assertSame(64, strlen($raw));
            self::assertSame(1, openssl_verify($message, self::toDer($raw), $publicKey, OPENSSL_ALGO_SHA256));
        }
    }

    #[RunInSeparateProcess]
    #[PreserveGlobalState(false)]
    public function test_jwt_has_valid_es256_signature_and_expected_claims(): void
    {
        $path = tempnam(sys_get_temp_dir(), 'apns-test-');
        self::assertNotFalse($path);
        try {
            $key = openssl_pkey_new(['private_key_type' => OPENSSL_KEYTYPE_EC, 'curve_name' => 'prime256v1']);
            self::assertNotFalse($key);
            self::assertTrue(openssl_pkey_export($key, $pem));
            file_put_contents($path, $pem);
            define('PUSH_APNS_PRIVATE_KEY_REL_PATH', $path);
            define('PUSH_APNS_KEY_ID', 'TESTKEY123');
            define('PUSH_APNS_TEAM_ID', 'TESTTEAM12');
            $jwt = push_apns_jwt();
            $parts = explode('.', $jwt);
            self::assertCount(3, $parts);
            $decode = static fn(string $part): string => base64_decode(strtr($part, '-_', '+/'), true);
            self::assertSame(['alg' => 'ES256', 'kid' => 'TESTKEY123'], json_decode($decode($parts[0]), true));
            $claims = json_decode($decode($parts[1]), true);
            self::assertSame('TESTTEAM12', $claims['iss']);
            self::assertEqualsWithDelta(time(), $claims['iat'], 2);
            $raw = $decode($parts[2]);
            self::assertSame(64, strlen($raw));
            self::assertSame(1, openssl_verify($parts[0] . '.' . $parts[1], self::toDer($raw), openssl_pkey_get_details($key)['key'], OPENSSL_ALGO_SHA256));
            self::assertSame($jwt, push_apns_jwt());
        } finally {
            unlink($path);
        }
    }

    private static function toDer(string $raw): string
    {
        $content = '';
        foreach (str_split($raw, 32) as $integer) {
            $integer = ltrim($integer, "\x00");
            if ((ord($integer[0]) & 0x80) !== 0) {
                $integer = "\x00" . $integer;
            }
            $content .= "\x02" . chr(strlen($integer)) . $integer;
        }
        return "\x30" . chr(strlen($content)) . $content;
    }
}
