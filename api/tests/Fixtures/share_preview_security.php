<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
// Synthetic, memory-only data. Loads no config/environment and makes no requests.
$pdo = new PDO('sqlite::memory:', null, null, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC]);
function db(): PDO { return $GLOBALS['pdo']; }
function table_name(string $key): string { return 'fixture_' . $key; }
function trips_image_column_available(PDO $pdo): bool { return true; }
function normalize_trip_status(mixed $value): string { return (string) $value; }
require __DIR__ . '/../../lib/helpers/helper_share_preview.php';
$pdo->exec('CREATE TABLE fixture_trips(id INTEGER PRIMARY KEY, name TEXT, status TEXT, image_path TEXT)');
$pdo->exec('CREATE TABLE fixture_trip_invites(id INTEGER PRIMARY KEY, trip_id INTEGER, invite_code TEXT, expires_at TEXT, revoked_at TEXT, target_user_id INTEGER)');
$pdo->prepare('INSERT INTO fixture_trips VALUES (1, ?, ?, ?)')->execute(['Synthetic private trip', 'active', 'uploads/trips/synthetic-private.webp']);
$pdo->prepare('INSERT INTO fixture_trip_invites VALUES (1, 1, ?, ?, NULL, NULL)')->execute(['abc123def4', gmdate('Y-m-d H:i:s',time()+86400)]);
$results=[];
foreach (['valid', 'revoked', 'expired', 'archived', 'directed', 'missing', 'empty_expiry', 'invalid_expiry', 'null_code', 'just_expired'] as $case) {
 $pdo->prepare('UPDATE fixture_trip_invites SET expires_at=?, revoked_at=NULL, target_user_id=NULL')->execute([gmdate('Y-m-d H:i:s',time()+86400)]);
 $pdo->exec("UPDATE fixture_trips SET status='active'");
 if ($case==='revoked') $pdo->exec("UPDATE fixture_trip_invites SET revoked_at='2026-01-01 00:00:00'");
 if ($case==='expired') $pdo->exec("UPDATE fixture_trip_invites SET expires_at='2026-01-01 00:00:00'");
 if ($case==='archived') $pdo->exec("UPDATE fixture_trips SET status='archived'");
 if ($case==='directed') $pdo->exec('UPDATE fixture_trip_invites SET target_user_id=42');
 if ($case==='just_expired') $pdo->prepare('UPDATE fixture_trip_invites SET expires_at=?')->execute([gmdate('Y-m-d H:i:s')]);
 if ($case==='empty_expiry') $pdo->exec("UPDATE fixture_trip_invites SET expires_at=''");
 if ($case==='invalid_expiry') $pdo->exec("UPDATE fixture_trip_invites SET expires_at='not-a-date'");
 $meta=share_trip_meta($case==='null_code'?null:($case==='missing'?'none123456':'abc123def4'));
 $results[$case]=$meta;
}
$pdo->exec("UPDATE fixture_trip_invites SET target_user_id=NULL, revoked_at='2026-01-01 00:00:00'");
$pdo->exec("UPDATE fixture_trips SET name='New synthetic name after revocation', image_path='uploads/trips/new-after-revocation.webp'");
$results['revoked_then_updated']=share_trip_meta('abc123def4');
echo json_encode($results, JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES),"\n";
