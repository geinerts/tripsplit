<?php
declare(strict_types=1);
// Isolated SQLite harness for quick split share links; no live config or network.
require __DIR__ . '/trip_invitations.php';
define('RATE_LIMIT_EXPENSE_WRITE_IP_MAX', 100);
define('RATE_LIMIT_EXPENSE_WRITE_USER_MAX', 100);
function normalize_receipt_path(string $path, bool $allowEmpty = true): string { return trim($path); }
function receipt_public_url(?string $path): ?string { return $path ? 'https://example.invalid/r/' . $path : null; }
function receipt_thumb_public_url(?string $path): ?string { return $path ? 'https://example.invalid/t/' . $path : null; }
function delete_receipt_file(?string $path): void {}
function avatar_thumb_public_url(?string $path): ?string { return $path ? 'https://example.invalid/a/' . $path : null; }
function format_cents_with_currency(int $cents, string $code): string { return $code . ' ' . number_format($cents / 100, 2, '.', ''); }
function private_media_signing_secret(): string { return str_repeat('k', 32); }
function auth_access_token_secret(): string { return 'test-secret'; }
require __DIR__ . '/../../lib/helpers/helper_expense_math.php';
require __DIR__ . '/../../lib/actions/quick_splits_actions.php';

$pdo = invitation_test_setup(false);
$GLOBALS['pdo'] = $pdo;
$call = static fn (string $handler, int $user, array $input = []): array => invitation_call($handler, $user, $input);
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
$pdo->exec('INSERT INTO trip_friends(user_a_id,user_b_id,requested_by,status) VALUES (1,2,1,"accepted")');
$pdo->exec('UPDATE trip_users SET avatar_path = "avatars/a.webp" WHERE id = 1');

$r = [];
$base = ['amount' => 20, 'currency_code' => 'EUR', 'note' => 'Dinner at Lido', 'category' => 'food', 'date' => '2026-11-16',
    'paid_by' => 'me', 'split_mode' => 'itemized',
    'people' => [['key' => 'me', 'user_id' => 1], ['key' => 'inv', 'user_id' => 2], ['key' => 'a', 'name' => 'Anna Bērziņa']],
    'items' => [['name' => 'Pizza', 'amount' => 12, 'people' => ['me', 'a']], ['name' => 'Beer', 'amount' => 5, 'people' => ['inv']]],
    'extra_amount' => 3];
$id = (int) $call('add_quick_split_action', 1, $base)['body']['quick_split']['id'];
$withReceipt = (int) $call('add_quick_split_action', 1, ['receipt_path' => receipt_owned_upload_path('receipts/r1.webp', 1)] + $base)['body']['quick_split']['id'];

// Before the migration: a clear 409, and get_quick_split has no link.
$r['before'] = [$call('share_quick_split_action', 1, ['id' => $id])['status'], $call('get_quick_split_action', 1, ['id' => $id])['body']['quick_split']['share'] ?? 'absent'];

$pdo->exec('CREATE TABLE trip_quick_split_shares (id INTEGER PRIMARY KEY AUTOINCREMENT, quick_split_id INT NOT NULL,
    token_salt CHAR(32) NOT NULL, token_hash CHAR(64) NOT NULL UNIQUE, show_receipt INT NOT NULL DEFAULT 0,
    created_by INT NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, expires_at TIMESTAMP NOT NULL, revoked_at TIMESTAMP NULL)');
$share = static fn (int $user, int $qs, array $extra = []): array => $call('share_quick_split_action', $user, ['id' => $qs] + $extra);

$first = $share(1, $id);
$r['first'] = $first;
$url = (string) $first['body']['share']['url'];
$token = substr($url, strlen('https://splyto.eu/split?code='));
$r['token_shape'] = (bool) preg_match('/^[A-Za-z0-9_-]{22}$/', $token);
$r['again_same_url'] = $share(1, $id)['body']['share']['url'] === $url;
$r['rows_after_two_shares'] = (int) $pdo->query('SELECT COUNT(*) FROM trip_quick_split_shares')->fetchColumn();
$stored = $pdo->query('SELECT * FROM trip_quick_split_shares')->fetch();
$r['token_not_stored'] = !in_array($token, $stored, true) && $stored['token_hash'] === hash('sha256', $token);
$r['receipt_without_photo'] = $share(1, $id, ['show_receipt' => true])['body']['share']['show_receipt'];
$r['truthy_is_not_true'] = $share(1, $withReceipt, ['show_receipt' => 1])['body']['share']['show_receipt'];
$receiptShare = $share(1, $withReceipt, ['show_receipt' => true])['body']['share'];
$r['receipt_on'] = $receiptShare['show_receipt'];
$r['errors'] = [
    'member' => $share(2, $id),
    'stranger' => $share(3, $id)['status'],
    'missing' => $share(1, 999)['status'],
    'revoke_member' => $call('revoke_quick_split_share_action', 2, ['id' => $id])['status'],
];
$r['get_owner'] = $call('get_quick_split_action', 1, ['id' => $id])['body']['quick_split']['share']['url'] === $url;
$r['get_member_has_no_share'] = array_key_exists('share', $call('get_quick_split_action', 2, ['id' => $id])['body']['quick_split']);

// The public page data: names, initials and amounts, nothing that identifies an account.
$resolved = quick_split_share_resolve($pdo, $token);
$page = quick_split_share_page_data($pdo, $resolved);
$r['page'] = $page;
$r['page_json_leaks'] = array_values(array_filter(['user_id', 'avatar', 'email', 'is_me', 'is_account'],
    static fn (string $needle): bool => str_contains(json_encode($page), $needle)));
$receiptPage = quick_split_share_page_data($pdo, quick_split_share_resolve($pdo, substr($receiptShare['url'], 29)));
$r['receipt_page'] = $receiptPage['receipt_url'] !== null;
$share(1, $withReceipt, ['show_receipt' => false]);
$r['receipt_page_after_off'] = quick_split_share_page_data($pdo, quick_split_share_resolve($pdo, substr($receiptShare['url'], 29)))['receipt_url'];
$r['bad_tokens'] = [
    quick_split_share_resolve($pdo, '') === null,
    quick_split_share_resolve($pdo, str_repeat('A', 22)) === null,
    quick_split_share_resolve($pdo, $token . 'x') === null,
    quick_split_share_resolve($pdo, ['x']) === null,
];

// Expired: a new link next time.
$pdo->exec('UPDATE trip_quick_split_shares SET expires_at = "2000-01-01 00:00:00" WHERE quick_split_id = ' . $id);
$r['expired_resolves'] = quick_split_share_resolve($pdo, $token) !== null;
$renewed = $share(1, $id)['body']['share']['url'];
$r['renewed_is_new'] = $renewed !== $url;
$token = substr($renewed, 29);

// Suspended creator: the link stops answering.
$pdo->exec('UPDATE trip_users SET account_status = "suspended" WHERE id = 1');
$r['suspended_resolves'] = quick_split_share_resolve($pdo, $token) !== null;
$pdo->exec('UPDATE trip_users SET account_status = "active" WHERE id = 1');

// Revoke ends it at once; sharing again makes a new one.
$r['revoke'] = $call('revoke_quick_split_share_action', 1, ['id' => $id])['body'];
$r['revoked_resolves'] = quick_split_share_resolve($pdo, $token) !== null;
$r['get_after_revoke'] = $call('get_quick_split_action', 1, ['id' => $id])['body']['quick_split']['share'];
$token = substr($share(1, $id)['body']['share']['url'], 29);

// Added to a trip: the link ends and can't be made again.
$pdo->exec('INSERT INTO trip_trips(id,name,created_by) VALUES (7,"Rome",1)');
$pdo->exec('INSERT INTO trip_trip_members(trip_id,user_id,role) VALUES (7,1,"owner")');
$pdo->exec('INSERT INTO trip_expenses(id,trip_id,paid_by) VALUES (950,7,1)');
$call('move_quick_split_to_trip_action', 1, ['id' => $id, 'trip_id' => 7, 'expense_id' => 950]);
$r['moved_resolves'] = quick_split_share_resolve($pdo, $token) !== null;
$r['moved_share'] = $share(1, $id)['status'];

// Deleting the quick split, or the creator's quick splits, removes its links.
$call('delete_quick_split_action', 1, ['id' => $withReceipt]);
$r['links_after_delete'] = (int) $pdo->query('SELECT COUNT(*) FROM trip_quick_split_shares WHERE quick_split_id = ' . $withReceipt)->fetchColumn();
delete_user_quick_splits($pdo, 1);
$r['links_after_account_erased'] = (int) $pdo->query('SELECT COUNT(*) FROM trip_quick_split_shares')->fetchColumn();
echo json_encode($r, JSON_THROW_ON_ERROR | JSON_UNESCAPED_UNICODE);
