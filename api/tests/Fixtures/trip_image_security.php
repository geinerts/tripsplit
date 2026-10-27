<?php
declare(strict_types=1);
// CLI-only: in-memory database and synthetic files in a unique output/tests directory. No config/.env/network.
if (PHP_SAPI !== 'cli') exit(1);
$root = dirname(__DIR__, 3);
define('DB_TABLE_PREFIX', 'trip_');
define('TRIP_IMAGES_REL_DIR', 'output/tests/trip-image-' . bin2hex(random_bytes(8)));
define('PUBLIC_BASE_URL', 'https://fixture.invalid');
define('TRUST_PROXY_HEADERS', false);
foreach (['RATE_LIMIT_TRIP_WRITE_IP_MAX','RATE_LIMIT_TRIP_WRITE_USER_MAX','RATE_LIMIT_MUTATION_WINDOW_SEC'] as $c) define($c,100);
final class Response extends RuntimeException { public function __construct(public int $status, public array $payload) { parent::__construct('Synthetic response'); } }
function json_out(array $payload,int $status=200): void { throw new Response($status,$payload); }
function require_post(): void {}
function auth_access_token_secret(): string { return 'synthetic-trip-image-test-key'; }
function get_me(): array { return ['id'=>7]; }
function db(): PDO { return $GLOBALS['pdo']; }
function read_json(): array { return $GLOBALS['body']; }
function table_name(string $name): string { return 'trip_'.$name; }
function trips_currency_column_available(PDO $pdo): bool { return true; }
function normalize_currency_code($value): string { return (string)$value; }
function default_trip_currency_code(): string { return 'EUR'; }
function enforce_rate_limit(...$args): void {}
function client_ip_address(): string { return '192.0.2.1'; }
function app_event(...$args): void {}
final class SyntheticDb extends PDO {
    public function prepare(string $query,array $options=[]): PDOStatement|false {
        if (str_contains($query,'information_schema.columns') && str_contains($query,':column')) {
            return parent::prepare('SELECT COUNT(*) FROM pragma_table_info(:table_name) WHERE name=:column',$options);
        }
        if (str_contains($query,'information_schema.columns')) $query='SELECT '.(str_contains($query,'budget_cents') ? '0' : '1')." WHERE :table_name <> ''";
        if (str_starts_with(trim($query), 'DELETE FROM')) $query = str_replace('LIMIT 1', '', $query);
        return parent::prepare($query,$options);
    }
}
$pdo=new SyntheticDb('sqlite::memory:',null,null,[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
$pdo->exec('CREATE TABLE trip_trips (id INTEGER PRIMARY KEY,name TEXT,currency_code TEXT,trip_mode TEXT,status TEXT,created_by INTEGER,image_path TEXT,ended_at TEXT,archived_at TEXT)');
$pdo->exec('CREATE TABLE trip_expenses (trip_id INTEGER)');
$pdo->exec('CREATE TABLE trip_trip_members (trip_id INTEGER,user_id INTEGER,role TEXT)');
$pdo->exec("INSERT INTO trip_trip_members VALUES (1,7,'owner'),(2,8,'owner')");
$image=TRIP_IMAGES_REL_DIR.'/victim.webp';
$pdo->prepare("INSERT INTO trip_trips VALUES(1,'Attacker trip','EUR','group','active',7,NULL,NULL,NULL),(2,'Victim trip','EUR','group','active',8,?,NULL,NULL)")->execute([$image]);
require $root.'/api/config/config_uploads.php';
require $root.'/api/lib/helpers/helper_trip.php';
require $root.'/api/lib/actions/trips_actions.php';
$directory=$root.'/'.TRIP_IMAGES_REL_DIR;
if (!is_dir($directory)) mkdir($directory,0700,true);
file_put_contents($directory.'/victim.webp','synthetic cover sentinel');
file_put_contents($directory.'/victim_thumb.webp','synthetic thumbnail sentinel');
function invoke(array $request, string $handler = 'update_trip_action'): int {
    $GLOBALS['body']=$request;
    try { $handler(); } catch(Response $r) { return $r->status; }
    throw new RuntimeException('Missing response');
}

function filePairExists(string $path): bool {
    return is_file(upload_relative_path_to_abs($path)) && is_file(upload_relative_path_to_abs(upload_thumb_relative_path($path)));
}
try {
    $results = [];
    $results['direct_denied'] = invoke(['id'=>2,'remove_image'=>true]);
    $results['foreign_legacy_denied'] = invoke(['id'=>1,'image_path'=>$image]);
    $results['foreign_intact'] = filePairExists($image);
    // Run the same binding function used by the upload endpoint, including thumbnail renaming.
    $raw = TRIP_IMAGES_REL_DIR.'/new.webp';
    file_put_contents(upload_relative_path_to_abs($raw), 'synthetic new cover');
    $thumb = upload_thumb_relative_path($raw);
    file_put_contents(upload_relative_path_to_abs($thumb), 'synthetic new thumb');
    $owned = bind_stored_trip_image_to_owner(['path'=>$raw, 'thumb_path'=>$thumb], 1, 7);
    $results['binding_renamed_pair'] = filePairExists($owned) && !is_file(upload_relative_path_to_abs($raw));
    $results['own_signed_accepted'] = invoke(['id'=>1,'image_path'=>$owned]);
    $results['unchanged_accepted'] = invoke(['id'=>1,'image_path'=>$owned]);
    foreach ([[2, 7], [1, 8]] as [$tripId, $userId]) {
        file_put_contents(upload_relative_path_to_abs(trip_image_owned_upload_path($raw, $tripId, $userId)), 'synthetic foreign cover');
    }
    $results['foreign_signed_denied'] = invoke(['id'=>1,'image_path'=>trip_image_owned_upload_path($raw,2,7)]);
    $results['other_uploader_denied'] = invoke(['id'=>1,'image_path'=>trip_image_owned_upload_path($raw,1,8)]);
    $results['tampered_denied'] = invoke(['id'=>1,'image_path'=>str_replace('new_', 'tampered_', $owned)]);
    $results['remove_accepted'] = invoke(['id'=>1,'remove_image'=>true]);
    $results['unreferenced_pair_removed'] = !file_exists(upload_relative_path_to_abs($owned)) && !file_exists(upload_relative_path_to_abs(upload_thumb_relative_path($owned)));
    $results['deleted_upload_denied'] = invoke(['id'=>1,'image_path'=>$owned]);
    // Historic shared references must survive updates AND deletion of the referencing trip.
    $pdo->prepare('UPDATE trip_trips SET image_path=? WHERE id=1')->execute([$image]);
    $results['unchanged_legacy_accepted'] = invoke(['id'=>1,'image_path'=>$image]);
    $results['shared_remove_accepted'] = invoke(['id'=>1,'remove_image'=>true]);
    $results['shared_survives_remove'] = filePairExists($image);
    $pdo->prepare('UPDATE trip_trips SET image_path=? WHERE id=1')->execute([$image]);
    $results['shared_delete_accepted'] = invoke(['id'=>1], 'delete_trip_action');
    $results['shared_survives_delete'] = filePairExists($image);
    $results['victim_reference_unchanged'] = $pdo->query('SELECT image_path FROM trip_trips WHERE id=2')->fetchColumn() === $image;
    // Replacing a legacy shared cover also keeps the other trip's original intact.
    $pdo->prepare("INSERT INTO trip_trips VALUES(3,'Third trip','EUR','group','active',7,?,NULL,NULL)")->execute([$image]);
    $pdo->exec("INSERT INTO trip_trip_members VALUES (3,7,'owner')");
    $rawReplacement = TRIP_IMAGES_REL_DIR.'/replacement.webp';
    file_put_contents(upload_relative_path_to_abs($rawReplacement), 'synthetic replacement');
    file_put_contents(upload_relative_path_to_abs(upload_thumb_relative_path($rawReplacement)), 'synthetic thumb');
    $replacement = bind_stored_trip_image_to_owner(['path'=>$rawReplacement, 'thumb_path'=>upload_thumb_relative_path($rawReplacement)], 3, 7);
    $results['shared_replace_accepted'] = invoke(['id'=>3,'image_path'=>$replacement]);
    $results['shared_survives_replace'] = filePairExists($image);
    $results['sole_delete_accepted'] = invoke(['id'=>3], 'delete_trip_action');
    $results['sole_delete_removes_pair'] = !file_exists(upload_relative_path_to_abs($replacement)) && !file_exists(upload_relative_path_to_abs(upload_thumb_relative_path($replacement)));
    echo json_encode($results, JSON_THROW_ON_ERROR);
} finally {
    foreach (glob($directory.'/*') ?: [] as $file) unlink($file);
    rmdir($directory);
}
