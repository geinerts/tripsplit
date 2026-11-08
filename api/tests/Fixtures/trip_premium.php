<?php
declare(strict_types=1);
// The real trips handler in the isolated SQLite harness. No live config or network.
require __DIR__ . '/trip_invitations.php';
require_once __DIR__ . '/../../lib/helpers/helper_premium.php';
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

/** Trip id => premium_features, as the trips list returns them to $user. */
function trip_premium_list(int $user): array
{
    $response = invitation_call('trips_action', $user);
    if ($response['status'] !== 200) throw new RuntimeException('trips failed: ' . json_encode($response));
    return array_column($response['body']['trips'], 'premium_features', 'id');
}

$rome = invitation_call('create_trip_action', 1, ['name' => 'Rome'])['body']['trip']['id'];
$oslo = invitation_call('create_trip_action', 1, ['name' => 'Oslo'])['body']['trip']['id'];
$pdo->exec("INSERT INTO trip_trip_members(trip_id,user_id,role) VALUES ($rome,2,'member')");

$results = [];
$results['no_tables'] = trip_premium_list(1);

$pdo->exec('CREATE TABLE trip_premium_grants (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INT, source VARCHAR(20),
    starts_at DATETIME, ends_at DATETIME, revoked_at DATETIME NULL)');
$pdo->exec('CREATE TABLE trip_premium_trip_grants (id INTEGER PRIMARY KEY AUTOINCREMENT, trip_id INT, source VARCHAR(20),
    reason TEXT, revoked_at DATETIME NULL, version INT DEFAULT 1, created_at DATETIME)');
$results['free'] = trip_premium_list(1);

$pdo->exec("INSERT INTO trip_premium_trip_grants(trip_id,source,reason,created_at) VALUES ($rome,'testing','Pilot','2026-11-08')");
$results['owner_with_trip_premium'] = trip_premium_list(1);
$results['member_with_trip_premium'] = trip_premium_list(2);
$results['outsider_before_joining'] = trip_premium_list(3);
$pdo->exec("INSERT INTO trip_trip_members(trip_id,user_id,role) VALUES ($rome,3,'member')");
$results['member_who_joined_later'] = trip_premium_list(3);
$pdo->exec("DELETE FROM trip_trip_members WHERE trip_id = $rome AND user_id = 3");
$results['member_who_left'] = trip_premium_list(3);

$pdo->exec('UPDATE trip_premium_trip_grants SET revoked_at = "2026-11-08"');
$results['after_revoke'] = trip_premium_list(2);

$pdo->exec("INSERT INTO trip_premium_grants(user_id,source,starts_at,ends_at) VALUES (1,'testing','2000-01-01','2100-01-01')");
$results['own_premium'] = trip_premium_list(1);
$results['other_member_without_own_premium'] = trip_premium_list(2);

$results['ids'] = ['rome' => $rome, 'oslo' => $oslo];
echo json_encode($results, JSON_THROW_ON_ERROR);
