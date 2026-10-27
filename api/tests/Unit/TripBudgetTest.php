<?php
declare(strict_types=1);
use PHPUnit\Framework\TestCase;

final class TripBudgetTest extends TestCase
{
    public function test_optional_budgets_persist_with_permissions_and_backward_compatibility(): void
    {
        $process = proc_open([PHP_BINARY, __DIR__.'/../Fixtures/trip_budget.php'],
            [0=>['pipe','r'],1=>['pipe','w'],2=>['pipe','w']], $pipes);
        self::assertIsResource($process);
        fclose($pipes[0]);
        $output = stream_get_contents($pipes[1]);
        $errors = stream_get_contents($pipes[2]);
        fclose($pipes[1]); fclose($pipes[2]);
        self::assertSame(0, proc_close($process), $errors);
        self::assertSame('', $errors);
        $r = json_decode($output, true, 512, JSON_THROW_ON_ERROR);
        self::assertSame(409, $r['unmigrated_create']['status']);
        self::assertSame(0, $r['unmigrated_rows']);
        self::assertSame(200, $r['unmigrated_plain']['status']);
        self::assertNull($r['unmigrated_plain']['body']['trip']['budget_cents']);
        self::assertSame(409, $r['unmigrated_update']['status']);
        foreach (['solo','group'] as $mode) {
            foreach (['create','rename','edit','clear','restore'] as $action) {
                self::assertSame(200, $r[$mode.'_'.$action]['status'], $mode.' '.$action);
            }
            self::assertSame(125050, $r[$mode.'_stored']);
            self::assertSame(125050, $r[$mode.'_rename']['body']['trip']['budget_cents']);
            self::assertSame(99999999999, $r[$mode.'_edit']['body']['trip']['budget_cents']);
            self::assertNull($r[$mode.'_clear']['body']['trip']['budget_cents']);
            self::assertSame(1, $r[$mode.'_restore']['body']['trip']['budget_cents']);
        }
        self::assertSame(403, $r['outsider']['status']);
        self::assertSame(403, $r['member']['status']);
        self::assertSame(200, $r['admin']['status']);
        self::assertSame(30000, $r['member_read']['budget_cents']);
        self::assertSame(400, $r['currency_implicit']['status']);
        self::assertSame(42000, $r['currency_explicit']['body']['trip']['budget_cents']);
        foreach ($r['invalid'] as $statuses) self::assertSame([400,400], $statuses);
        self::assertTrue($r['invalid_no_writes']);
    }
}
