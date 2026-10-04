<?php
declare(strict_types=1);
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

final class LifecycleSchemaContractTest extends TestCase
{
    public static function cases(): iterable
    {
        foreach (['deactivation', 'password_reset'] as $flow) {
            yield [$flow, 'available', '200'];
            yield [$flow, 'missing', '503'];
        }
    }

    #[DataProvider('cases')]
    public function test_schema_guards_use_real_quoted_table_mapping(string $flow, string $state, string $expected): void
    {
        $process = proc_open([PHP_BINARY, __DIR__ . '/../Fixtures/lifecycle_schema_contract.php', $flow, $state],
            [0 => ['pipe', 'r'], 1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes);
        self::assertIsResource($process);
        fclose($pipes[0]);
        $out = stream_get_contents($pipes[1]);
        $err = stream_get_contents($pipes[2]);
        fclose($pipes[1]); fclose($pipes[2]);
        self::assertSame(0, proc_close($process), $err);
        self::assertSame('', $err);
        self::assertSame($expected, $out);
    }
}
