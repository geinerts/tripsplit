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

    public function test_new_modes_report_their_values_in_money(): void
    {
        $this->assertSame(-5.5, expense_split_value_to_payload('adjustment', -550));
        $this->assertSame(10.0, expense_split_value_to_payload('adjustment', 1000));
        $this->assertSame(12.34, expense_split_value_to_payload('itemized', 1234));
    }

    public function test_adjustment_shares_what_remains_equally(): void
    {
        $this->assertSame(
            [1 => 4000, 2 => 3000, 3 => 3000],
            expense_adjustment_owed_cents(10000, [1, 2, 3], [1 => 1000, 2 => 0, 3 => 0])
        );
        // Leftover cents go to the first people, and the total stays exact.
        $owed = expense_adjustment_owed_cents(1000, [1, 2, 3], [1 => 0, 2 => 0, 3 => 0]);
        $this->assertSame([1 => 334, 2 => 333, 3 => 333], $owed);
        // A discount moves cost to the others.
        $this->assertSame(
            [1 => 2500, 2 => 3500, 3 => 4000],
            expense_adjustment_owed_cents(10000, [1, 2, 3], [1 => -1000, 2 => 0, 3 => 500])
        );
    }

    public function test_adjustments_that_do_not_fit_are_refused(): void
    {
        $this->assertNull(expense_adjustment_owed_cents(1000, [1, 2], [1 => 1500, 2 => 0]));
        $this->assertNull(expense_adjustment_owed_cents(1000, [1, 2], [1 => -2000, 2 => 0]));
        $this->assertNull(expense_adjustment_owed_cents(1000, [], []));
    }

    public function test_itemized_shares_items_and_extra_in_proportion(): void
    {
        $items = [
            ['amount_cents' => 1200, 'participant_ids' => [1, 2]],
            ['amount_cents' => 500, 'participant_ids' => [2]],
        ];
        $this->assertSame([1 => 600, 2 => 1100], expense_itemized_owed_cents($items, 0));
        $owed = expense_itemized_owed_cents($items, 300);
        $this->assertSame(2000, array_sum($owed));
        $this->assertSame([1 => 706, 2 => 1294], $owed);
    }

    public function test_itemized_totals_stay_exact_with_awkward_numbers(): void
    {
        foreach ([1, 7, 100, 333, 9999] as $extra) {
            $owed = expense_itemized_owed_cents([
                ['amount_cents' => 1001, 'participant_ids' => [1, 2, 3]],
                ['amount_cents' => 7, 'participant_ids' => [3, 4]],
            ], $extra);
            $this->assertSame(1008 + $extra, array_sum($owed));
        }
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
