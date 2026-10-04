<?php
declare(strict_types=1);

require_once __DIR__ . '/../helpers/helper_premium.php';

function admin_panel_premium_mutate_action(): void
{
    require_post();
    $session = require_admin_role('superadmin');
    $csrf = (string) ($_SERVER['HTTP_X_PREMIUM_CSRF'] ?? '');
    try {
        premium_assert_write($session, $csrf);
    } catch (DomainException $error) {
        json_out(['ok' => false, 'error' => 'Verified 2FA and a current session are required.'], 403);
    }
    try {
        $result = premium_mutate(db(), $session, $csrf, read_json());
    } catch (InvalidArgumentException $error) {
        json_out(['ok' => false, 'error' => $error->getMessage()], 400);
    } catch (DomainException $error) {
        json_out(['ok' => false, 'error' => $error->getMessage()], 409);
    } catch (Throwable $error) {
        error_log('Premium mutation failed: ' . get_class($error));
        json_out(['ok' => false, 'error' => 'Change was not saved. Check for a duplicate partner name or reload and retry.'], 503);
    }
    json_out(['ok' => true] + $result);
}

function admin_panel_premium_list_action(): void
{
    $session = require_admin_role('superadmin', 'admin');
    try {
        $result = premium_admin_list(db(), $_GET);
    } catch (PDOException $error) {
        json_out(['ok' => false, 'error' => 'Premium administration is unavailable. Database migration may be required.'], 503);
    } catch (InvalidArgumentException $error) {
        json_out(['ok' => false, 'error' => $error->getMessage()], 400);
    }
    json_out(['ok' => true] + $result + ['can_manage' => premium_can_manage($session),
        'csrf_token' => premium_can_manage($session) ? premium_csrf_token($session) : null]);
}

function premium_admin_list(PDO $pdo, array $filters): array
{
    $partners = table_name('premium_partners');
    $grants = table_name('premium_grants');
    $users = table_name('users');
    $kind = ($filters['kind'] ?? '') === 'partners' ? 'partners' : 'grants';
    $offset = max(0, min(100000, (int) ($filters['offset'] ?? 0)));
    $search = mb_substr(trim((string) ($filters['q'] ?? '')), 0, 120);
    $stamp = gmdate('Y-m-d H:i:s');
    $params = [];
    if ($kind === 'partners') {
        $where = 'p.name LIKE ?';
        $params[] = '%' . $search . '%';
        $from = "$partners p";
        $columns = "p.id, p.name, p.created_at, (SELECT COUNT(*) FROM $grants g JOIN $users u ON u.id=g.user_id"
            . " WHERE g.partner_id=p.id AND u.account_status='active' AND g.revoked_at IS NULL AND g.starts_at <= '$stamp' AND g.ends_at > '$stamp') AS active_grants";
        $order = 'p.name, p.id';
    } else {
        $from = "$grants g JOIN $users u ON u.id=g.user_id LEFT JOIN $partners p ON p.id=g.partner_id";
        $columns = 'g.id, g.user_id, g.partner_id, g.source, g.starts_at, g.ends_at, g.revoked_at, g.version, u.nickname, u.account_status, p.name AS partner_name';
        $where = '(u.nickname LIKE ? OR u.email LIKE ? OR p.name LIKE ?)';
        $params = array_fill(0, 3, '%' . $search . '%');
        $filter = $filters['status'] ?? 'active';
        if ($filter === 'active' || $filter === 'expiring') {
            $where .= " AND u.account_status='active' AND g.revoked_at IS NULL AND g.starts_at <= ? AND g.ends_at > ?";
            array_push($params, $stamp, $stamp);
            if ($filter === 'expiring') {
                $where .= ' AND g.ends_at <= ?';
                $params[] = gmdate('Y-m-d H:i:s', time() + 14 * 86400);
            }
        } elseif ($filter === 'expired') {
            $where .= ' AND g.revoked_at IS NULL AND g.ends_at <= ?';
            $params[] = $stamp;
        } elseif ($filter === 'revoked') {
            $where .= ' AND g.revoked_at IS NOT NULL';
        } elseif ($filter !== 'all') {
            throw new InvalidArgumentException('Invalid status.');
        }
        if ((int) ($filters['partner_id'] ?? 0) > 0) {
            $where .= ' AND g.partner_id = ?';
            $params[] = (int) $filters['partner_id'];
        }
        $order = 'g.ends_at, g.id';
    }
    $query = $pdo->prepare("SELECT $columns FROM $from WHERE $where ORDER BY $order LIMIT 41 OFFSET $offset");
    $query->execute($params);
    $rows = $query->fetchAll(PDO::FETCH_ASSOC);
    return ['rows' => array_slice($rows, 0, 40), 'has_more' => count($rows) > 40];
}
