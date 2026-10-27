<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') exit(1);
// In-memory handler harness, no production config, secrets, requests or mail.
final class SharingResponse extends RuntimeException {
    public function __construct(public array $payload, public int $status) { parent::__construct('response'); }
}
final class SharingPDO extends PDO {
    public function prepare(string $query, array $options = []): PDOStatement|false {
        if (str_contains($query, 'information_schema.columns')) {
            $query = ($GLOBALS['available'] ? 'SELECT 1' : 'SELECT 0') . " WHERE :table_name <> ''";
        }
        return parent::prepare($query, $options);
    }
}
$available = ($argv[1] ?? '') !== 'missing';
$pdo = new SharingPDO('sqlite::memory:', null, null, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
$pdo->exec('CREATE TABLE trip_users(id INTEGER PRIMARY KEY, share_payment_details_with_trips INTEGER NOT NULL DEFAULT 0)');
$pdo->exec('INSERT INTO trip_users(id) VALUES(1),(2)');
function db(): PDO { return $GLOBALS['pdo']; }
function get_me(): array { return ['id'=>1]; }
function require_post(): void {}
function read_json(): array { return $GLOBALS['body']; }
function table_name(string $key): string { return 'trip_'.$key; }
function json_out(array $payload, int $status=200): void { throw new SharingResponse($payload,$status); }
function users_name_columns_available(PDO $pdo): bool { return false; }
function users_payment_columns_available(PDO $pdo): bool { return false; }
function users_revolut_me_link_column_available(PDO $pdo): bool { return false; }
function users_wise_pay_link_column_available(PDO $pdo): bool { return false; }
function users_preferred_currency_column_available(PDO $pdo): bool { return false; }
function fetch_me_row_by_id(PDO $pdo, int $id): array {
    $stmt=$pdo->prepare('SELECT * FROM trip_users WHERE id=?'); $stmt->execute([$id]); return $stmt->fetch(PDO::FETCH_ASSOC);
}
function build_me_payload(array $row, PDO $pdo): array { return $row; }
require __DIR__.'/../../lib/actions/auth_actions.php';
$results=[];
foreach (['enable'=>true,'disable'=>false,'invalid'=>'true'] as $case=>$value) {
    $body=['share_payment_details_with_trips'=>$value, 'id'=>2, 'user_id'=>2];
    try { update_profile_action(); } catch (SharingResponse $e) {
        $results[$case]=['status'=>$e->status, 'owner'=>fetch_me_row_by_id($pdo,1), 'other'=>fetch_me_row_by_id($pdo,2)];
    }
}
echo json_encode($results, JSON_THROW_ON_ERROR);
