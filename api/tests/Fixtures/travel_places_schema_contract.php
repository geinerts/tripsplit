<?php
declare(strict_types=1);

// Load the production mapper without application config, credentials or a live DB.
define('DB_TABLE_PREFIX', $argv[1]);
require __DIR__ . '/../../config/config_db.php';
require __DIR__ . '/../../lib/helpers/helper_travel_places.php';
require __DIR__ . '/../../lib/helpers/helper_profile_payment_sharing.php';
require __DIR__ . '/../../lib/helpers/helper_trip_budget.php';
$driver = class_exists('Pdo\\Sqlite') ? 'Pdo\\Sqlite' : PDO::class;
$pdo = new $driver('sqlite::memory:', null, null, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
$pdo->exec("ATTACH DATABASE ':memory:' AS information_schema");
$pdo->exec('CREATE TABLE information_schema.columns (table_schema TEXT, table_name TEXT, column_name TEXT)');
if (method_exists($pdo, 'createFunction')) {
    $pdo->createFunction('DATABASE', static fn(): string => 'fixture');
} else {
    $pdo->sqliteCreateFunction('DATABASE', static fn(): string => 'fixture');
}
$column = $pdo->prepare('INSERT INTO information_schema.columns VALUES ("fixture",?,?)');
$column->execute([DB_TABLE_PREFIX . 'users', 'share_payment_details_with_trips']);
$column->execute([DB_TABLE_PREFIX . 'trips', 'budget_cents']);
$pdo->exec('CREATE TABLE ' . table_name('travel_places') . ' (
    id INTEGER, user_id INTEGER, place_key TEXT, city TEXT, region TEXT,
    country TEXT, country_code TEXT, latitude REAL, longitude REAL,
    visited_on TEXT, trip_id INTEGER, trip_name TEXT, title TEXT,
    photo_source TEXT, photo_version INTEGER, photo_data BLOB)');
$pdo->exec('CREATE TABLE ' . table_name('trip_members') . ' (trip_id INTEGER, user_id INTEGER)');
$pdo->exec('INSERT INTO ' . table_name('travel_places') . ' (id,user_id,city,trip_id) VALUES (1,7,"Lisbon",9)');
$pdo->exec('INSERT INTO ' . table_name('trip_members') . ' (trip_id,user_id) VALUES (9,7)');
$row = $pdo->query(travel_places_select($pdo) . ' WHERE p.user_id=7')->fetch(PDO::FETCH_ASSOC);
echo json_encode([
    'city' => $row['city'], 'trip_id' => (int)$row['accessible_trip_id'],
    'sharing_available' => users_trip_payment_sharing_available($pdo),
    'budget_available' => trips_budget_column_available($pdo),
], JSON_THROW_ON_ERROR);
