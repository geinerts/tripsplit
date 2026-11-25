<?php
declare(strict_types=1);

// Dashboard, system health and security overview.
// Loaded by ../admin_panel_actions.php; routes are registered in the router.

// ── Dashboard ─────────────────────────────────────────────────────────────────

function admin_panel_dashboard_action(): void
{
    $sess = require_admin_role(...admin_roles_all());
    $pdo  = db();

    $users   = table_name('users');
    $trips   = table_name('trips');
    $exp     = table_name('expenses');
    $settle  = table_name('settlements');
    $push    = table_name('push_queue');
    $inc     = table_name('admin_incidents');

    $stats = [];

    // User counts
    $stmt = $pdo->query("SELECT COUNT(*) FROM {$users} WHERE guest_trip_id IS NULL");
    $stats['total_users'] = (int) $stmt->fetchColumn();

    $stmt = $pdo->query("SELECT COUNT(*) FROM {$users} WHERE account_status = 'active' AND guest_trip_id IS NULL");
    $stats['active_users'] = (int) $stmt->fetchColumn();

    $stmt = $pdo->query("SELECT COUNT(*) FROM {$users} WHERE created_at >= DATE_SUB(UTC_TIMESTAMP(), INTERVAL 7 DAY)");
    $stats['new_users_7d'] = (int) $stmt->fetchColumn();

    // Trip / expense counts
    $stmt = $pdo->query("SELECT COUNT(*) FROM {$trips}");
    $stats['total_trips'] = (int) $stmt->fetchColumn();

    $stmt = $pdo->query("SELECT COUNT(*) FROM {$exp}");
    $stats['total_expenses'] = (int) $stmt->fetchColumn();

    // Push queue health
    $stmt = $pdo->query("SELECT status, COUNT(*) AS cnt FROM {$push} GROUP BY status");
    $pushRows = $stmt->fetchAll();
    $pushStats = [];
    foreach ($pushRows as $r) {
        $pushStats[(string) $r['status']] = (int) $r['cnt'];
    }
    $stats['push_queue'] = $pushStats;

    // Open incidents
    $stmt = $pdo->query("SELECT COUNT(*) FROM {$inc} WHERE status != 'resolved'");
    $stats['open_incidents'] = (int) $stmt->fetchColumn();

    // Recent open incidents
    $stmt = $pdo->query("
        SELECT id, title, severity, status, created_at, admin_username
        FROM {$inc}
        WHERE status != 'resolved'
        ORDER BY
          FIELD(severity,'critical','high','medium','low'),
          created_at DESC
        LIMIT 5
    ");
    $stats['recent_incidents'] = $stmt->fetchAll();

    $stats['account_deletion_feedback'] = account_deletion_feedback_summary($pdo);
    $stats['feature_usage'] = feature_usage_summary($pdo);
    $stats['growth'] = admin_growth_series($pdo, gmdate('Y-m-d'));

    json_out(['ok' => true, 'stats' => $stats]);
}

/**
 * Daily counts for the last $days days, ending with $today (UTC, Y-m-d):
 * sign-ups (guests excluded), active users (anyone with an app event that day)
 * and new trips. Days without data are zero.
 */
function admin_growth_series(PDO $pdo, string $today, int $days = 30): array
{
    $end = new DateTimeImmutable($today . ' 00:00:00', new DateTimeZone('UTC'));
    $start = $end->modify('-' . ($days - 1) . ' days');
    $from = $start->format('Y-m-d H:i:s');
    $series = [];
    for ($day = $start; $day <= $end; $day = $day->modify('+1 day')) {
        $series[$day->format('Y-m-d')] = ['date' => $day->format('Y-m-d'), 'signups' => 0, 'active' => 0, 'trips' => 0];
    }
    $queries = [
        'signups' => 'SELECT DATE(created_at) AS d, COUNT(*) AS n FROM ' . table_name('users')
            . ' WHERE created_at >= ? AND guest_trip_id IS NULL GROUP BY DATE(created_at)',
        'active' => 'SELECT DATE(created_at) AS d, COUNT(DISTINCT user_id) AS n FROM ' . table_name('app_events')
            . ' WHERE created_at >= ? AND user_id IS NOT NULL GROUP BY DATE(created_at)',
        'trips' => 'SELECT DATE(created_at) AS d, COUNT(*) AS n FROM ' . table_name('trips')
            . ' WHERE created_at >= ? GROUP BY DATE(created_at)',
    ];
    foreach ($queries as $key => $sql) {
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$from]);
        foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
            $date = substr((string) $row['d'], 0, 10);
            if (isset($series[$date])) {
                $series[$date][$key] = (int) $row['n'];
            }
        }
    }
    return array_values($series);
}

// ── System health ────────────────────────────────────────────────────────────

function admin_panel_system_health_action(): void
{
    require_admin_role(...admin_roles_ops());
    $pdo = db();
    $now = time();
    json_out(['ok' => true, 'jobs' => ops_status_read($now),
        'system' => ops_system_snapshot($pdo, dirname(__DIR__, 3)),
        // Tables that hold security limits; a missing one makes those actions answer 503.
        'limits' => security_limit_storage_status($pdo),
        'push' => admin_push_queue_health($pdo, gmdate('Y-m-d H:i:s', $now))]);
}

/** Backlog and recent failures of the push queue. */
function admin_push_queue_health(PDO $pdo, string $now): array
{
    $queue = table_name('push_queue');
    $stmt = $pdo->prepare("SELECT
            SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) AS pending,
            MIN(CASE WHEN status = 'pending' THEN created_at END) AS oldest_pending_at,
            SUM(CASE WHEN status IN ('failed', 'dead') AND updated_at >= ? THEN 1 ELSE 0 END) AS failed_24h,
            MAX(sent_at) AS last_sent_at
        FROM {$queue}");
    $stmt->execute([(new DateTimeImmutable($now . ' UTC'))->modify('-1 day')->format('Y-m-d H:i:s')]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC) ?: [];
    return ['pending' => (int) ($row['pending'] ?? 0), 'oldest_pending_at' => $row['oldest_pending_at'] ?? null,
        'failed_24h' => (int) ($row['failed_24h'] ?? 0), 'last_sent_at' => $row['last_sent_at'] ?? null];
}

// ── Security overview ────────────────────────────────────────────────────────

function admin_panel_security_overview_action(): void
{
    require_admin_role('superadmin', 'admin');
    json_out(['ok' => true] + admin_security_overview(db(), time()));
}

/**
 * Admin sign-in, 2FA and session events from the audit log, plus rate-limit
 * pressure per scope in the last 24 hours (subjects stay hashed).
 */
function admin_security_overview(PDO $pdo, int $now): array
{
    $since = gmdate('Y-m-d H:i:s', $now - 7 * 86400);
    $stmt = $pdo->prepare("SELECT admin_username, action, ip_address, created_at FROM " . table_name('admin_audit_log') . "
        WHERE created_at >= ? AND (action LIKE 'admin.auth.%' OR action LIKE 'admin.totp.%'
            OR action LIKE 'admin_user.%' OR action LIKE 'admin.session.%' OR action = 'user.sessions.revoke_all')
        ORDER BY created_at DESC, id DESC LIMIT 100");
    $stmt->execute([$since]);
    $events = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $counts = ['failed_logins' => 0, 'failed_2fa' => 0, 'locked' => 0, 'successful_logins' => 0];
    foreach ($events as $event) {
        $action = (string) $event['action'];
        if (str_starts_with($action, 'admin.auth.login_failed')) $counts['failed_logins']++;
        elseif ($action === 'admin.auth.2fa_failed') $counts['failed_2fa']++;
        elseif ($action === 'admin.auth.login_blocked_locked') $counts['locked']++;
        elseif ($action === 'admin.auth.2fa_success') $counts['successful_logins']++;
    }

    $limits = $pdo->prepare('SELECT scope, COUNT(*) AS windows, SUM(hits) AS requests, MAX(hits) AS peak
        FROM ' . table_name('request_limits') . ' WHERE window_start >= ? GROUP BY scope ORDER BY peak DESC, scope LIMIT 30');
    $limits->execute([$now - 86400]);
    $rateLimits = array_map(static fn(array $row): array => ['scope' => (string) $row['scope'],
        'windows' => (int) $row['windows'], 'requests' => (int) $row['requests'], 'peak' => (int) $row['peak']],
        $limits->fetchAll(PDO::FETCH_ASSOC));

    $sessions = $pdo->prepare('SELECT COUNT(*) FROM ' . table_name('admin_sessions') . ' WHERE expires_at > ?');
    $sessions->execute([gmdate('Y-m-d H:i:s', $now)]);

    return ['counts_7d' => $counts, 'events' => $events, 'rate_limits_24h' => $rateLimits,
        'active_admin_sessions' => (int) $sessions->fetchColumn()];
}
