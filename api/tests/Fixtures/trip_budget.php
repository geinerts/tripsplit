<?php
declare(strict_types=1);
// Reuse the isolated, real-handler SQLite harness. No live config or network.
require __DIR__ . '/trip_invitations.php';
$pdo = invitation_test_setup(false);
$actor = 1;
$body = [];
$assertions = 0;
$results = [];
$results['unmigrated_create'] = invitation_call('create_trip_action', 1, ['name'=>'Budget trip', 'budget_cents'=>10000]);
$results['unmigrated_rows'] = (int)$pdo->query('SELECT COUNT(*) FROM trip_trips')->fetchColumn();
$plain = invitation_call('create_trip_action', 1, ['name'=>'No budget']);
$results['unmigrated_plain'] = $plain;
$results['unmigrated_update'] = invitation_call('update_trip_action', 1, ['id'=>$plain['body']['trip']['id'], 'budget_cents'=>10000]);
$pdo->exec(file_get_contents(__DIR__ . '/../../../sql/migrations/2026-10-26-add-trip-budget.sql'));
foreach (['solo', 'group'] as $mode) {
    $created = invitation_call('create_trip_action', 1, ['name'=>'Budget '.$mode, 'trip_mode'=>$mode, 'budget_cents'=>125050]);
    $id = $created['body']['trip']['id'];
    $results[$mode.'_create'] = $created;
    $results[$mode.'_stored'] = (int)$pdo->query('SELECT budget_cents FROM trip_trips WHERE id='.$id)->fetchColumn();
    $results[$mode.'_rename'] = invitation_call('update_trip_action', 1, ['id'=>$id, 'name'=>'Renamed trip']);
    $results[$mode.'_edit'] = invitation_call('update_trip_action', 1, ['id'=>$id, 'budget_cents'=>99999999999]);
    $results[$mode.'_clear'] = invitation_call('update_trip_action', 1, ['id'=>$id, 'budget_cents'=>null]);
    $results[$mode.'_restore'] = invitation_call('update_trip_action', 1, ['id'=>$id, 'budget_cents'=>1]);
}
$results['outsider'] = invitation_call('update_trip_action', 2, ['id'=>$id, 'budget_cents'=>10000]);
$pdo->exec('INSERT INTO trip_trip_members(trip_id,user_id,role) VALUES ('.$id.',2,"member"),('.$id.',3,"admin")');
$results['member'] = invitation_call('update_trip_action', 2, ['id'=>$id, 'budget_cents'=>10000]);
$results['admin'] = invitation_call('update_trip_action', 3, ['id'=>$id, 'budget_cents'=>30000]);
$results['member_read'] = build_trip_payload(find_trip_for_user($pdo, 2, $id));
$results['currency_implicit'] = invitation_call('update_trip_action', 1, ['id'=>$id,'currency_code'=>'USD']);
$results['currency_explicit'] = invitation_call('update_trip_action', 1, ['id'=>$id,'currency_code'=>'USD','budget_cents'=>42000]);
$before = (int)$pdo->query('SELECT COUNT(*) FROM trip_trips')->fetchColumn();
foreach ([0, -1, 100000000000, 12.34, '10000', true, [], ['amount'=>100]] as $invalid) {
    $results['invalid'][] = [
        invitation_call('create_trip_action', 1, ['name'=>'Invalid budget', 'budget_cents'=>$invalid])['status'],
        invitation_call('update_trip_action', 1, ['id'=>$id, 'budget_cents'=>$invalid])['status'],
    ];
}
$results['invalid_no_writes'] = $before === (int)$pdo->query('SELECT COUNT(*) FROM trip_trips')->fetchColumn()
    && (int)$pdo->query('SELECT budget_cents FROM trip_trips WHERE id='.$id)->fetchColumn() === 42000;
echo json_encode($results, JSON_THROW_ON_ERROR);
