<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

require_once __DIR__ . '/../../lib/helpers/helper_expense_math.php';

final class ExpenseMathPayloadTest extends TestCase
{
    public function test_split_value_conversion_modes(): void
    {
        $this->assertSame(12.34, expense_split_value_to_payload('exact', 1234));
        $this->assertSame(33.34, expense_split_value_to_payload('percent', 3334));
        $this->assertSame(3, expense_split_value_to_payload('shares', 3));
        $this->assertNull(expense_split_value_to_payload('equal', 0));
    }

    public function test_payload_rows_use_stored_owed_when_total_matches(): void
    {
        $rows = build_expense_participants_payload_rows(
            1000,
            'percent',
            [
                ['id' => 1, 'nickname' => 'A', 'owed_cents' => 600, 'split_value' => 6000],
                ['id' => 2, 'nickname' => 'B', 'owed_cents' => 400, 'split_value' => 4000],
            ]
        );

        $this->assertCount(2, $rows);
        $this->assertSame(6.0, $rows[0]['owed']);
        $this->assertSame(4.0, $rows[1]['owed']);
        $this->assertEquals(60.0, $rows[0]['split_value']);
        $this->assertEquals(40.0, $rows[1]['split_value']);
    }

    public function test_payload_rows_fallback_to_equal_split_when_stored_total_mismatch(): void
    {
        $rows = build_expense_participants_payload_rows(
            1000,
            'equal',
            [
                ['id' => 1, 'nickname' => 'A', 'owed_cents' => 0, 'split_value' => 0],
                ['id' => 2, 'nickname' => 'B', 'owed_cents' => 0, 'split_value' => 0],
                ['id' => 3, 'nickname' => 'C', 'owed_cents' => 0, 'split_value' => 0],
            ]
        );

        $this->assertCount(3, $rows);
        $this->assertSame(3.34, $rows[0]['owed']);
        $this->assertSame(3.33, $rows[1]['owed']);
        $this->assertSame(3.33, $rows[2]['owed']);
        $this->assertNull($rows[0]['split_value']);
        $this->assertNull($rows[1]['split_value']);
        $this->assertNull($rows[2]['split_value']);
    }
}
