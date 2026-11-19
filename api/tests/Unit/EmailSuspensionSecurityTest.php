<?php
declare(strict_types=1);
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\Attributes\RunInSeparateProcess;
use PHPUnit\Framework\TestCase;

final class EmailSuspensionSecurityTest extends TestCase
{
    #[RunInSeparateProcess]
    public function test_unknown_permission_schema_is_not_treated_as_an_absent_column(): void
    {
        $pdo = new class extends PDO {
            public function __construct() {}
            public function prepare(string $query, array $options = []): PDOStatement|false
            {
                throw new RuntimeException('Synthetic metadata failure');
            }
        };
        $this->expectExceptionMessage('Synthetic metadata failure');
        users_email_reactivation_column_available($pdo);
    }

    public static function scenarios(): iterable
    {
        foreach (['admin', 'proof_before_admin', 'cleanup_then_admin', 'stale_timestamp', 'legacy', 'missing_deactivated', 'deleted'] as $case) {
            yield $case => [$case, 403];
        }
        foreach (['active', 'cleanup', 'admin_reactivate', 'missing_active', 'missing_cleanup'] as $case) {
            yield $case => [$case, 200];
        }
    }

    #[DataProvider('scenarios')]
    public function test_only_explicit_cleanup_permission_allows_reactivation(string $case, int $expected): void
    {
        $p = proc_open([PHP_BINARY, __DIR__ . '/../Fixtures/email_suspension.php', $case],
            [0 => ['pipe', 'r'], 1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes);
        self::assertIsResource($p);
        fclose($pipes[0]);
        $out = stream_get_contents($pipes[1]); $err = stream_get_contents($pipes[2]);
        fclose($pipes[1]); fclose($pipes[2]);
        self::assertSame(0, proc_close($p), $err . $out);
        self::assertSame('', $err);
        $r = json_decode($out, true, 512, JSON_THROW_ON_ERROR);
        self::assertSame($expected, $r['confirmation']['status']);
        self::assertSame($expected, $r['login_status']);
        self::assertTrue($r['other_unchanged']);
        self::assertFalse($r['open']);
        if ($r['admin'] !== null) { self::assertSame(200, $r['admin']['status']); }
        if ($expected === 403) {
            self::assertNotSame('active', $r['account_status']);
            self::assertSame(0, $r['mail_count']);
        } else {
            self::assertSame('active', $r['account_status']);
            self::assertContains($r['permission'], [0, null]);
        }
        if ($case === 'cleanup') { self::assertSame(1, $r['cleanup']['deactivated']); }
        if ($case === 'missing_cleanup') { self::assertFalse($r['cleanup']['table_ready']); }
    }
}
