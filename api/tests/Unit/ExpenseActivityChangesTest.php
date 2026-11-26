<?php
declare(strict_types=1);
use PHPUnit\Framework\TestCase;

require_once __DIR__ . '/../../lib/helpers/helper_expense_activity.php';

final class ExpenseActivityChangesTest extends TestCase
{
    private const BEFORE = [
        'amount_cents' => 2500,
        'source_amount_cents' => 2500,
        'currency_code' => 'EUR',
        'paid_by' => 1,
        'category' => 'food',
        'subcategory' => '',
        'note' => 'Dinner',
        'expense_date' => '2026-11-20',
        'split_mode' => 'equal',
        'is_personal' => 0,
        'receipt_path' => '',
    ];

    public function test_a_save_without_changes_names_nothing(): void
    {
        $people = [1 => 1250, 2 => 1250];
        self::assertSame([], expense_activity_changes(self::BEFORE, self::BEFORE + ['expense_date' => '2026-11-20 00:00:00'], $people, [2 => 1250, 1 => 1250]));
        // A stored date with a time still matches the same day.
        self::assertSame([], expense_activity_changes(['expense_date' => '2026-11-20 00:00:00'] + self::BEFORE, self::BEFORE, $people, $people));
    }

    public function test_each_change_is_named_once_in_a_fixed_order(): void
    {
        $people = [1 => 1250, 2 => 1250];
        $after = [
            'amount_cents' => 3000,
            'paid_by' => 2,
            'subcategory' => 'restaurant',
            'note' => 'Late dinner',
            'expense_date' => '2026-11-21',
            'receipt_path' => 'r/1.jpg',
        ] + self::BEFORE;
        self::assertSame(
            ['amount', 'payer', 'category', 'note', 'date', 'split', 'receipt'],
            expense_activity_changes(self::BEFORE, $after, $people, [1 => 1500, 2 => 1500])
        );
    }

    public function test_currency_counts_as_amount_and_people_as_split(): void
    {
        $people = [1 => 1250, 2 => 1250];
        self::assertSame(['amount'], expense_activity_changes(self::BEFORE, ['currency_code' => 'USD'] + self::BEFORE, $people, $people));
        self::assertSame(['split'], expense_activity_changes(self::BEFORE, self::BEFORE, $people, [1 => 2500]));
        self::assertSame(['split'], expense_activity_changes(self::BEFORE, ['is_personal' => 1] + self::BEFORE, $people, $people));
    }
}
