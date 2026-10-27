<?php
declare(strict_types=1);

// Load the production mapper without application config, credentials or a live DB.
define('DB_TABLE_PREFIX', $argv[1]);
require __DIR__ . '/../../config/config_db.php';
require __DIR__ . '/../../lib/helpers/helper_travel_places.php';
$pdo = new PDO('sqlite::memory:', null, null, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
$pdo->exec('CREATE TABLE ' . table_name('travel_places') . ' (
    id INTEGER, user_id INTEGER, place_key TEXT, city TEXT, region TEXT,
    country TEXT, country_code TEXT, latitude REAL, longitude REAL,
    visited_on TEXT, trip_id INTEGER, trip_name TEXT, title TEXT,
    photo_source TEXT, photo_version INTEGER, photo_data BLOB)');
$pdo->exec('CREATE TABLE ' . table_name('trip_members') . ' (trip_id INTEGER, user_id INTEGER)');
$pdo->exec('INSERT INTO ' . table_name('travel_places') . ' (id,user_id,city,trip_id) VALUES (1,7,"Lisbon",9)');
$pdo->exec('INSERT INTO ' . table_name('trip_members') . ' (trip_id,user_id) VALUES (9,7)');
$row = $pdo->query(travel_places_select($pdo) . ' WHERE p.user_id=7')->fetch(PDO::FETCH_ASSOC);
echo json_encode(['city' => $row['city'], 'trip_id' => (int)$row['accessible_trip_id']], JSON_THROW_ON_ERROR);
