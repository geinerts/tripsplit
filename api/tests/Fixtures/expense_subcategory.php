<?php
declare(strict_types=1);
// Isolated SQLite harness; no live config or network.
require __DIR__ . '/trip_invitations.php';
$pdo = invitation_test_setup(false);
$r = [];
$status = static function (mixed $value): int {
    try { normalize_expense_subcategory($value); } catch (InvitationResponse $response) { return $response->status; }
    return 200;
};
$pdo->exec('INSERT INTO trip_expenses (trip_id, paid_by) VALUES (1, 1)');
$r['before_available'] = expenses_subcategory_column_available($pdo);
$r['before_select'] = expense_subcategory_select($pdo);
save_expense_subcategory($pdo, 1, 'taxi');
$r['before_read'] = $pdo->query('SELECT ' . expense_subcategory_select($pdo, '') . ' FROM trip_expenses WHERE id = 1')->fetchColumn();
$r['valid'] = [
    normalize_expense_subcategory(null),
    normalize_expense_subcategory(''),
    normalize_expense_subcategory("  Rooftop   bar \n"),
    normalize_expense_subcategory('restaurant'),
    normalize_expense_subcategory(str_repeat('ā', 40)),
];
$r['invalid'] = [$status(str_repeat('a', 41)), $status(12), $status(['taxi']), $status(true), $status('see https://x.example')];
$pdo->exec(file_get_contents(__DIR__ . '/../../../sql/migrations/2026-11-17-add-expense-subcategory.sql'));
$r['after_available'] = expenses_subcategory_column_available($pdo);
$r['after_select'] = expense_subcategory_select($pdo);
save_expense_subcategory($pdo, 1, 'taxi');
$r['after_read'] = $pdo->query('SELECT ' . expense_subcategory_select($pdo, '') . ' FROM trip_expenses WHERE id = 1')->fetchColumn();
save_expense_subcategory($pdo, 1, null);
$r['cleared'] = $pdo->query('SELECT subcategory FROM trip_expenses WHERE id = 1')->fetchColumn();
echo json_encode($r, JSON_THROW_ON_ERROR | JSON_UNESCAPED_UNICODE);
