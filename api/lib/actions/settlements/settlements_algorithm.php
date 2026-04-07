<?php
declare(strict_types=1);

/**
 * Pure settlement algorithm functions — no DB, no HTTP, fully testable.
 */

/**
 * Greedy debt-simplification algorithm.
 *
 * @param  array<array{id:int, amount_cents:int}> $creditors  People owed money (positive net), sorted DESC.
 * @param  array<array{id:int, amount_cents:int}> $debtors    People who owe money (negative net), sorted DESC.
 * @param  array<int, array{nickname:string}>     $statsById  User stats keyed by user id (used for nicknames).
 * @return array<array{from_user_id:int, to_user_id:int, from:string, to:string, amount_cents:int, amount:float}>
 */
function calculate_greedy_settlements(array $creditors, array $debtors, array $statsById): array
{
    usort($creditors, static fn(array $a, array $b): int => $b['amount_cents'] <=> $a['amount_cents']);
    usort($debtors,   static fn(array $a, array $b): int => $b['amount_cents'] <=> $a['amount_cents']);

    $recommended = [];
    $i = 0;
    $j = 0;

    while ($i < count($debtors) && $j < count($creditors)) {
        $debt   = $debtors[$i];
        $credit = $creditors[$j];
        $payCents = min($debt['amount_cents'], $credit['amount_cents']);

        $fromUserId = (int) $debt['id'];
        $toUserId   = (int) $credit['id'];

        $recommended[] = [
            'from_user_id' => $fromUserId,
            'to_user_id'   => $toUserId,
            'from'         => $statsById[$fromUserId]['nickname'] ?? '',
            'to'           => $statsById[$toUserId]['nickname'] ?? '',
            'amount_cents' => $payCents,
            'amount'       => cents_to_float($payCents),
        ];

        $debtors[$i]['amount_cents']   -= $payCents;
        $creditors[$j]['amount_cents'] -= $payCents;

        if ($debtors[$i]['amount_cents'] === 0) {
            $i++;
        }
        if ($creditors[$j]['amount_cents'] === 0) {
            $j++;
        }
    }

    return $recommended;
}

/**
 * Compute per-user balances from raw expense data (no DB needed).
 *
 * @param  array<int, array{id:int, nickname:string, paid_cents:int, owed_cents:int}> $stats
 * @param  array<array{id:int, amount:string|float, paid_by:int}>                    $expenses
 * @param  array<int, array<array{user_id:int, owed_cents:int}>>                     $participantsByExpense
 * @return array{stats:array, balances:array, recommended_settlements:array}
 */
function compute_balance_from_data(array $stats, array $expenses, array $participantsByExpense): array
{
    foreach ($expenses as $expense) {
        $expenseId   = (int) $expense['id'];
        $paidBy      = (int) $expense['paid_by'];
        $amountCents = decimal_to_cents($expense['amount']);

        if (isset($stats[$paidBy])) {
            $stats[$paidBy]['paid_cents'] += $amountCents;
        }

        $participants = $participantsByExpense[$expenseId] ?? [];
        $count = count($participants);
        if ($count < 1) {
            continue;
        }

        $storedOwedTotal = 0;
        foreach ($participants as $p) {
            $storedOwedTotal += (int) ($p['owed_cents'] ?? 0);
        }
        $useStoredOwed = ($storedOwedTotal === $amountCents);

        if ($useStoredOwed) {
            foreach ($participants as $p) {
                $uid = (int) $p['user_id'];
                if (isset($stats[$uid])) {
                    $stats[$uid]['owed_cents'] += (int) $p['owed_cents'];
                }
            }
            continue;
        }

        // Even split with penny distribution
        $base      = intdiv($amountCents, $count);
        $remainder = $amountCents % $count;
        foreach ($participants as $index => $p) {
            $uid = (int) $p['user_id'];
            if (!isset($stats[$uid])) {
                continue;
            }
            $stats[$uid]['owed_cents'] += $base + ($index < $remainder ? 1 : 0);
        }
    }

    $creditors = [];
    $debtors   = [];
    $balances  = [];

    foreach ($stats as $stat) {
        $net = $stat['paid_cents'] - $stat['owed_cents'];
        if ($net > 0) {
            $creditors[] = ['id' => $stat['id'], 'amount_cents' => $net];
        } elseif ($net < 0) {
            $debtors[] = ['id' => $stat['id'], 'amount_cents' => -$net];
        }
        $balances[] = [
            'id'       => $stat['id'],
            'nickname' => $stat['nickname'],
            'paid'     => cents_to_float($stat['paid_cents']),
            'owed'     => cents_to_float($stat['owed_cents']),
            'net'      => cents_to_float($net),
        ];
    }

    $recommended = calculate_greedy_settlements($creditors, $debtors, $stats);

    return [
        'stats'                   => $stats,
        'balances'                => $balances,
        'recommended_settlements' => $recommended,
    ];
}
