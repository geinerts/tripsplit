<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

/**
 * Tests for the pure settlement algorithm — no DB, no HTTP.
 *
 * Scenarios covered:
 *  - 2 people, one paid everything
 *  - 3 people, chain of debts collapses to minimal transactions
 *  - Already balanced (no settlements needed)
 *  - Odd-cent split distributes remainder correctly
 *  - Greedy algorithm minimises number of transactions
 */
class SettlementAlgorithmTest extends TestCase
{
    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------

    private function makeStats(array $users): array
    {
        $stats = [];
        foreach ($users as $u) {
            $stats[$u['id']] = [
                'id'         => $u['id'],
                'nickname'   => $u['nickname'],
                'paid_cents' => 0,
                'owed_cents' => 0,
            ];
        }
        return $stats;
    }

    // -------------------------------------------------------------------------
    // compute_balance_from_data tests
    // -------------------------------------------------------------------------

    public function test_two_people_one_paid_everything(): void
    {
        // Alice paid 100€, Bob paid 0, split equally → Bob owes Alice 50€
        $stats = $this->makeStats([
            ['id' => 1, 'nickname' => 'Alice'],
            ['id' => 2, 'nickname' => 'Bob'],
        ]);

        $expenses = [
            ['id' => 1, 'amount' => '100.00', 'paid_by' => 1],
        ];
        $participants = [
            1 => [
                ['user_id' => 1, 'owed_cents' => 5000],
                ['user_id' => 2, 'owed_cents' => 5000],
            ],
        ];

        $result = compute_balance_from_data($stats, $expenses, $participants);

        $settlements = $result['recommended_settlements'];
        $this->assertCount(1, $settlements);
        $this->assertSame(2, $settlements[0]['from_user_id']);
        $this->assertSame(1, $settlements[0]['to_user_id']);
        $this->assertSame(5000, $settlements[0]['amount_cents']);
        $this->assertSame(50.0, $settlements[0]['amount']);
    }

    public function test_already_balanced_no_settlements(): void
    {
        // Alice paid 50€, Bob paid 50€, each owes 50€ → no settlements
        $stats = $this->makeStats([
            ['id' => 1, 'nickname' => 'Alice'],
            ['id' => 2, 'nickname' => 'Bob'],
        ]);

        $expenses = [
            ['id' => 1, 'amount' => '50.00', 'paid_by' => 1],
            ['id' => 2, 'amount' => '50.00', 'paid_by' => 2],
        ];
        $participants = [
            1 => [['user_id' => 1, 'owed_cents' => 5000]],
            2 => [['user_id' => 2, 'owed_cents' => 5000]],
        ];

        $result = compute_balance_from_data($stats, $expenses, $participants);
        $this->assertCount(0, $result['recommended_settlements']);
    }

    public function test_three_people_greedy_minimises_transactions(): void
    {
        // Alice paid 90€ for all 3 (30€ each)
        // Bob paid 0, owes 30€
        // Charlie paid 0, owes 30€
        // Expected: 2 transactions (Bob→Alice 30€, Charlie→Alice 30€)
        $stats = $this->makeStats([
            ['id' => 1, 'nickname' => 'Alice'],
            ['id' => 2, 'nickname' => 'Bob'],
            ['id' => 3, 'nickname' => 'Charlie'],
        ]);

        $expenses = [
            ['id' => 1, 'amount' => '90.00', 'paid_by' => 1],
        ];
        $participants = [
            1 => [
                ['user_id' => 1, 'owed_cents' => 3000],
                ['user_id' => 2, 'owed_cents' => 3000],
                ['user_id' => 3, 'owed_cents' => 3000],
            ],
        ];

        $result = compute_balance_from_data($stats, $expenses, $participants);
        $settlements = $result['recommended_settlements'];

        $this->assertCount(2, $settlements);
        $this->assertSame(3000, $settlements[0]['amount_cents']);
        $this->assertSame(3000, $settlements[1]['amount_cents']);
    }

    public function test_odd_cent_split_distributes_remainder(): void
    {
        // 10€ split 3 ways: 3.34 + 3.33 + 3.33 = 10.00
        // (stored owed_cents don't sum to amount_cents → even-split path)
        $stats = $this->makeStats([
            ['id' => 1, 'nickname' => 'Alice'],
            ['id' => 2, 'nickname' => 'Bob'],
            ['id' => 3, 'nickname' => 'Charlie'],
        ]);

        $expenses = [
            ['id' => 1, 'amount' => '10.00', 'paid_by' => 1],
        ];
        // stored owed_cents: 0 → triggers even-split fallback
        $participants = [
            1 => [
                ['user_id' => 1, 'owed_cents' => 0],
                ['user_id' => 2, 'owed_cents' => 0],
                ['user_id' => 3, 'owed_cents' => 0],
            ],
        ];

        $result = compute_balance_from_data($stats, $expenses, $participants);
        $stats   = $result['stats'];

        // Total owed must equal total paid (1000 cents)
        $totalOwed = array_sum(array_column($stats, 'owed_cents'));
        $this->assertSame(1000, $totalOwed);
    }

    public function test_balances_net_sums_to_zero(): void
    {
        // Net balances across all users must always sum to zero
        $stats = $this->makeStats([
            ['id' => 1, 'nickname' => 'Alice'],
            ['id' => 2, 'nickname' => 'Bob'],
            ['id' => 3, 'nickname' => 'Charlie'],
        ]);

        $expenses = [
            ['id' => 1, 'amount' => '60.00', 'paid_by' => 1],
            ['id' => 2, 'amount' => '30.00', 'paid_by' => 2],
        ];
        $participants = [
            1 => [
                ['user_id' => 1, 'owed_cents' => 2000],
                ['user_id' => 2, 'owed_cents' => 2000],
                ['user_id' => 3, 'owed_cents' => 2000],
            ],
            2 => [
                ['user_id' => 1, 'owed_cents' => 1000],
                ['user_id' => 2, 'owed_cents' => 1000],
                ['user_id' => 3, 'owed_cents' => 1000],
            ],
        ];

        $result   = compute_balance_from_data($stats, $expenses, $participants);
        $netTotal = array_sum(array_column($result['balances'], 'net'));
        $this->assertEqualsWithDelta(0.0, $netTotal, 0.001);
    }

    // -------------------------------------------------------------------------
    // calculate_greedy_settlements tests
    // -------------------------------------------------------------------------

    public function test_greedy_single_debt(): void
    {
        $creditors = [['id' => 1, 'amount_cents' => 5000]];
        $debtors   = [['id' => 2, 'amount_cents' => 5000]];
        $stats     = [
            1 => ['nickname' => 'Alice'],
            2 => ['nickname' => 'Bob'],
        ];

        $result = calculate_greedy_settlements($creditors, $debtors, $stats);
        $this->assertCount(1, $result);
        $this->assertSame(5000, $result[0]['amount_cents']);
    }

    public function test_greedy_chain_collapses(): void
    {
        // Bob owes 100€, Alice is owed 60€, Charlie is owed 40€
        // → Bob pays Alice 60€, Bob pays Charlie 40€ (2 transactions)
        $creditors = [
            ['id' => 1, 'amount_cents' => 6000],
            ['id' => 3, 'amount_cents' => 4000],
        ];
        $debtors = [['id' => 2, 'amount_cents' => 10000]];
        $stats   = [
            1 => ['nickname' => 'Alice'],
            2 => ['nickname' => 'Bob'],
            3 => ['nickname' => 'Charlie'],
        ];

        $result = calculate_greedy_settlements($creditors, $debtors, $stats);
        $this->assertCount(2, $result);

        $totalPaid = array_sum(array_column($result, 'amount_cents'));
        $this->assertSame(10000, $totalPaid);
    }

    public function test_greedy_empty_returns_empty(): void
    {
        $result = calculate_greedy_settlements([], [], []);
        $this->assertSame([], $result);
    }
}
