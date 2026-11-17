<?php
declare(strict_types=1);
// Isolated SQLite harness; no live config or network.
require __DIR__ . '/trip_invitations.php';
require __DIR__ . '/../../lib/helpers/helper_trip_start_reminders.php';
$pdo = invitation_test_setup(false);
$pdo->exec('ALTER TABLE trip_trips ADD COLUMN date_from DATE NULL');
$pdo->exec('ALTER TABLE trip_trips ADD COLUMN date_to DATE NULL');
$now = gmmktime(17, 0, 0, 11, 20, 2026);
$pdo->exec("INSERT INTO trip_users (id, nickname, account_status) VALUES (11,'Anna','active'),(12,'Jana','active'),(13,'Old','deleted')");
$pdo->exec("INSERT INTO trip_trips (id, name, created_by, status, date_from) VALUES
    (21,'Lisbon',11,'active','2026-11-21'),
    (22,'Rome',11,'active','2026-11-22'),
    (23,'Done',11,'settling','2026-11-21'),
    (24,'No dates',11,'active',NULL)");
$pdo->exec("INSERT INTO trip_trip_members (trip_id, user_id, role) VALUES
    (21,11,'owner'),(21,12,'member'),(21,13,'member'),(22,11,'owner'),(23,11,'owner'),(24,11,'owner')");
$r = [];
$r['dry'] = process_trip_start_reminders($pdo, ['now' => $now, 'dry_run' => true]);
$r['dry_rows'] = (int) $pdo->query('SELECT COUNT(*) FROM trip_notifications')->fetchColumn();
$r['first'] = process_trip_start_reminders($pdo, ['now' => $now]);
$r['again'] = process_trip_start_reminders($pdo, ['now' => $now]);
$r['stored'] = $pdo->query('SELECT trip_id, user_id, type, title, body FROM trip_notifications ORDER BY user_id')->fetchAll();
$r['text'] = build_trip_start_reminder_text('');
echo json_encode($r, JSON_THROW_ON_ERROR | JSON_UNESCAPED_UNICODE);
