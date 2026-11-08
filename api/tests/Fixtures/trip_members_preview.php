<?php
declare(strict_types=1);
// The real trips handler in the isolated SQLite harness. No live config or network.
require __DIR__ . '/trip_invitations.php';
require_once __DIR__ . '/../../lib/helpers/helper_premium.php';
require_once __DIR__ . '/../../config/config_uploads.php';
if (!function_exists('normalize_profile_currency_code_or_default')) {
    function normalize_profile_currency_code_or_default($code): string { return is_string($code) && $code !== '' ? $code : 'EUR'; }
}
$pdo = invitation_test_setup(false);
$actor = 1;
$body = [];
$assertions = 0;
foreach (['ALTER TABLE trip_settlements ADD COLUMN status VARCHAR(20)', 'ALTER TABLE trip_expenses ADD COLUMN amount DECIMAL(12,2)',
    'ALTER TABLE trip_expense_participants ADD COLUMN owed_cents INT'] as $sql) {
    $pdo->exec($sql);
}
$pdo->exec('INSERT INTO trip_users(id,nickname,account_status) VALUES (4,"Fourth","active"),(5,"Fifth","active"),(6,"Outsider","active")');
$pdo->exec('UPDATE trip_users SET first_name = "Matiss", last_name = "Geinerts" WHERE id = 1');
$pdo->exec('UPDATE trip_users SET avatar_path = "uploads/avatars/2.jpg" WHERE id = 2');

/** Trip id => members_preview, as the trips list returns them to $user. */
function trip_members_preview_list(int $user): array
{
    $response = invitation_call('trips_action', $user);
    if ($response['status'] !== 200) throw new RuntimeException('trips failed: ' . json_encode($response));
    return array_column($response['body']['trips'], 'members_preview', 'id');
}

$rome = invitation_call('create_trip_action', 1, ['name' => 'Rome'])['body']['trip']['id'];
$oslo = invitation_call('create_trip_action', 1, ['name' => 'Oslo'])['body']['trip']['id'];
foreach ([5, 2, 4, 3] as $member) {
    $pdo->exec("INSERT INTO trip_trip_members(trip_id,user_id,role) VALUES ($rome,$member,'member')");
}

$trips = invitation_call('trips_action', 1)['body']['trips'];
echo json_encode([
    'ids' => ['rome' => $rome, 'oslo' => $oslo],
    'owner' => trip_members_preview_list(1),
    'member' => trip_members_preview_list(2),
    'outsider' => trip_members_preview_list(6) === [] ? [] : 'unexpected',
    'counts' => array_column($trips, 'members_count', 'id'),
], JSON_THROW_ON_ERROR);
