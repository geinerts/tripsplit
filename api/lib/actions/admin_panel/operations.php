<?php
declare(strict_types=1);

// Push queue, incidents, audit log and app events.
// Loaded by ../admin_panel_actions.php; routes are registered in the router.

// ── Push queue ────────────────────────────────────────────────────────────────

function admin_panel_push_queue_action(): void
{
    $sess   = require_admin_role(...admin_roles_ops());
    $pdo    = db();
    $status = trim((string) ($_GET['status'] ?? 'all'));
    $limit  = max(1, min(100, (int) ($_GET['limit']  ?? 50)));
    $offset = max(0,          (int) ($_GET['offset'] ?? 0));

    $queueTable = table_name('push_queue');

    // Health summary
    $stmt  = $pdo->query("SELECT status, COUNT(*) AS cnt, MAX(created_at) AS latest FROM {$queueTable} GROUP BY status");
    $health = [];
    foreach ($stmt->fetchAll() as $row) {
        $health[(string) $row['status']] = ['count' => (int) $row['cnt'], 'latest' => $row['latest']];
    }

    // Filtered rows
    $where  = ($status !== 'all') ? 'WHERE status = ?' : '';
    $params = ($status !== 'all') ? [$status, $limit, $offset] : [$limit, $offset];
    $stmt   = $pdo->prepare("
        SELECT id, user_id, type, title, body, status, attempts, last_error, created_at, sent_at
        FROM {$queueTable}
        {$where}
        ORDER BY created_at DESC
        LIMIT ? OFFSET ?
    ");
    $stmt->execute($params);
    $rows = $stmt->fetchAll();

    json_out(['ok' => true, 'health' => $health, 'rows' => $rows, 'limit' => $limit, 'offset' => $offset]);
}

function admin_panel_push_retry_action(): void
{
    require_post();
    $sess    = require_admin_role(...admin_roles_ops());
    $pdo     = db();
    $body    = read_json();
    $queueId = (int) ($body['queue_id'] ?? 0);

    if ($queueId <= 0) {
        json_out(['ok' => false, 'error' => 'Invalid queue_id.'], 400);
    }

    $queueTable = table_name('push_queue');
    $stmt = $pdo->prepare("SELECT id, status FROM {$queueTable} WHERE id = ? LIMIT 1");
    $stmt->execute([$queueId]);
    $item = $stmt->fetch();
    if (!is_array($item)) {
        json_out(['ok' => false, 'error' => 'Queue item not found.'], 404);
    }
    if ($item['status'] === 'sent') {
        json_out(['ok' => false, 'error' => 'Item already sent.'], 409);
    }

    // Reset attempts so the background worker picks it up again
    $pdo->prepare("UPDATE {$queueTable} SET status = 'pending', attempts = 0, last_error = NULL WHERE id = ?")
        ->execute([$queueId]);

    admin_audit($pdo, $sess, 'push.retry', 'push_queue', $queueId);
    json_out(['ok' => true]);
}

// ── Incidents ─────────────────────────────────────────────────────────────────

function admin_panel_incidents_action(): void
{
    $sess   = require_admin_role(...admin_roles_all());
    $pdo    = db();
    $status = trim((string) ($_GET['status'] ?? 'all'));
    $limit  = max(1, min(100, (int) ($_GET['limit']  ?? 25)));
    $offset = max(0,          (int) ($_GET['offset'] ?? 0));

    $incTable = table_name('admin_incidents');

    $where  = ($status !== 'all') ? 'WHERE status = ?' : '';
    $params = ($status !== 'all') ? [$status, $limit, $offset] : [$limit, $offset];

    $stmt = $pdo->prepare("
        SELECT id, admin_username, title, body, severity, status,
               resolved_at, resolved_by_username, created_at, updated_at
        FROM {$incTable}
        {$where}
        ORDER BY
          FIELD(status,'open','investigating','resolved'),
          FIELD(severity,'critical','high','medium','low'),
          created_at DESC
        LIMIT ? OFFSET ?
    ");
    $stmt->execute($params);
    $incidents = $stmt->fetchAll();

    $cntStmt = $pdo->prepare("SELECT COUNT(*) FROM {$incTable} {$where}");
    $cntStmt->execute(array_slice($params, 0, count($params) - 2));
    $total = (int) $cntStmt->fetchColumn();

    json_out(['ok' => true, 'incidents' => $incidents, 'total' => $total]);
}

function admin_panel_create_incident_action(): void
{
    require_post();
    $sess  = require_admin_role(...admin_roles_ops());
    $pdo   = db();
    $body  = read_json();

    $title    = trim((string) ($body['title']    ?? ''));
    $bodyText = trim((string) ($body['body']     ?? ''));
    $severity = trim((string) ($body['severity'] ?? 'medium'));

    if ($title === '') {
        json_out(['ok' => false, 'error' => 'Title is required.'], 400);
    }
    if (!in_array($severity, ['low', 'medium', 'high', 'critical'], true)) {
        json_out(['ok' => false, 'error' => 'Invalid severity.'], 400);
    }

    $incTable = table_name('admin_incidents');
    $stmt = $pdo->prepare("
        INSERT INTO {$incTable} (admin_user_id, admin_username, title, body, severity)
        VALUES (?, ?, ?, ?, ?)
    ");
    $stmt->execute([
        (int) $sess['admin_user_id'],
        (string) $sess['username'],
        $title,
        $bodyText,
        $severity,
    ]);
    $incidentId = (int) $pdo->lastInsertId();

    admin_audit($pdo, $sess, 'incident.create', 'incident', $incidentId, [
        'title'    => $title,
        'severity' => $severity,
    ]);

    json_out(['ok' => true, 'id' => $incidentId]);
}

function admin_panel_update_incident_action(): void
{
    require_post();
    $sess       = require_admin_role(...admin_roles_ops());
    $pdo        = db();
    $body       = read_json();
    $incidentId = (int) ($body['id']     ?? 0);
    $newStatus  = trim((string) ($body['status'] ?? ''));

    if ($incidentId <= 0) {
        json_out(['ok' => false, 'error' => 'Invalid incident id.'], 400);
    }
    if (!in_array($newStatus, ['open', 'investigating', 'resolved'], true)) {
        json_out(['ok' => false, 'error' => 'Invalid status.'], 400);
    }

    $incTable = table_name('admin_incidents');
    $stmt = $pdo->prepare("SELECT id, status FROM {$incTable} WHERE id = ? LIMIT 1");
    $stmt->execute([$incidentId]);
    $incident = $stmt->fetch();
    if (!is_array($incident)) {
        json_out(['ok' => false, 'error' => 'Incident not found.'], 404);
    }

    $resolvedAt = ($newStatus === 'resolved') ? date('Y-m-d H:i:s') : null;
    $resolvedBy = ($newStatus === 'resolved') ? $sess['username'] : null;

    $pdo->prepare("
        UPDATE {$incTable}
        SET status = ?, resolved_at = ?, resolved_by_username = ?
        WHERE id = ?
    ")->execute([$newStatus, $resolvedAt, $resolvedBy, $incidentId]);

    admin_audit($pdo, $sess, 'incident.update', 'incident', $incidentId, [
        'old_status' => $incident['status'],
        'new_status' => $newStatus,
    ]);

    json_out(['ok' => true]);
}

// ── Audit log ─────────────────────────────────────────────────────────────────

function admin_panel_audit_log_action(): void
{
    $sess         = require_admin_role(...admin_roles_ops());
    $pdo          = db();
    $actionFilter = trim((string) ($_GET['action_filter'] ?? ''));
    $targetFilter = trim((string) ($_GET['target']  ?? ''));
    $limit        = max(1, min(200, (int) ($_GET['limit']  ?? 50)));
    $offset       = max(0,          (int) ($_GET['offset'] ?? 0));

    $logTable = table_name('admin_audit_log');

    $conditions = [];
    $params     = [];

    if ($actionFilter !== '') {
        $conditions[] = 'action LIKE ?';
        $params[]     = '%' . str_replace(['%', '_'], ['\\%', '\\_'], $actionFilter) . '%';
    }
    if ($targetFilter !== '') {
        $conditions[] = 'target_type = ?';
        $params[]     = $targetFilter;
    }

    $where = $conditions ? 'WHERE ' . implode(' AND ', $conditions) : '';

    $stmt = $pdo->prepare("
        SELECT id, admin_username, action, target_type, target_id, details, ip_address, created_at
        FROM {$logTable}
        {$where}
        ORDER BY created_at DESC
        LIMIT ? OFFSET ?
    ");
    $params[] = $limit;
    $params[] = $offset;
    $stmt->execute($params);
    $rows = $stmt->fetchAll();

    // Decode JSON details for response
    foreach ($rows as &$row) {
        if ($row['details'] !== null) {
            $row['details'] = json_decode((string) $row['details'], true);
        }
    }
    unset($row);

    $cntStmt = $pdo->prepare("SELECT COUNT(*) FROM {$logTable} {$where}");
    $cntStmt->execute(array_slice($params, 0, count($params) - 2));
    $total = (int) $cntStmt->fetchColumn();

    json_out(['ok' => true, 'log' => $rows, 'total' => $total, 'limit' => $limit, 'offset' => $offset]);
}

// ── App events feed ───────────────────────────────────────────────────────────

function admin_panel_app_events_action(): void
{
    require_admin_role(...admin_roles_ops());
    $pdo        = db();
    $typeFilter = trim((string) ($_GET['event_type'] ?? ''));
    $limit      = max(1, min(200, (int) ($_GET['limit']  ?? 50)));
    $offset     = max(0,          (int) ($_GET['offset'] ?? 0));

    $eventsTable = table_name('app_events');
    $usersTable  = table_name('users');

    $conditions = [];
    $params     = [];

    if ($typeFilter !== '') {
        $conditions[] = 'e.event_type LIKE ?';
        $params[]     = '%' . str_replace(['%', '_'], ['\\%', '\\_'], $typeFilter) . '%';
    }

    $where = $conditions ? 'WHERE ' . implode(' AND ', $conditions) : '';

    $stmt = $pdo->prepare("
        SELECT e.id, e.user_id, u.nickname AS username, e.event_type, e.entity_type, e.entity_id, e.created_at
        FROM {$eventsTable} e
        LEFT JOIN {$usersTable} u ON u.id = e.user_id
        {$where}
        ORDER BY e.created_at DESC
        LIMIT ? OFFSET ?
    ");
    $params[] = $limit;
    $params[] = $offset;
    $stmt->execute($params);
    $rows = $stmt->fetchAll();

    $cntStmt = $pdo->prepare("SELECT COUNT(*) FROM {$eventsTable} e {$where}");
    $cntStmt->execute(array_slice($params, 0, count($params) - 2));
    $total = (int) $cntStmt->fetchColumn();

    json_out(['ok' => true, 'events' => $rows, 'total' => $total, 'limit' => $limit, 'offset' => $offset]);
}
