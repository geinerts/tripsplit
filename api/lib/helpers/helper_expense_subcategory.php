<?php
declare(strict_types=1);

/** True once `trip_expenses.subcategory` exists. Only a found column is cached. */
function expenses_subcategory_column_available(PDO $pdo): bool
{
    static $found = [];
    $key = spl_object_id($pdo);
    if (isset($found[$key])) {
        return true;
    }
    try {
        $pdo->query('SELECT subcategory FROM ' . table_name('expenses') . ' LIMIT 0');
    } catch (Throwable $error) {
        return false;
    }
    $found[$key] = true;
    return true;
}

/** Null when there is no type; 400 for anything that isn't a short text. */
function normalize_expense_subcategory(mixed $value): ?string
{
    if ($value === null) {
        return null;
    }
    if (!is_string($value)) {
        json_out(['ok' => false, 'error' => 'Invalid expense type.'], 400);
    }
    $clean = trim(preg_replace('/\s+/u', ' ', $value) ?? $value);
    if ($clean === '') {
        return null;
    }
    if (str_length($clean) > 40) {
        json_out(['ok' => false, 'error' => 'Expense type is too long.'], 400);
    }
    ensure_text_has_no_links($clean, 'Expense type');
    return $clean;
}

/** Stores the type after the expense row was written; skipped before the migration. */
function save_expense_subcategory(PDO $pdo, int $expenseId, ?string $subcategory): void
{
    if (!expenses_subcategory_column_available($pdo)) {
        return;
    }
    $stmt = $pdo->prepare(
        'UPDATE ' . table_name('expenses') . ' SET subcategory = :subcategory WHERE id = :id'
    );
    $stmt->execute(['subcategory' => $subcategory, 'id' => $expenseId]);
}

/** SQL fragment for expense reads: the column, or NULL before the migration. */
function expense_subcategory_select(PDO $pdo, string $alias = 'e'): string
{
    if (!expenses_subcategory_column_available($pdo)) {
        return 'NULL AS subcategory';
    }
    return $alias === '' ? 'subcategory' : $alias . '.subcategory';
}
