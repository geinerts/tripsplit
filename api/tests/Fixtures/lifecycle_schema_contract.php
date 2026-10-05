<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
define('DB_TABLE_PREFIX', 'synthetic_');
require __DIR__ . '/../../config/config_db.php';
require __DIR__ . '/../../lib/actions/account_deactivation_actions.php';
require __DIR__ . '/../../lib/actions/password_reset_actions.php';
require __DIR__ . '/../../lib/helpers/helper_account_action_proofs.php';

final class SchemaStatement extends PDOStatement
{
    private array $params = [];
    public function __construct(private string $expected, private bool $available) {}
    public function execute(?array $params = null): bool { $this->params = $params ?? []; return true; }
    public function fetchColumn(int $column = 0): mixed
    { return (int) ($this->available && ($this->params['table_name'] ?? '') === $this->expected); }
}
final class SchemaDatabase extends PDO
{
    public function __construct(private string $expected, private bool $available) {}
    public function prepare(string $query, array $options = []): PDOStatement|false
    {
        if (!str_contains($query, 'information_schema.columns')) throw new RuntimeException('Unexpected query');
        return new SchemaStatement($this->expected, $this->available);
    }
}
function users_deactivated_at_column_available(PDO $pdo): bool { return true; }
function users_account_status_column_available(PDO $pdo): bool { return true; }
function users_email_verified_at_column_available(PDO $pdo): bool { return true; }
function users_deleted_at_column_available(PDO $pdo): bool { return true; }
function json_out(array $body, int $status = 200): void { throw new RuntimeException('Response', $status); }

$lifecycle = ($argv[1] ?? '') === 'lifecycle';
$deactivate = ($argv[1] ?? '') === 'deactivation' || $lifecycle;
$db = new SchemaDatabase($deactivate ? 'synthetic_account_action_tokens' : 'synthetic_password_resets', ($argv[2] ?? '') === 'available');
try {
    if ($lifecycle) ensure_account_action_proof_schema($db);
    elseif ($deactivate) ensure_deactivation_link_schema($db);
    else ensure_password_reset_security_schema($db);
    echo '200';
} catch (RuntimeException $e) { echo (string) $e->getCode(); }
