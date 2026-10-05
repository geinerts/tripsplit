<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/isolated_mysql.php';
require __DIR__ . '/../../config/config_user_validation.php';
require __DIR__ . '/../../lib/actions/settlements/settlements_payments.php';
define('DB_TABLE_PREFIX', 'trip_');
define('RATE_LIMIT_TRIP_WRITE_IP_MAX', 100);
define('RATE_LIMIT_TRIP_WRITE_USER_MAX', 100);
define('RATE_LIMIT_MUTATION_WINDOW_SEC', 60);

class PaymentTestResponse extends RuntimeException {
    public function __construct(public array $payload, public int $status) { parent::__construct(); }
}
function json_out(array $payload, int $status = 200): void { throw new PaymentTestResponse($payload, $status); }
function table_name(string $key): string { return 'trip_' . $key; }
function db(): PDO { return $GLOBALS['pdo']; }
function require_post(): void {}
function read_json(): array { return $GLOBALS['body']; }
function bearer_access_token_from_header(): string { return 'synthetic-auth'; }
function resolve_user_id_from_access_token(string $token): int { return $GLOBALS['actor']; }
function fetch_me_row_by_id(PDO $pdo, int $id): ?array {
    $stmt = $pdo->prepare('SELECT * FROM trip_users WHERE id=:id');
    $stmt->execute(['id'=>$id]);
    return $stmt->fetch() ?: null;
}
// HTTP authentication, rate limits, notifications, balance math and idempotency
// storage are adapters here; the real payment handler/SQL/transaction run below.
function get_current_trip(PDO $pdo, array $me, bool $required): array {
    $stmt = $pdo->prepare('SELECT t.* FROM trip_trips t JOIN trip_trip_members m
        ON m.trip_id=t.id WHERE t.id=10 AND m.user_id=:user');
    $stmt->execute(['user'=>$me['id']]);
    $row = $stmt->fetch();
    if (!$row) json_out(['ok'=>false],403);
    return $row;
}
function normalize_trip_status($status): string { return (string) $status; }
function client_ip_address(): string { return '192.0.2.1'; }
function enforce_rate_limit(...$args): void {}
function request_client_mutation_id(): string { return 'synthetic-mutation'; }
function mutation_idempotency_try_replay(...$args): void {}
function mutation_idempotency_find_response(...$args): ?array { return null; }
function mutation_idempotency_store_response(...$args): void {
    if ($GLOBALS['scenario'] === 'rollback') throw new RuntimeException('synthetic write failure');
}
function compute_trip_balance_data(PDO $pdo, int $tripId): array {
    return ['recommended_settlements'=>[['from_user_id'=>1,'to_user_id'=>2,'amount_cents'=>1000]]];
}
function format_cents_with_currency(int $cents, string $currency): string { return '10 EUR'; }
function trip_currency_code_from_trip(array $trip): string { return 'EUR'; }
function create_user_notification(...$args): void {}
function app_event(...$args): void {}

class_alias(class_exists('Pdo\\Sqlite') ? 'Pdo\\Sqlite' : PDO::class, 'PaymentSQLiteBase');
class PaymentSQLite extends PaymentSQLiteBase {
    public function prepare(string $query, array $options = []): PDOStatement|false {
        if (str_contains($query, 'information_schema.tables')) {
            $query = "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name=:table_name";
        } elseif (str_contains($query, 'information_schema.columns')) {
            $query = "SELECT COUNT(*) FROM pragma_table_info(:table_name) WHERE name='share_payment_details'";
        }
        return parent::prepare(str_replace('FOR UPDATE', '', $query), $options);
    }
}

$scenario = $argv[1];
$mysql = getenv('SPLYTO_ISOLATED_MYSQL') === '1';
$pdo = $mysql ? isolated_test_mysql() : new PaymentSQLite('sqlite::memory:');
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
$pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
if ($mysql) $pdo->exec('SET FOREIGN_KEY_CHECKS=0');
foreach (['payments','trip_members','trips','users'] as $table) $pdo->exec('DROP TABLE IF EXISTS trip_' . $table);
if ($mysql) $pdo->exec('SET FOREIGN_KEY_CHECKS=1');
$pdo->exec('CREATE TABLE trip_users (id INTEGER PRIMARY KEY, nickname VARCHAR(64), account_status VARCHAR(20),
    bank_account_holder VARCHAR(100), bank_iban VARCHAR(100), bank_bic VARCHAR(100),
    revolut_handle VARCHAR(100), revolut_me_link VARCHAR(255), paypal_me_link VARCHAR(255), wise_pay_link VARCHAR(255))');
$pdo->exec('CREATE TABLE trip_trips (id INTEGER PRIMARY KEY, status VARCHAR(20), updated_at TIMESTAMP NULL)');
$pdo->exec('CREATE TABLE trip_trip_members (trip_id INTEGER, user_id INTEGER, PRIMARY KEY(trip_id,user_id))');
$id = $mysql ? 'INT PRIMARY KEY AUTO_INCREMENT' : 'INTEGER PRIMARY KEY AUTOINCREMENT';
$pdo->exec('CREATE TABLE trip_payments (id ' . $id . ', trip_id INTEGER, from_user_id INTEGER, to_user_id INTEGER,
    amount_cents INTEGER, status VARCHAR(20), note VARCHAR(255), requester_user_id INTEGER,
    requested_at TIMESTAMP NULL, marked_sent_at TIMESTAMP NULL, confirmed_at TIMESTAMP NULL,
    cancelled_at TIMESTAMP NULL, cancel_reason VARCHAR(30), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)');
if (!str_starts_with($scenario, 'unmigrated')) {
    $pdo->exec($mysql
        ? file_get_contents(__DIR__ . '/../../../sql/migrations/2026-10-05-add-payment-details-consent.sql')
        : 'ALTER TABLE trip_payments ADD COLUMN share_payment_details INTEGER NOT NULL DEFAULT 0');
}
$pdo->exec('INSERT INTO trip_users (id,nickname,account_status,bank_iban) VALUES
    (1,"Payer","active","PAYER-SECRET"),(2,"Payee","active","PAYEE-SECRET"),(3,"Owner","active","OWNER-SECRET")');
$pdo->exec('INSERT INTO trip_trips(id,status) VALUES (10,"active")');
$pdo->exec('INSERT INTO trip_trip_members VALUES (10,1),(10,2),(10,3)');
$actor = 2;
$body = ['from_user_id'=>1,'amount'=>10,'to_user_id'=>3,'requester_user_id'=>3];
switch ($scenario) {
    case 'true': case 'rollback': case 'unmigrated_true': $body['share_payment_details'] = true; break;
    case 'false': $body['share_payment_details'] = false; break;
    case 'string': $body['share_payment_details'] = 'true'; break;
    case 'integer': $body['share_payment_details'] = 1; break;
    case 'missing': case 'unmigrated_missing': break;
    default: throw new RuntimeException('Unknown test scenario');
}
try {
    create_trip_payment_request_action();
} catch (PaymentTestResponse $response) {
    $result = ['status'=>$response->status];
} catch (RuntimeException $error) {
    if ($scenario !== 'rollback') throw $error;
    $result = ['status'=>500];
}
$rows = $pdo->query('SELECT * FROM trip_payments')->fetchAll();
$result['count'] = count($rows);
$result['open_transaction'] = $pdo->inTransaction();
$result['consent'] = (int) ($rows[0]['share_payment_details'] ?? 0);
$result['payee'] = (int) ($rows[0]['to_user_id'] ?? 0);
$result['requester'] = (int) ($rows[0]['requester_user_id'] ?? 0);
if ($rows !== [] && !str_starts_with($scenario, 'unmigrated')) {
    $actor = 1;
    $body = ['payment_id'=>$rows[0]['id']];
    try { trip_payment_request_details_action(); } catch (PaymentTestResponse $response) {
        $result['read_status'] = $response->status;
        $result['expected_details'] = ($response->payload['payment_details']['bank_iban'] ?? '') === 'PAYEE-SECRET';
    }
}
echo json_encode($result, JSON_THROW_ON_ERROR);
