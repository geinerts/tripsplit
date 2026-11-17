<?php
declare(strict_types=1);
use PHPUnit\Framework\TestCase;

final class ExpenseSubcategoryTest extends TestCase
{
    public function test_type_is_optional_validated_and_safe_before_the_migration(): void
    {
        $process = proc_open([PHP_BINARY, __DIR__.'/../Fixtures/expense_subcategory.php'],
            [0=>['pipe','r'],1=>['pipe','w'],2=>['pipe','w']], $pipes);
        self::assertIsResource($process);
        fclose($pipes[0]);
        $output = stream_get_contents($pipes[1]);
        $errors = stream_get_contents($pipes[2]);
        fclose($pipes[1]); fclose($pipes[2]);
        self::assertSame(0, proc_close($process), $errors);
        self::assertSame('', $errors);
        $r = json_decode($output, true, 512, JSON_THROW_ON_ERROR);
        // Before the migration reads give null and writes are skipped.
        self::assertFalse($r['before_available']);
        self::assertSame('NULL AS subcategory', $r['before_select']);
        self::assertNull($r['before_read']);
        self::assertSame([null, null, 'Rooftop bar', 'restaurant', str_repeat('ā', 40)], $r['valid']);
        self::assertSame([400, 400, 400, 400, 400], $r['invalid']);
        self::assertTrue($r['after_available']);
        self::assertSame('e.subcategory', $r['after_select']);
        self::assertSame('taxi', $r['after_read']);
        self::assertNull($r['cleared']);
    }
}
