<?php
declare(strict_types=1);
// Runs one scan_receipt scenario in its own process and prints JSON.
// The provider is a stand-in: no real AI call and no cost. SQLite checks
// handler behaviour; MySQL locking is in tests/Integration/verify_receipt_scan.php.
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }

final class ScanResponse extends RuntimeException
{
    public function __construct(public array $payload, public int $status) { parent::__construct('response'); }
}
function json_out(array $payload, int $status = 200): void { throw new ScanResponse($payload, $status); }
function table_name(string $key): string { return 'trip_' . $key; }
function db(): PDO { return $GLOBALS['pdo']; }
function require_post(): void {}
function read_json(): array { return $GLOBALS['body']; }
function get_me(): array { return ['id' => $GLOBALS['me'], 'nickname' => 'Owner']; }
function client_ip_address(): string { return '192.0.2.1'; }
function enforce_rate_limit(PDO $pdo, string $scope, ...$args): void { $GLOBALS['rates'][] = $scope; }
function users_account_status_select_sql(PDO $pdo, string $alias = ''): string { return 'account_status, '; }
function user_account_status(array $user): string { return (string) ($user['account_status'] ?? 'active'); }
function assert_receipt_attachment_owned(string $path, int $userId, string $existing = ''): void
{
    if (!str_starts_with($path, 'receipts/u' . $userId . '_')) {
        json_out(['ok' => false, 'error' => 'Receipt must be uploaded by you. Please upload it again.'], 403);
    }
}
function upload_relative_path_to_abs(string $path): ?string { return $GLOBALS['dir'] . '/' . basename($path); }

foreach ([
    'OPENAI_API_KEY' => 'sk-test-not-real', 'RECEIPT_AI_MODEL' => 'gpt-5.4-mini-2026-03-17',
    'RECEIPT_AI_PRICE_INPUT_MICROUSD' => 750_000, 'RECEIPT_AI_PRICE_OUTPUT_MICROUSD' => 4_500_000,
    'RECEIPT_AI_RESERVE_MICROUSD' => 15_000, 'RECEIPT_AI_BUDGET_HOUR_MICROUSD' => 500_000,
    'RECEIPT_AI_BUDGET_DAY_MICROUSD' => 2_000_000, 'RECEIPT_AI_BUDGET_MONTH_MICROUSD' => 15_000_000,
    'RECEIPT_AI_USER_DAY_MAX' => 20, 'RECEIPT_AI_USER_MONTH_MAX' => 200,
    'RECEIPT_AI_MAX_OUTPUT_TOKENS' => 2000, 'RECEIPT_AI_TIMEOUT_SEC' => 30,
] as $name => $value) {
    define($name, $value);
}
require __DIR__ . '/../../lib/actions/receipt_scan_actions.php';

final class ScanSQLite extends PDO
{
    public function prepare(string $query, array $options = []): PDOStatement|false
    {
        $query = str_replace([' FOR UPDATE', 'INSERT IGNORE INTO'], ['', 'INSERT OR IGNORE INTO'], $query);
        return parent::prepare($query, $options);
    }
}
$pdo = new ScanSQLite('sqlite::memory:', null, null, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
$GLOBALS['pdo'] = $pdo;
$GLOBALS['me'] = 1;
$GLOBALS['rates'] = [];
$GLOBALS['calls'] = [];
$GLOBALS['dir'] = sys_get_temp_dir() . '/splyto-scan-' . getmypid();
@mkdir($GLOBALS['dir']);
register_shutdown_function(static function (): void {
    array_map('unlink', glob($GLOBALS['dir'] . '/*') ?: []);
    @rmdir($GLOBALS['dir']);
});

$pdo->exec("CREATE TABLE trip_users (id INTEGER PRIMARY KEY, email TEXT, email_verified_at TEXT,
    account_status TEXT DEFAULT 'active', guest_trip_id INT NULL)");
$pdo->exec("INSERT INTO trip_users VALUES (1, 'owner@example.invalid', '2026-01-01', 'active', NULL),
    (2, NULL, NULL, 'active', NULL), (3, 'other@example.invalid', '2026-01-01', 'active', NULL)");
$pdo->exec("CREATE TABLE trip_feature_flags (flag_key TEXT PRIMARY KEY, mode TEXT, updated_at TEXT, updated_by_admin_id INT)");
$pdo->exec('CREATE TABLE trip_user_features (user_id INT, flag_key TEXT, granted_at TEXT, granted_by_admin_id INT)');
$pdo->exec("INSERT INTO trip_feature_flags (flag_key, mode) VALUES ('receipt_ai', 'allowlist')");
$pdo->exec("INSERT INTO trip_user_features (user_id, flag_key) VALUES (1, 'receipt_ai'), (2, 'receipt_ai')");
$pdo->exec("CREATE TABLE trip_ai_scans (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INT, request_id TEXT,
    receipt_path TEXT, image_sha256 TEXT, status TEXT DEFAULT 'reserved', model TEXT, reserved_microusd INT DEFAULT 0,
    cost_microusd INT NULL, input_tokens INT NULL, output_tokens INT NULL, duration_ms INT NULL, error_code TEXT NULL,
    result_json TEXT NULL, budget_hour TEXT, budget_day TEXT, budget_month TEXT, created_at TEXT, finished_at TEXT NULL,
    UNIQUE (user_id, request_id))");
$pdo->exec('CREATE TABLE trip_ai_budget (period TEXT PRIMARY KEY, spent_microusd INT NOT NULL DEFAULT 0,
    reserved_microusd INT NOT NULL DEFAULT 0, updated_at TEXT)');

function make_image(string $name, int $width, int $height): void
{
    $image = imagecreatetruecolor($width, $height);
    imagefill($image, 0, 0, imagecolorallocate($image, 255, 255, 255));
    imagepng($image, $GLOBALS['dir'] . '/' . $name);
}
make_image('u1_receipt.png', 400, 900);
make_image('u1_other.png', 401, 900);
make_image('u1_big.png', 2000, 3000);

$receipt = ['is_receipt' => true, 'merchant' => 'Rimi', 'date' => '2026-11-19', 'currency' => 'eur',
    'items' => [['name' => 'Milk', 'quantity' => 2, 'unit_price' => 1.29, 'total' => 2.58, 'uncertain' => false],
        ['name' => 'Bread', 'quantity' => 1, 'unit_price' => 1.1, 'total' => 1.1, 'uncertain' => true],
        ['name' => 'Discount', 'quantity' => null, 'unit_price' => null, 'total' => -0.5, 'uncertain' => false]],
    'discounts' => null, 'tax' => null, 'tip' => null, 'service_charge' => null, 'total' => 3.18, 'notes' => null];
$GLOBALS['answer'] = ['ok' => true, 'data' => $receipt, 'input_tokens' => 2000, 'output_tokens' => 400, 'error_code' => null];
$GLOBALS['receipt_ai_provider'] = static function (string $bytes, string $mime): array {
    $size = getimagesizefromstring($bytes);
    $GLOBALS['calls'][] = ['mime' => $mime, 'width' => $size[0] ?? 0, 'height' => $size[1] ?? 0];
    return $GLOBALS['answer'];
};

function scan(array $body, int $me = 1): array
{
    $GLOBALS['me'] = $me;
    $GLOBALS['body'] = $body;
    try { scan_receipt_action(); } catch (ScanResponse $r) { return ['status' => $r->status, 'payload' => $r->payload]; }
    return ['status' => 0, 'payload' => []];
}
function state(PDO $pdo): array
{
    return [
        'calls' => count($GLOBALS['calls']),
        'scans' => $pdo->query('SELECT status, cost_microusd, reserved_microusd, error_code, input_tokens FROM trip_ai_scans ORDER BY id')->fetchAll(PDO::FETCH_ASSOC),
        'budget' => $pdo->query('SELECT period, spent_microusd, reserved_microusd FROM trip_ai_budget ORDER BY period')->fetchAll(PDO::FETCH_ASSOC),
    ];
}
$ok = ['receipt_path' => 'receipts/u1_receipt.png', 'request_id' => 'req-00000001'];

$scenario = $argv[1] ?? '';
$out = [];
switch ($scenario) {
    case 'success':
        $out['response'] = scan($ok);
        $out['state'] = state($pdo);
        $out['first_call'] = $GLOBALS['calls'][0] ?? null;
        $out['rates'] = $GLOBALS['rates'];
        break;
    case 'gates':
        $pdo->exec("UPDATE trip_feature_flags SET mode = 'off'");
        $out['flag_off'] = scan($ok);
        $pdo->exec("UPDATE trip_feature_flags SET mode = 'allowlist'");
        $out['not_granted'] = scan($ok, 3);
        $out['unverified'] = scan($ok, 2);
        $out['bad_request_id'] = scan(['receipt_path' => 'receipts/u1_receipt.png', 'request_id' => 'x'])['status'];
        $out['not_owner'] = scan(['receipt_path' => 'receipts/u3_receipt.png', 'request_id' => 'req-00000002'])['status'];
        $out['missing_file'] = scan(['receipt_path' => 'receipts/u1_gone.png', 'request_id' => 'req-00000003']);
        $out['state'] = state($pdo);
        break;
    case 'idempotent':
        $out['first'] = scan($ok);
        $out['again'] = scan($ok);
        $out['reused'] = scan(['receipt_path' => 'receipts/u1_other.png', 'request_id' => 'req-00000001']);
        $out['same_image_new_request'] = scan(['receipt_path' => 'receipts/u1_receipt.png', 'request_id' => 'req-00000009']);
        $out['state'] = state($pdo);
        break;
    case 'quota':
        $insert = $pdo->prepare("INSERT INTO trip_ai_scans (user_id, request_id, receipt_path, image_sha256, status, model,
            budget_hour, budget_day, budget_month, created_at) VALUES (1, ?, 'x', 'h', 'done', 'm', 'h', 'd', 'm', ?)");
        for ($i = 0; $i < 20; $i++) { $insert->execute(['old-' . $i, gmdate('Y-m-d H:i:s', time() - 60)]); }
        $out['response'] = scan($ok);
        $out['calls'] = count($GLOBALS['calls']);
        $out['budget'] = state($pdo)['budget'];
        break;
    case 'budget':
        [, $day] = receipt_ai_periods(time());
        $pdo->prepare('INSERT INTO trip_ai_budget (period, spent_microusd) VALUES (?, ?)')->execute([$day, 1_990_000]);
        ini_set('error_log', '/dev/null');
        $out['response'] = scan($ok);
        $out['state'] = state($pdo);
        break;
    case 'in_progress':
        [$h, $d, $m] = receipt_ai_periods(time());
        $pdo->prepare("INSERT INTO trip_ai_scans (user_id, request_id, receipt_path, image_sha256, status, model,
            budget_hour, budget_day, budget_month, created_at) VALUES (1, 'running-1', 'x', 'h', 'sent', 'm', ?, ?, ?, ?)")
            ->execute([$h, $d, $m, gmdate('Y-m-d H:i:s', time() - 10)]);
        $out['response'] = scan($ok);
        $out['calls'] = count($GLOBALS['calls']);
        break;
    case 'provider_fails':
        ini_set('error_log', '/dev/null');
        $GLOBALS['answer'] = ['ok' => false, 'data' => null, 'input_tokens' => null, 'output_tokens' => null, 'error_code' => 'provider_unreachable'];
        $out['no_usage'] = scan($ok);
        $GLOBALS['answer'] = ['ok' => false, 'data' => null, 'input_tokens' => 1000, 'output_tokens' => 0, 'error_code' => 'provider_incomplete'];
        $out['with_usage'] = scan(['receipt_path' => 'receipts/u1_other.png', 'request_id' => 'req-00000002']);
        $out['retry_same_request'] = scan($ok);
        $out['state'] = state($pdo);
        break;
    case 'big_image':
        $out['response'] = scan(['receipt_path' => 'receipts/u1_big.png', 'request_id' => 'req-00000005'])['status'];
        $out['call'] = $GLOBALS['calls'][0] ?? null;
        break;
    case 'not_receipt':
        $GLOBALS['answer']['data'] = ['is_receipt' => false, 'merchant' => 'x', 'date' => null, 'currency' => null,
            'items' => [['name' => 'x', 'quantity' => 1, 'unit_price' => 1, 'total' => 1, 'uncertain' => false]],
            'discounts' => null, 'tax' => null, 'tip' => null, 'service_charge' => null, 'total' => 9, 'notes' => 'A cat.'];
        $out['response'] = scan($ok);
        break;
    case 'validate':
        $now = gmmktime(12, 0, 0, 11, 20, 2026);
        $out['mismatch'] = receipt_ai_validate(['is_receipt' => true, 'merchant' => "Shop\u{0007}\n", 'date' => '2026-02-30',
            'currency' => 'XXX', 'items' => [['name' => str_repeat('a', 120), 'quantity' => -1, 'unit_price' => 1, 'total' => 10.004, 'uncertain' => false],
                ['name' => '   ', 'quantity' => 1, 'unit_price' => 1, 'total' => 1, 'uncertain' => false]],
            'discounts' => 1, 'tax' => 0.21, 'tip' => -5, 'service_charge' => null, 'total' => 12, 'notes' => null], $now);
        $out['future_date'] = receipt_ai_validate(['is_receipt' => true, 'date' => '2027-01-01', 'items' => [], 'total' => 1], $now)['date'];
        $many = array_fill(0, 150, ['name' => 'x', 'quantity' => 1, 'unit_price' => 0.01, 'total' => 0.01, 'uncertain' => false]);
        $out['many_items'] = count(receipt_ai_validate(['is_receipt' => true, 'items' => $many, 'total' => 1.5], $now)['items']);
        $out['huge_amount'] = receipt_ai_validate(['is_receipt' => true, 'items' => [['name' => 'x', 'total' => 1e12]], 'total' => 1e12], $now)['items'];
        $out['cost'] = receipt_ai_cost_microusd(2000, 400);
        $out['schema_required'] = receipt_ai_schema()['required'];
        break;
    default:
        fwrite(STDERR, "Unknown scenario\n");
        exit(1);
}
echo json_encode($out);
