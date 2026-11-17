<?php
declare(strict_types=1);
// Isolated SQLite harness for quick split handlers; no live config or network.
require __DIR__ . '/trip_invitations.php';
define('RATE_LIMIT_EXPENSE_WRITE_IP_MAX', 100);
define('RATE_LIMIT_EXPENSE_WRITE_USER_MAX', 100);
if (!function_exists('normalize_receipt_path')) {
    function normalize_receipt_path(string $path, bool $allowEmpty = true): string { return trim($path); }
}
if (!function_exists('receipt_public_url')) {
    function receipt_public_url(?string $path): ?string { return $path ? 'https://example.invalid/r/' . $path : null; }
}
if (!function_exists('receipt_thumb_public_url')) {
    function receipt_thumb_public_url(?string $path): ?string { return $path ? 'https://example.invalid/t/' . $path : null; }
}
if (!function_exists('delete_receipt_file')) {
    function delete_receipt_file(?string $path): void { $GLOBALS['deleted_receipts'][] = $path; }
}
if (!function_exists('avatar_thumb_public_url')) {
    function avatar_thumb_public_url(?string $path): ?string { return $path ? 'https://example.invalid/a/' . $path : null; }
}
if (!function_exists('format_cents_with_currency')) {
    function format_cents_with_currency(int $cents, string $code): string { return $code . ' ' . number_format($cents / 100, 2, '.', ''); }
}
if (!function_exists('auth_access_token_secret')) {
    function auth_access_token_secret(): string { return 'test-secret'; }
}
require __DIR__ . '/../../lib/helpers/helper_expense_math.php';
require __DIR__ . '/../../lib/actions/quick_splits_actions.php';
require __DIR__ . '/../../lib/helpers/push/push_localization.php';

$pdo = invitation_test_setup(false);
$GLOBALS['pdo'] = $pdo;
$r = [];
$call = static fn (string $handler, int $user, array $input = []): array => invitation_call($handler, $user, $input);

if (($argv[1] ?? '') === 'before') {
    // Before the migration the actions answer 409 and nothing else breaks.
    echo json_encode(['list' => $call('list_quick_splits_action', 1), 'add' => $call('add_quick_split_action', 1, [])]);
    exit;
}

$pdo->exec('CREATE TABLE trip_friends (id INTEGER PRIMARY KEY AUTOINCREMENT, user_a_id INT, user_b_id INT, requested_by INT, status VARCHAR(20))');
$pdo->exec('CREATE TABLE trip_quick_splits (id INTEGER PRIMARY KEY AUTOINCREMENT, created_by INT NOT NULL,
    amount_cents INT NOT NULL, currency_code CHAR(3) NOT NULL DEFAULT "EUR", category VARCHAR(64) NOT NULL DEFAULT "other",
    subcategory VARCHAR(40) NULL, note VARCHAR(255) NOT NULL DEFAULT "", split_mode VARCHAR(16) NOT NULL DEFAULT "equal",
    split_date DATE NOT NULL, receipt_path VARCHAR(255) NULL, client_mutation_id VARCHAR(96) NULL,
    moved_trip_id INT NULL, moved_expense_id INT NULL, moved_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (created_by, client_mutation_id))');
$pdo->exec('CREATE TABLE trip_quick_split_people (id INTEGER PRIMARY KEY AUTOINCREMENT, quick_split_id INT NOT NULL,
    position INT NOT NULL DEFAULT 0, user_id INT NULL, name VARCHAR(32) NOT NULL DEFAULT "", is_payer INT NOT NULL DEFAULT 0,
    owed_cents INT NOT NULL DEFAULT 0, split_value INT NOT NULL DEFAULT 0)');
$pdo->exec('CREATE TABLE trip_quick_split_items (id INTEGER PRIMARY KEY AUTOINCREMENT, quick_split_id INT NOT NULL,
    position INT NOT NULL DEFAULT 0, name VARCHAR(80) NOT NULL DEFAULT "", amount_cents INT NOT NULL, is_extra INT NOT NULL DEFAULT 0)');
$pdo->exec('CREATE TABLE trip_quick_split_item_people (item_id INT NOT NULL, person_id INT NOT NULL, PRIMARY KEY (item_id, person_id))');
// 1 Owner, 2 Invitee and 4 Friend are friends; 3 Other is not; 5 is a trip guest.
$pdo->exec('INSERT INTO trip_users(id,nickname,account_status,guest_trip_id) VALUES (4,"Friend","active",NULL),(5,"Guest","active",9)');
$pdo->exec('INSERT INTO trip_friends(user_a_id,user_b_id,requested_by,status) VALUES (1,2,1,"accepted"),(1,4,4,"accepted"),(1,5,1,"accepted"),(1,3,1,"pending")');

$people = [['key' => 'me', 'user_id' => 1], ['key' => 'inv', 'user_id' => 2], ['key' => 'a', 'name' => ' Andris ']];
$base = ['amount' => 90, 'currency_code' => 'EUR', 'note' => 'Dinner at Lido', 'category' => 'food',
    'subcategory' => 'Restaurant', 'date' => '2026-11-16', 'paid_by' => 'me', 'people' => $people, 'split_mode' => 'equal'];
$notes = static fn (): array => $pdo->query('SELECT user_id, trip_id, type, title, body, payload_json FROM trip_notifications ORDER BY id')->fetchAll();

$r['errors'] = [
    'one_person' => $call('add_quick_split_action', 1, ['people' => [['key' => 'me', 'user_id' => 1]]] + $base),
    'no_key' => $call('add_quick_split_action', 1, ['people' => [['user_id' => 1], ['name' => 'X']]] + $base),
    'dup_key' => $call('add_quick_split_action', 1, ['people' => [['key' => 'a', 'user_id' => 1], ['key' => 'a', 'name' => 'X']]] + $base),
    'not_me' => $call('add_quick_split_action', 1, ['people' => [['key' => 'a', 'user_id' => 2], ['key' => 'b', 'name' => 'X']]] + $base),
    'stranger' => $call('add_quick_split_action', 1, ['people' => [['key' => 'me', 'user_id' => 1], ['key' => 'o', 'user_id' => 3]]] + $base),
    'guest' => $call('add_quick_split_action', 1, ['people' => [['key' => 'me', 'user_id' => 1], ['key' => 'g', 'user_id' => 5]]] + $base),
    'unknown_payer' => $call('add_quick_split_action', 1, ['paid_by' => 'zzz'] + $base),
    'link_name' => $call('add_quick_split_action', 1, ['people' => [['key' => 'me', 'user_id' => 1], ['key' => 'x', 'name' => 'https://x.example']]] + $base),
    'exact_sum' => $call('add_quick_split_action', 1, ['split_mode' => 'exact', 'splits' => [['person' => 'me', 'value' => 10], ['person' => 'inv', 'value' => 10], ['person' => 'a', 'value' => 10]]] + $base),
];
$r['nothing_saved'] = (int) $pdo->query('SELECT COUNT(*) FROM trip_quick_splits')->fetchColumn();

$created = $call('add_quick_split_action', 1, ['client_mutation_id' => 'm-1'] + $base);
$r['created'] = $created;
$r['replay'] = $call('add_quick_split_action', 1, ['client_mutation_id' => 'm-1'] + $base)['body']['quick_split']['id'] ?? null;
$r['count_after_replay'] = (int) $pdo->query('SELECT COUNT(*) FROM trip_quick_splits')->fetchColumn();
$r['notes_after_create'] = $notes();
$firstId = (int) $created['body']['quick_split']['id'];

$r['invitee_get'] = $call('get_quick_split_action', 2, ['id' => $firstId]);
$r['other_get'] = $call('get_quick_split_action', 3, ['id' => $firstId])['status'];
$r['invitee_update'] = $call('update_quick_split_action', 2, ['id' => $firstId] + $base)['status'];
$r['invitee_delete'] = $call('delete_quick_split_action', 2, ['id' => $firstId])['status'];
$r['invitee_move'] = $call('move_quick_split_to_trip_action', 2, ['id' => $firstId, 'trip_id' => 1, 'expense_id' => 1])['status'];

// Itemized, older date, paid by the name-only person.
$itemized = ['amount' => 20, 'date' => '2026-11-10', 'note' => '', 'split_mode' => 'itemized', 'paid_by' => 'a',
    'items' => [['name' => 'Pizza', 'amount' => 12, 'people' => ['me', 'inv']], ['name' => 'Beer', 'amount' => 5, 'people' => ['inv']]],
    'extra_amount' => 3] + $base;
$second = $call('add_quick_split_action', 1, $itemized);
$r['itemized'] = $second['body']['quick_split'] ?? $second;
$secondId = (int) ($second['body']['quick_split']['id'] ?? 0);
$r['bad_item_person'] = $call('add_quick_split_action', 1, ['items' => [['name' => 'X', 'amount' => 20, 'people' => ['nobody']]]] + $itemized)['body'];
$r['notes_after_itemized'] = count($notes());

// Third one, newest date, without the invitee.
$third = $call('add_quick_split_action', 1, ['date' => '2026-11-17', 'people' => [['key' => 'me', 'user_id' => 1], ['key' => 'f', 'user_id' => 4]]] + $base);
$thirdId = (int) $third['body']['quick_split']['id'];

$r['owner_list'] = array_map(static fn (array $i): int => $i['id'], $call('list_quick_splits_action', 1)['body']['items']);
$r['invitee_list'] = $call('list_quick_splits_action', 2)['body']['items'];
$r['other_list'] = $call('list_quick_splits_action', 3)['body']['items'];
$page1 = $call('list_quick_splits_action', 1, ['limit' => 2])['body'];
$page2 = $call('list_quick_splits_action', 1, ['limit' => 2, 'cursor' => $page1['next_cursor']])['body'];
$r['pages'] = [array_column($page1['items'], 'id'), $page1['has_more'], array_column($page2['items'], 'id'), $page2['has_more']];

// Update: keep the invitee, add Friend. Only Friend is told.
$before = count($notes());
$updated = $call('update_quick_split_action', 1, ['id' => $firstId, 'amount' => 100,
    'people' => array_merge($people, [['key' => 'f', 'user_id' => 4]]), 'split_mode' => 'shares',
    'splits' => [['person' => 'me', 'value' => 1], ['person' => 'inv', 'value' => 1], ['person' => 'a', 'value' => 1], ['person' => 'f', 'value' => 2]]] + $base);
$r['updated'] = array_map(static fn (array $p): array => [$p['name'], $p['amount'], $p['split_value']], $updated['body']['quick_split']['people']);
$r['update_notes'] = array_map(static fn (array $n): int => (int) $n['user_id'], array_slice($notes(), $before));

// Receipts: must be uploaded by the caller; replacing one deletes the old file.
$owned = receipt_owned_upload_path('receipts/r1.webp', 1);
$r['foreign_receipt'] = $call('update_quick_split_action', 1, ['id' => $thirdId, 'receipt_path' => receipt_owned_upload_path('receipts/r1.webp', 2), 'people' => [['key' => 'me', 'user_id' => 1], ['key' => 'f', 'user_id' => 4]]] + $base)['status'];
$withReceipt = $call('update_quick_split_action', 1, ['id' => $thirdId, 'date' => '2026-11-17', 'receipt_path' => $owned, 'people' => [['key' => 'me', 'user_id' => 1], ['key' => 'f', 'user_id' => 4]]] + $base);
$r['receipt'] = [$withReceipt['body']['quick_split']['receipt_url'] !== null, $withReceipt['body']['quick_split']['has_receipt'], $withReceipt['body']['quick_split']['receipt_path'] === $owned];
$r['friend_sees_receipt_path'] = $call('get_quick_split_action', 4, ['id' => $thirdId])['body']['quick_split']['receipt_path'];
$r['delete_third'] = $call('delete_quick_split_action', 1, ['id' => $thirdId])['body'];
$r['deleted_receipts'] = $GLOBALS['deleted_receipts'] ?? [];
$r['friend_after_delete'] = $call('get_quick_split_action', 4, ['id' => $thirdId])['status'];

// Add to a trip: the owner must be in the trip and the expense must be in it.
$pdo->exec('INSERT INTO trip_trips(id,name,created_by) VALUES (7,"Rome",1),(8,"Oslo",3)');
$pdo->exec('INSERT INTO trip_trip_members(trip_id,user_id,role) VALUES (7,1,"owner"),(8,3,"owner")');
$pdo->exec('INSERT INTO trip_expenses(id,trip_id,paid_by) VALUES (950,7,1),(951,8,3)');
$r['move_errors'] = [
    $call('move_quick_split_to_trip_action', 1, ['id' => $firstId, 'trip_id' => 8, 'expense_id' => 951])['status'],
    $call('move_quick_split_to_trip_action', 1, ['id' => $firstId, 'trip_id' => 7, 'expense_id' => 951])['body'],
];
$r['move'] = $call('move_quick_split_to_trip_action', 1, ['id' => $firstId, 'trip_id' => 7, 'expense_id' => 950])['body'];
$r['after_move_list'] = array_column($call('list_quick_splits_action', 2)['body']['items'], 'id');
$moved = $call('get_quick_split_action', 1, ['id' => $firstId])['body']['quick_split'];
$r['after_move_get'] = [$moved['added_to_trip'], $moved['can_edit']];
$r['after_move_update'] = $call('update_quick_split_action', 1, ['id' => $firstId] + $base)['body'];
$r['after_move_delete'] = $call('delete_quick_split_action', 1, ['id' => $firstId])['status'];

// A deleted account keeps the saved name; deleting the creator removes their quick splits.
$pdo->exec('UPDATE trip_users SET nickname = "Deleted User", account_status = "deleted" WHERE id = 2');
$r['deleted_person_name'] = $call('get_quick_split_action', 1, ['id' => $secondId])['body']['quick_split']['people'][1]['name'];
$r['creator_erased_receipts'] = delete_user_quick_splits($pdo, 1);
$r['left_after_creator_erased'] = (int) $pdo->query('SELECT COUNT(*) FROM trip_quick_splits')->fetchColumn()
    + (int) $pdo->query('SELECT COUNT(*) FROM trip_quick_split_people')->fetchColumn();

$r['push_lv'] = [
    push_localize_notification_for_locale(['type' => 'quick_split_added', 'title' => 'Quick split', 'body' => 'Owner added you to a quick split: Dinner at Lido'], 'lv'),
    push_localize_notification_for_locale(['type' => 'quick_split_added', 'title' => 'Quick split', 'body' => 'Owner added you to a quick split of EUR 84.00'], 'lv'),
];
require __DIR__ . '/../../lib/helpers/helper_notification_preferences.php';
$r['prefs'] = [notification_in_app_pref_key_for_type('quick_split_added'), notification_push_pref_key_for_type('quick_split_added')];
echo json_encode($r, JSON_THROW_ON_ERROR | JSON_UNESCAPED_UNICODE);
