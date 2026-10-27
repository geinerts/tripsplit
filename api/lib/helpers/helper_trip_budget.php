<?php
declare(strict_types=1);

function trips_budget_column_available(PDO $pdo): bool
{
    $stmt = $pdo->prepare('SELECT COUNT(*) FROM information_schema.columns
        WHERE table_schema = DATABASE() AND table_name = :table_name AND column_name = "budget_cents"');
    $stmt->execute(['table_name' => trim(table_name('trips'), '`')]);
    return (int) $stmt->fetchColumn() > 0;
}

function validate_trip_budget_cents(mixed $value): ?int
{
    if ($value === null) return null;
    if (!is_int($value) || $value < 1 || $value > 99999999999) {
        json_out(['ok' => false, 'error' => 'Budget must be a positive integer number of cents, up to 99999999999.'], 400);
    }
    return $value;
}

function require_trip_budget_schema(PDO $pdo): void
{
    if (!trips_budget_column_available($pdo)) {
        json_out(['ok' => false, 'error' => 'Trip budgets require a server update.'], 409);
    }
}
