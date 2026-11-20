<?php
declare(strict_types=1);

use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

require_once __DIR__ . '/../../config/config_auth_logging_rate.php';

/**
 * Security limits fail closed (2026-11-20): when they cannot be enforced the
 * request is refused with 503 instead of passing unchecked. Missing tables,
 * counting and the storage check run on MySQL
 * (tests/Integration/verify_reset_rate_limits.php).
 */
final class SecurityLimitsFailClosedTest extends TestCase
{
    private PDO $pdo;
    private string $previousLog;

    protected function setUp(): void
    {
        // No limit tables at all; these checks refuse before touching them.
        $this->pdo = new PDO('sqlite::memory:', null, null, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
        $this->previousLog = (string) ini_get('error_log');
        ini_set('error_log', '/dev/null');
    }

    protected function tearDown(): void
    {
        ini_set('error_log', $this->previousLog);
    }

    private function answer(callable $call): int
    {
        try {
            $call();
        } catch (ApiResponseException $response) {
            return $response->statusCode;
        }
        return 200;
    }



    public static function brokenSettings(): iterable
    {
        yield 'zero hits' => ['login_ip', 0, 900];
        yield 'negative hits' => ['login_ip', -1, 900];
        yield 'zero window' => ['login_ip', 10, 0];
        yield 'empty scope' => ['', 10, 900];
    }

    #[DataProvider('brokenSettings')]
    public function test_broken_limit_settings_refuse_instead_of_skipping(string $scope, int $max, int $window): void
    {
        self::assertSame(503, $this->answer(fn () => enforce_rate_limit($this->pdo, $scope, 'subject', $max, $window)));
    }


    public function test_broken_upload_quota_settings_refuse(): void
    {
        self::assertSame(503, $this->answer(fn () => enforce_upload_daily_quota($this->pdo, 'user', 7, 1000, 0, 1_000_000)));
        self::assertSame(503, $this->answer(fn () => enforce_upload_daily_quota($this->pdo, 'user', 7, 1000, 60, 0)));
        self::assertSame(503, $this->answer(fn () => enforce_upload_daily_quota($this->pdo, 'avatar', 7, 1000, 60, 1_000_000)));
    }

    public function test_silent_budget_says_no_when_storage_is_missing(): void
    {
        self::assertFalse(rate_limit_try($this->pdo, 'existing_account_notice', 'a@example.invalid', 1, 86400));
    }
}
