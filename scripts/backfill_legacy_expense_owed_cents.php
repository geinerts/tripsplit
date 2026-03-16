#!/usr/bin/env php
<?php
declare(strict_types=1);

if (PHP_SAPI !== 'cli') {
    fwrite(STDERR, "This script must be run from CLI.\n");
    exit(1);
}

require __DIR__ . '/../api/config.php';

main($argv);

function main(array $argv): void
{
    $options = parse_cli_options($argv);
    $dryRun = $options['dry_run'];
    $tripId = $options['trip_id'];

    $pdo = db();
    $expensesTable = table_name('expenses');
    $participantsTable = table_name('expense_participants');

    $mismatchSql = '
        SELECT
            e.id,
            e.trip_id,
            e.amount,
            e.split_mode,
            COALESCE(SUM(ep.owed_cents), 0) AS owed_sum_cents,
            COUNT(ep.user_id) AS participants_count
        FROM ' . $expensesTable . ' e
        LEFT JOIN ' . $participantsTable . ' ep ON ep.expense_id = e.id
    ';
    $params = [];
    if ($tripId !== null) {
        $mismatchSql .= ' WHERE e.trip_id = :trip_id ';
        $params['trip_id'] = $tripId;
    }
    $mismatchSql .= '
        GROUP BY e.id, e.trip_id, e.amount, e.split_mode
        HAVING owed_sum_cents <> CAST(ROUND(e.amount * 100) AS SIGNED)
        ORDER BY e.trip_id ASC, e.id ASC
    ';

    $mismatchStmt = $pdo->prepare($mismatchSql);
    $mismatchStmt->execute($params);
    $candidates = $mismatchStmt->fetchAll();

    if (!$candidates) {
        echo "No mismatched expenses found.\n";
        return;
    }

    $participantsStmt = $pdo->prepare(
        'SELECT user_id, owed_cents, split_value
         FROM ' . $participantsTable . '
         WHERE expense_id = :expense_id
         ORDER BY user_id ASC'
    );
    $updateStmt = $pdo->prepare(
        'UPDATE ' . $participantsTable . '
         SET owed_cents = :owed_cents
         WHERE expense_id = :expense_id
           AND user_id = :user_id'
    );

    $examined = 0;
    $fixed = 0;
    $skipped = 0;
    $updatedRows = 0;

    if (!$dryRun) {
        $pdo->beginTransaction();
    }

    try {
        foreach ($candidates as $row) {
            $examined++;
            $expenseId = (int) ($row['id'] ?? 0);
            $trip = (int) ($row['trip_id'] ?? 0);
            $amountCents = decimal_to_cents($row['amount'] ?? 0);
            $splitMode = normalize_split_mode((string) ($row['split_mode'] ?? 'equal'));

            $participantsStmt->execute(['expense_id' => $expenseId]);
            $participants = $participantsStmt->fetchAll();
            if (!$participants) {
                $skipped++;
                echo "SKIP expense_id={$expenseId} trip_id={$trip}: no participants\n";
                continue;
            }

            try {
                $recomputed = recompute_owed_cents($amountCents, $splitMode, $participants);
            } catch (RuntimeException $error) {
                $skipped++;
                echo "SKIP expense_id={$expenseId} trip_id={$trip}: {$error->getMessage()}\n";
                continue;
            }

            $sum = array_sum($recomputed);
            if ($sum !== $amountCents) {
                $skipped++;
                echo "SKIP expense_id={$expenseId} trip_id={$trip}: recomputed sum {$sum} != amount {$amountCents}\n";
                continue;
            }

            $changedRowsForExpense = 0;
            foreach ($participants as $participant) {
                $userId = (int) ($participant['user_id'] ?? 0);
                $currentOwed = (int) ($participant['owed_cents'] ?? 0);
                $nextOwed = (int) ($recomputed[$userId] ?? 0);
                if ($currentOwed === $nextOwed) {
                    continue;
                }
                $changedRowsForExpense++;
                if ($dryRun) {
                    continue;
                }
                $updateStmt->execute([
                    'owed_cents' => $nextOwed,
                    'expense_id' => $expenseId,
                    'user_id' => $userId,
                ]);
                $updatedRows += (int) $updateStmt->rowCount();
            }

            if ($changedRowsForExpense > 0) {
                $fixed++;
                echo ($dryRun ? 'DRY-RUN' : 'FIXED')
                    . " expense_id={$expenseId} trip_id={$trip} rows_changed={$changedRowsForExpense}\n";
            } else {
                echo "NOOP expense_id={$expenseId} trip_id={$trip}\n";
            }
        }

        if (!$dryRun && $pdo->inTransaction()) {
            $pdo->commit();
        }
    } catch (Throwable $error) {
        if (!$dryRun && $pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    echo "\nSummary\n";
    echo "  examined: {$examined}\n";
    echo "  fixed: {$fixed}\n";
    echo "  skipped: {$skipped}\n";
    if ($dryRun) {
        echo "  mode: dry-run\n";
    } else {
        echo "  updated_rows: {$updatedRows}\n";
    }
}

function parse_cli_options(array $argv): array
{
    $tripId = null;
    $dryRun = false;

    foreach ($argv as $index => $arg) {
        if ($index === 0) {
            continue;
        }
        if ($arg === '--dry-run') {
            $dryRun = true;
            continue;
        }
        if (strpos($arg, '--trip-id=') === 0) {
            $raw = trim(substr($arg, strlen('--trip-id=')));
            if ($raw === '' || !ctype_digit($raw) || (int) $raw <= 0) {
                throw new InvalidArgumentException('Invalid --trip-id value.');
            }
            $tripId = (int) $raw;
            continue;
        }
        if ($arg === '--help' || $arg === '-h') {
            echo "Usage: php scripts/backfill_legacy_expense_owed_cents.php [--dry-run] [--trip-id=ID]\n";
            exit(0);
        }
        throw new InvalidArgumentException('Unknown option: ' . $arg);
    }

    return [
        'trip_id' => $tripId,
        'dry_run' => $dryRun,
    ];
}

function normalize_split_mode(string $value): string
{
    $raw = strtolower(trim($value));
    if ($raw === '' || $raw === 'equal') {
        return 'equal';
    }
    if ($raw === 'exact' || $raw === 'percent' || $raw === 'shares') {
        return $raw;
    }
    return 'equal';
}

function recompute_owed_cents(int $amountCents, string $splitMode, array $participants): array
{
    if ($amountCents <= 0) {
        throw new RuntimeException('amount must be positive');
    }
    if (!$participants) {
        throw new RuntimeException('no participants');
    }

    $rows = [];
    foreach ($participants as $participant) {
        $userId = (int) ($participant['user_id'] ?? 0);
        if ($userId <= 0) {
            throw new RuntimeException('participant user_id missing');
        }
        $rows[] = [
            'user_id' => $userId,
            'split_value' => (int) ($participant['split_value'] ?? 0),
        ];
    }

    if ($splitMode === 'equal') {
        $count = count($rows);
        $base = intdiv($amountCents, $count);
        $remainder = $amountCents % $count;
        $owed = [];
        foreach ($rows as $index => $row) {
            $owed[(int) $row['user_id']] = $base + ($index < $remainder ? 1 : 0);
        }
        return $owed;
    }

    if ($splitMode === 'exact') {
        $owed = [];
        $sum = 0;
        foreach ($rows as $row) {
            $value = (int) $row['split_value'];
            if ($value < 0) {
                throw new RuntimeException('exact split has negative split_value');
            }
            $owed[(int) $row['user_id']] = $value;
            $sum += $value;
        }
        if ($sum !== $amountCents) {
            throw new RuntimeException('exact split_value sum does not match amount');
        }
        return $owed;
    }

    if ($splitMode === 'percent') {
        $weights = [];
        $sumBasisPoints = 0;
        foreach ($rows as $row) {
            $value = (int) $row['split_value'];
            if ($value < 0) {
                throw new RuntimeException('percent split has negative split_value');
            }
            $userId = (int) $row['user_id'];
            $weights[$userId] = $value;
            $sumBasisPoints += $value;
        }
        if ($sumBasisPoints !== 10000) {
            throw new RuntimeException('percent split_value total must be 10000');
        }
        return allocate_weighted_shares_cents($amountCents, $rows, $weights);
    }

    if ($splitMode === 'shares') {
        $weights = [];
        foreach ($rows as $row) {
            $value = (int) $row['split_value'];
            if ($value <= 0) {
                throw new RuntimeException('shares split_value must be positive');
            }
            $weights[(int) $row['user_id']] = $value;
        }
        return allocate_weighted_shares_cents($amountCents, $rows, $weights);
    }

    throw new RuntimeException('unsupported split mode');
}

function allocate_weighted_shares_cents(int $amountCents, array $rows, array $weightsByUser): array
{
    $totalWeight = 0;
    foreach ($rows as $row) {
        $userId = (int) ($row['user_id'] ?? 0);
        $weight = (int) ($weightsByUser[$userId] ?? 0);
        if ($weight > 0) {
            $totalWeight += $weight;
        }
    }

    if ($totalWeight <= 0) {
        throw new RuntimeException('split weights must be positive');
    }

    $owedByUser = [];
    $allocated = 0;
    $remainders = [];

    foreach ($rows as $index => $row) {
        $userId = (int) ($row['user_id'] ?? 0);
        $weight = (int) ($weightsByUser[$userId] ?? 0);
        if ($weight <= 0) {
            $owedByUser[$userId] = 0;
            $remainders[] = [
                'user_id' => $userId,
                'index' => (int) $index,
                'remainder' => 0,
            ];
            continue;
        }

        $weighted = $amountCents * $weight;
        $base = intdiv($weighted, $totalWeight);
        $remainder = $weighted % $totalWeight;
        $owedByUser[$userId] = $base;
        $allocated += $base;
        $remainders[] = [
            'user_id' => $userId,
            'index' => (int) $index,
            'remainder' => (int) $remainder,
        ];
    }

    usort(
        $remainders,
        static function (array $a, array $b): int {
            $cmp = ((int) $b['remainder']) <=> ((int) $a['remainder']);
            if ($cmp !== 0) {
                return $cmp;
            }
            return ((int) $a['index']) <=> ((int) $b['index']);
        }
    );

    $left = $amountCents - $allocated;
    $count = count($remainders);
    $cursor = 0;
    while ($left > 0 && $count > 0) {
        $row = $remainders[$cursor % $count];
        $userId = (int) $row['user_id'];
        $owedByUser[$userId] = (int) ($owedByUser[$userId] ?? 0) + 1;
        $left--;
        $cursor++;
    }

    return $owedByUser;
}
