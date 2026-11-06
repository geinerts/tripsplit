<?php
declare(strict_types=1);

/**
 * @return int|float|null
 */
function expense_split_value_to_payload(string $splitMode, int $rawSplitValue)
{
    if ($splitMode === 'exact' || $splitMode === 'adjustment' || $splitMode === 'itemized') {
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
 * Everyone pays an equal part of what remains, plus their adjustment.
 *
 * @param array<int, int> $participantIds
 * @param array<int, int> $adjustmentsByUser cents, may be negative
 * @return array<int, int>|null owed cents by user, or null when the adjustments don't fit
 */
function expense_adjustment_owed_cents(int $amountCents, array $participantIds, array $adjustmentsByUser): ?array
{
    $count = count($participantIds);
    if ($count < 1) {
        return null;
    }
    $rest = $amountCents;
    foreach ($participantIds as $userId) {
        $rest -= (int) ($adjustmentsByUser[$userId] ?? 0);
    }
    if ($rest < 0) {
        return null;
    }
    $base = intdiv($rest, $count);
    $remainder = $rest % $count;
    $owed = [];
    foreach (array_values($participantIds) as $index => $userId) {
        $cents = $base + ($index < $remainder ? 1 : 0) + (int) ($adjustmentsByUser[$userId] ?? 0);
        if ($cents < 0) {
            return null;
        }
        $owed[$userId] = $cents;
    }
    return $owed;
}

/**
 * Each item is shared equally among its people, and the extra in proportion to their items.
 *
 * @param array<int, array{amount_cents:int, participant_ids:array<int, int>}> $items
 * @return array<int, int> owed cents by user
 */
function expense_itemized_owed_cents(array $items, int $extraCents): array
{
    $owed = [];
    foreach ($items as $item) {
        $ids = array_values($item['participant_ids']);
        $count = count($ids);
        $base = intdiv((int) $item['amount_cents'], $count);
        $remainder = (int) $item['amount_cents'] % $count;
        foreach ($ids as $index => $userId) {
            $owed[$userId] = ($owed[$userId] ?? 0) + $base + ($index < $remainder ? 1 : 0);
        }
    }

    $itemsTotal = array_sum($owed);
    if ($extraCents <= 0 || $itemsTotal <= 0) {
        return $owed;
    }
    $left = $extraCents;
    $remainders = [];
    $weights = $owed;
    foreach ($weights as $userId => $weight) {
        $share = intdiv($extraCents * $weight, $itemsTotal);
        $owed[$userId] += $share;
        $left -= $share;
        $remainders[$userId] = ($extraCents * $weight) % $itemsTotal;
    }
    arsort($remainders);
    foreach (array_keys($remainders) as $userId) {
        if ($left <= 0) {
            break;
        }
        $owed[$userId]++;
        $left--;
    }
    return $owed;
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
