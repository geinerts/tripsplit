<?php
declare(strict_types=1);

/**
 * @return int|float|null
 */
function expense_split_value_to_payload(string $splitMode, int $rawSplitValue)
{
    if ($splitMode === 'exact') {
        return cents_to_float($rawSplitValue);
    }
    if ($splitMode === 'percent') {
        return $rawSplitValue / 100;
    }
    if ($splitMode === 'shares') {
        return $rawSplitValue;
    }
    return null;
}

/**
 * @param array<int, array{id:int, nickname:string, owed_cents:int, split_value:int}> $participantRows
 * @return array<int, array{id:int, nickname:string, owed:float, split_value:int|float|null}>
 */
function build_expense_participants_payload_rows(
    int $amountCents,
    string $splitMode,
    array $participantRows
): array {
    $storedOwedTotal = 0;
    foreach ($participantRows as $participantRow) {
        $storedOwedTotal += (int) ($participantRow['owed_cents'] ?? 0);
    }
    $hasStoredOwed = count($participantRows) > 0 && $storedOwedTotal === $amountCents;

    $count = count($participantRows);
    $base = $count > 0 ? intdiv($amountCents, $count) : 0;
    $remainder = $count > 0 ? ($amountCents % $count) : 0;

    $participants = [];
    foreach ($participantRows as $index => $participantRow) {
        $storedOwedCents = (int) ($participantRow['owed_cents'] ?? 0);
        $owedCents = $hasStoredOwed
            ? $storedOwedCents
            : ($base + ($index < $remainder ? 1 : 0));

        $rawSplitValue = (int) ($participantRow['split_value'] ?? 0);
        $participants[] = [
            'id' => (int) ($participantRow['id'] ?? 0),
            'nickname' => (string) ($participantRow['nickname'] ?? ''),
            'owed' => cents_to_float($owedCents),
            'split_value' => expense_split_value_to_payload($splitMode, $rawSplitValue),
        ];
    }

    return $participants;
}
