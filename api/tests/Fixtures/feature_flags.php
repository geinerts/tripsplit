<?php
declare(strict_types=1);
// Runs one feature-flag scenario in its own process (static caches) and prints JSON.
// SQLite checks handler behavior; MySQL row locks are not exercised here.
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }

final class FlagResponse extends RuntimeException
{
    public function __construct(public array $payload, public int $status) { parent::__construct('response'); }
}
function json_out(array $payload, int $status = 200): void { throw new FlagResponse($payload, $status); }
function table_name(string $key): string { return 'trip_' . $key; }
function db(): PDO { return $GLOBALS['pdo']; }
function require_post(): void {}
function read_json(): array { return $GLOBALS['body']; }
function users_account_status_select_sql(PDO $pdo, string $alias = ''): string
{
    return ($alias !== '' ? $alias . '.' : '') . 'account_status, ';
}
function user_account_status(array $user): string { return (string) ($user['account_status'] ?? 'active'); }
function require_admin_role(string ...$roles): array
{
    if (!in_array($GLOBALS['role'], $roles, true)) {
        json_out(['ok' => false, 'error' => 'Insufficient permissions.', 'code' => 'forbidden'], 403);
    }
    return ['admin_user_id' => 1, 'username' => 'owner', 'role' => $GLOBALS['role']];
}
function admin_audit(PDO $pdo, array $sess, string $action, ?string $type = null, ?int $id = null,
    ?array $details = null, bool $strict = false): void
{
    if ($GLOBALS['auditFails']) { throw new RuntimeException('audit down'); }
    $pdo->prepare('INSERT INTO trip_admin_audit_log (action, target_id, details) VALUES (?, ?, ?)')
        ->execute([$action, $id, json_encode($details)]);
}

require __DIR__ . '/../../lib/actions/feature_flags_actions.php';

$scenario = $argv[1] ?? '';
final class FlagSQLite extends PDO
{
    public function prepare(string $query, array $options = []): PDOStatement|false
    {
        $query = str_replace([' FOR UPDATE', 'INSERT IGNORE INTO'], ['', 'INSERT OR IGNORE INTO'], $query);
        $query = preg_replace('/ON DUPLICATE KEY UPDATE.*$/s', 'ON CONFLICT(flag_key) DO UPDATE SET mode = excluded.mode,'
            . ' updated_by_admin_id = excluded.updated_by_admin_id, updated_at = CURRENT_TIMESTAMP', $query);
        return parent::prepare($query, $options);
    }
}
$pdo = new FlagSQLite('sqlite::memory:', null, null, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
$GLOBALS['pdo'] = $pdo;
$GLOBALS['role'] = 'superadmin';
$GLOBALS['auditFails'] = false;
$GLOBALS['body'] = [];
$pdo->exec('CREATE TABLE trip_users (id INTEGER PRIMARY KEY, nickname TEXT, email TEXT,
    account_status TEXT DEFAULT \'active\', guest_trip_id INT NULL)');
$pdo->exec("INSERT INTO trip_users (id, nickname, email, account_status, guest_trip_id) VALUES
    (1, 'Owner', 'owner@example.invalid', 'active', NULL), (2, 'Other', NULL, 'active', NULL),
    (3, 'Guest', NULL, 'active', 9), (4, 'Gone', NULL, 'deleted', NULL), (5, 'Paused', NULL, 'deactivated', NULL)");
$pdo->exec('CREATE TABLE trip_admin_users (id INTEGER PRIMARY KEY, username TEXT)');
$pdo->exec("INSERT INTO trip_admin_users VALUES (1, 'owner')");
$pdo->exec('CREATE TABLE trip_admin_audit_log (id INTEGER PRIMARY KEY AUTOINCREMENT, action TEXT, target_id INT, details TEXT)');
if ($scenario !== 'missing_tables') {
    // Same shape as sql/migrations/2026-11-20-feature-flags.sql, in SQLite types.
    $pdo->exec("CREATE TABLE trip_feature_flags (flag_key TEXT PRIMARY KEY, mode TEXT NOT NULL DEFAULT 'off',
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP, updated_by_admin_id INT NULL)");
    $pdo->exec('CREATE TABLE trip_user_features (user_id INT NOT NULL, flag_key TEXT NOT NULL,
        granted_at TEXT DEFAULT CURRENT_TIMESTAMP, granted_by_admin_id INT NULL, PRIMARY KEY (user_id, flag_key))');
    $pdo->exec("INSERT INTO trip_feature_flags (flag_key, mode) VALUES ('receipt_ai', 'off')");
}

function call(string $action, array $body = []): array
{
    $GLOBALS['body'] = $body;
    try { $action(); } catch (FlagResponse $r) { return ['status' => $r->status, 'payload' => $r->payload]; }
    return ['status' => 0, 'payload' => []];
}
function effective(PDO $pdo): array
{
    $out = [];
    foreach ([1, 2, 3, 4, 5] as $id) { $out[$id] = feature_flags_for_user($pdo, $id)['receipt_ai']; }
    return $out;
}
function setMode(PDO $pdo, string $mode): void { $pdo->exec("UPDATE trip_feature_flags SET mode = '$mode'"); }
function grant(PDO $pdo, int $id): void { $pdo->exec("INSERT INTO trip_user_features (user_id, flag_key) VALUES ($id, 'receipt_ai')"); }
function auditActions(PDO $pdo): array
{
    return $pdo->query('SELECT action FROM trip_admin_audit_log ORDER BY id')->fetchAll(PDO::FETCH_COLUMN);
}

$out = [];
switch ($scenario) {
    case 'modes':
        foreach ([1, 3, 4, 5] as $id) { grant($pdo, $id); }
        $out['off'] = effective($pdo);
        setMode($pdo, 'allowlist');
        $out['allowlist'] = effective($pdo);
        setMode($pdo, 'everyone');
        $out['everyone'] = effective($pdo);
        $out['payload_keys'] = array_keys(feature_flags_for_user($pdo, 1));
        $out['unknown_key'] = feature_enabled_for_user($pdo, 1, 'not_a_flag');
        break;
    case 'year_summary':
        // Its season (January–March) applies, except to accounts with a grant.
        $outside = strtotime('2026-11-28T12:00:00Z');
        $inside = strtotime('2027-01-15T12:00:00Z');
        $pdo->exec("INSERT INTO trip_feature_flags (flag_key, mode) VALUES ('year_summary', 'everyone')");
        $pdo->exec("INSERT INTO trip_user_features (user_id, flag_key) VALUES (1, 'year_summary')");
        $at = static fn(int $now): array => [
            1 => feature_flags_for_user($pdo, 1, $now)['year_summary'],
            2 => feature_flags_for_user($pdo, 2, $now)['year_summary'],
        ];
        $out['everyone_outside'] = $at($outside);
        $out['everyone_inside'] = $at($inside);
        $pdo->exec("UPDATE trip_feature_flags SET mode = 'allowlist' WHERE flag_key = 'year_summary'");
        $out['allowlist_outside'] = $at($outside);
        $out['allowlist_inside'] = $at($inside);
        $pdo->exec("UPDATE trip_feature_flags SET mode = 'off' WHERE flag_key = 'year_summary'");
        $out['off_inside'] = $at($inside);
        $out['receipt_untouched'] = feature_flags_for_user($pdo, 1, $outside)['receipt_ai'];
        break;
    case 'missing_tables':
        $out['flags'] = feature_flags_for_user($pdo, 1);
        $out['list'] = call('admin_panel_features_action')['status'];
        break;
    case 'set_mode':
        $GLOBALS['role'] = 'admin';
        $out['admin_forbidden'] = call('admin_panel_feature_set_mode_action', ['key' => 'receipt_ai', 'mode' => 'everyone', 'reason' => 'x'])['status'];
        $GLOBALS['role'] = 'superadmin';
        $out['no_reason'] = call('admin_panel_feature_set_mode_action', ['key' => 'receipt_ai', 'mode' => 'allowlist'])['status'];
        $out['bad_key'] = call('admin_panel_feature_set_mode_action', ['key' => 'nope', 'mode' => 'allowlist', 'reason' => 'x'])['status'];
        $out['bad_mode'] = call('admin_panel_feature_set_mode_action', ['key' => 'receipt_ai', 'mode' => 'on', 'reason' => 'x'])['status'];
        $out['ok'] = call('admin_panel_feature_set_mode_action', ['key' => 'receipt_ai', 'mode' => 'allowlist', 'reason' => 'start test']);
        $GLOBALS['auditFails'] = true;
        try {
            call('admin_panel_feature_set_mode_action', ['key' => 'receipt_ai', 'mode' => 'everyone', 'reason' => 'x']);
            $out['audit_failure_threw'] = false;
        } catch (RuntimeException $e) {
            $out['audit_failure_threw'] = true;
        }
        $out['mode_after_audit_failure'] = $pdo->query("SELECT mode FROM trip_feature_flags")->fetchColumn();
        $out['open_transaction'] = $pdo->inTransaction();
        $out['audit'] = $pdo->query('SELECT action, details FROM trip_admin_audit_log')->fetchAll(PDO::FETCH_ASSOC);
        break;
    case 'grants':
        setMode($pdo, 'allowlist');
        $out['unknown_user'] = call('admin_panel_user_feature_set_action', ['user_id' => 99, 'key' => 'receipt_ai', 'enabled' => true, 'reason' => 'x'])['status'];
        $out['guest'] = call('admin_panel_user_feature_set_action', ['user_id' => 3, 'key' => 'receipt_ai', 'enabled' => true, 'reason' => 'x'])['status'];
        $out['deleted'] = call('admin_panel_user_feature_set_action', ['user_id' => 4, 'key' => 'receipt_ai', 'enabled' => true, 'reason' => 'x'])['status'];
        $out['not_bool'] = call('admin_panel_user_feature_set_action', ['user_id' => 1, 'key' => 'receipt_ai', 'enabled' => 'yes', 'reason' => 'x'])['status'];
        $out['grant'] = call('admin_panel_user_feature_set_action', ['user_id' => 1, 'key' => 'receipt_ai', 'enabled' => true, 'reason' => 'owner tests']);
        $out['effective_after_grant'] = effective($pdo);
        $out['list'] = call('admin_panel_features_action')['payload'];
        $out['detail'] = admin_user_features($pdo, 1);
        $out['revoke'] = call('admin_panel_user_feature_set_action', ['user_id' => 1, 'key' => 'receipt_ai', 'enabled' => false, 'reason' => 'done']);
        $out['effective_after_revoke'] = effective($pdo);
        $out['audit'] = auditActions($pdo);
        delete_user_feature_grants($pdo, 1);
        break;
    case 'deletion':
        grant($pdo, 1);
        delete_user_feature_grants($pdo, 1);
        $out['rows'] = (int) $pdo->query('SELECT COUNT(*) FROM trip_user_features')->fetchColumn();
        break;
    default:
        fwrite(STDERR, "Unknown scenario\n");
        exit(1);
}
echo json_encode($out);
