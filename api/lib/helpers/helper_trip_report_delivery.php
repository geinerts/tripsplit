<?php
declare(strict_types=1);

const TRIP_REPORT_MAX_ATTEMPTS = 5;
const TRIP_REPORT_RETENTION_DAYS = 30;

function trip_report_queue_available(PDO $pdo): bool
{
    try {
        $pdo->query('SELECT 1 FROM ' . table_name('report_deliveries') . ' LIMIT 1');
        return true;
    } catch (PDOException $error) {
        return false;
    }
}

/** Queue one report per member. Runs inside end_trip's transaction, and never fails it. */
function trip_report_enqueue(PDO $pdo, int $tripId, array $memberIds, ?int $now = null): void
{
    if (!trip_report_queue_available($pdo)) {
        return;
    }
    $stamp = gmdate('Y-m-d H:i:s', $now ?? time());
    $table = table_name('report_deliveries');
    $exists = $pdo->prepare('SELECT 1 FROM ' . $table . ' WHERE trip_id = :trip AND user_id = :user');
    $insert = $pdo->prepare('INSERT INTO ' . $table . ' (trip_id, user_id, status, attempts, next_attempt_at, created_at)'
        . ' VALUES (:trip, :user, "pending", 0, :due, :created)');
    foreach ($memberIds as $userId) {
        $exists->execute(['trip' => $tripId, 'user' => (int) $userId]);
        if ($exists->fetchColumn()) {
            continue;
        }
        $insert->execute(['trip' => $tripId, 'user' => (int) $userId, 'due' => $stamp, 'created' => $stamp]);
    }
}

function trip_report_email_eligible(PDO $pdo, array $user): bool
{
    $email = trim((string) ($user['email'] ?? ''));
    if ($email === '' || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
        return false;
    }
    if ((string) ($user['account_status'] ?? '') !== 'active' || empty($user['email_verified_at'])) {
        return false;
    }
    $prefs = load_user_notification_preferences($pdo, (int) $user['id']);
    return ($prefs['email_trip_report_enabled'] ?? true) === true;
}

function build_trip_report_email(array $report, array $s, string $locale, string $firstName): string
{
    $e = 'email_template_escape';
    $title = $e(trip_report_text($s, 'email_title'));
    $greeting = $e(trip_report_text($s, 'email_greeting', $firstName));
    $body = $e(trip_report_text($s, 'email_body', $report['name']));
    $optOut = $e(trip_report_text($s, 'email_opt_out'));
    $footer = $e(trip_report_text($s, 'footer'));
    $logo = build_email_brand_logo_html();
    $lang = $e($locale);

    $rows = [[trip_report_text($s, 'total_spent'), trip_report_money($report['total_cents'], $report['currency'])]];
    $viewer = trip_report_viewer($report);
    if (!$report['is_solo'] && $viewer !== null) {
        $rows[] = [trip_report_text($s, 'you_paid'), trip_report_money($viewer['paid_cents'], $report['currency'])];
        $rows[] = [trip_report_text($s, 'your_share'), trip_report_money($viewer['owed_cents'], $report['currency'])];
        $rows[] = [trip_report_text($s, 'your_balance'), trip_report_money($viewer['net_cents'], $report['currency'], true)];
    }
    $summary = '';
    foreach ($rows as $row) {
        $summary .= '<tr><td class="t-body" style="padding:9px 0;border-bottom:1px solid #E7EEEB;font-size:14px;color:#53626B;">'
            . $e($row[0]) . '</td><td class="t-strong" align="right" style="padding:9px 0;border-bottom:1px solid #E7EEEB;font-size:14px;font-weight:bold;color:#193149;white-space:nowrap;">'
            . $e($row[1]) . '</td></tr>';
    }

    return <<<HTML
<!DOCTYPE html>
<html lang="{$lang}">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="color-scheme" content="light dark">
  <title>{$title}</title>
  <style>
    @media (prefers-color-scheme: dark) {
      body, .bg-page { background-color:#0F1A22 !important; }
      .card { background-color:#17232E !important; border-color:#26394A !important; }
      .t-strong { color:#FFFFFF !important; }
      .t-body { color:#C3D0D6 !important; }
      .t-muted { color:#8FA3AD !important; }
    }
  </style>
</head>
<body class="bg-page" style="margin:0;padding:0;background-color:#F2F6F5;font-family:Arial,Helvetica,sans-serif;color:#193149;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" bgcolor="#F2F6F5" class="bg-page">
    <tr><td align="center" style="padding:32px 12px;">
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="width:100%;max-width:560px;">
        <tr><td class="card" bgcolor="#FFFFFF" style="background-color:#FFFFFF;border:1px solid #DFE8E5;border-radius:20px;overflow:hidden;">
          <table role="presentation" width="100%" cellpadding="0" cellspacing="0">
            <tr><td bgcolor="#15222E" style="padding:28px 32px 24px;background-color:#15222E;background-image:linear-gradient(#15222E,#15222E);">{$logo}</td></tr>
            <tr><td height="3" bgcolor="#008576" style="height:3px;font-size:0;line-height:0;background-color:#008576;background-image:linear-gradient(#008576,#008576);">&nbsp;</td></tr>
            <tr><td style="padding:30px 32px;">
              <h1 class="t-strong" style="margin:0 0 20px;font-size:26px;line-height:32px;color:#193149;">{$title}</h1>
              <p class="t-strong" style="margin:0 0 8px;font-size:15px;line-height:24px;font-weight:bold;color:#193149;">{$greeting}</p>
              <p class="t-body" style="margin:0 0 20px;font-size:15px;line-height:24px;color:#53626B;">{$body}</p>
              <table role="presentation" width="100%" cellpadding="0" cellspacing="0">{$summary}</table>
              <p class="t-muted" style="margin:22px 0 0;font-size:12px;line-height:19px;color:#68777D;">{$optOut}</p>
            </td></tr>
          </table>
        </td></tr>
        <tr><td align="center" style="padding:20px 12px 0;"><p class="t-muted" style="margin:0;font-size:12px;line-height:20px;color:#68777D;">{$footer}</p></td></tr>
      </table>
    </td></tr>
  </table>
</body>
</html>
HTML;
}

function trip_report_finish_delivery(PDO $pdo, int $id, string $status, string $stamp): void
{
    $pdo->prepare('UPDATE ' . table_name('report_deliveries') . ' SET status = :status, finished_at = :finished WHERE id = :id')
        ->execute(['status' => $status, 'finished' => $stamp, 'id' => $id]);
}

/**
 * Sends due reports. $send(to, subject, html, attachments) and $renderPdf(html) are injected so
 * tests never reach the email provider. Log lines hold ids only, never addresses or amounts.
 */
function process_trip_report_deliveries(PDO $pdo, callable $send, callable $renderPdf, int $limit = 20, ?int $now = null): array
{
    $now ??= time();
    $stamp = gmdate('Y-m-d H:i:s', $now);
    $result = ['picked' => 0, 'sent' => 0, 'skipped' => 0, 'retried' => 0, 'failed' => 0];
    if (!trip_report_queue_available($pdo)) {
        return $result;
    }
    $table = table_name('report_deliveries');
    $due = $pdo->prepare('SELECT id, trip_id, user_id, attempts FROM ' . $table
        . ' WHERE status = "pending" AND next_attempt_at <= :now ORDER BY next_attempt_at ASC, id ASC LIMIT ' . max(1, $limit));
    $due->execute(['now' => $stamp]);
    $userStmt = $pdo->prepare('SELECT * FROM ' . table_name('users') . ' WHERE id = :id');
    $memberStmt = $pdo->prepare('SELECT 1 FROM ' . table_name('trip_members') . ' WHERE trip_id = :trip AND user_id = :user');

    foreach ($due->fetchAll() as $row) {
        $result['picked']++;
        $id = (int) $row['id'];
        $tripId = (int) $row['trip_id'];
        $userId = (int) $row['user_id'];
        try {
            $userStmt->execute(['id' => $userId]);
            $user = $userStmt->fetch();
            $memberStmt->execute(['trip' => $tripId, 'user' => $userId]);
            $report = is_array($user) && $memberStmt->fetchColumn() && trip_report_email_eligible($pdo, $user)
                ? trip_report_load($pdo, $tripId, $userId)
                : null;
            if ($report === null || $report['expense_count'] === 0) {
                trip_report_finish_delivery($pdo, $id, 'skipped', $stamp);
                $result['skipped']++;
                continue;
            }
            $locale = trip_report_user_locale($pdo, $userId);
            $s = trip_report_strings($locale);
            $pdf = $renderPdf(trip_report_html($report, $s, $locale, false));
            $firstName = trim((string) ($user['first_name'] ?? '')) ?: trim((string) ($user['nickname'] ?? ''));
            $sent = $send(
                trim((string) $user['email']),
                trip_report_text($s, 'email_subject', $report['name']),
                build_trip_report_email($report, $s, $locale, $firstName),
                [['filename' => trip_report_file_name($report['name'], 'pdf', $report['ended_at']), 'content' => base64_encode($pdf)]]
            );
            if ($sent !== true) {
                throw new RuntimeException('Email provider rejected the report.');
            }
            trip_report_finish_delivery($pdo, $id, 'sent', $stamp);
            $result['sent']++;
        } catch (Throwable $error) {
            $attempts = (int) $row['attempts'] + 1;
            error_log('[trip-report] delivery ' . $id . ' attempt ' . $attempts . ' failed: ' . get_class($error));
            if ($attempts >= TRIP_REPORT_MAX_ATTEMPTS) {
                $pdo->prepare('UPDATE ' . $table . ' SET attempts = :attempts, status = "failed", finished_at = :finished WHERE id = :id')
                    ->execute(['attempts' => $attempts, 'finished' => $stamp, 'id' => $id]);
                $result['failed']++;
            } else {
                $next = gmdate('Y-m-d H:i:s', $now + 300 * (2 ** ($attempts - 1)));
                $pdo->prepare('UPDATE ' . $table . ' SET attempts = :attempts, next_attempt_at = :next WHERE id = :id')
                    ->execute(['attempts' => $attempts, 'next' => $next, 'id' => $id]);
                $result['retried']++;
            }
        }
    }

    $pdo->prepare('DELETE FROM ' . $table . ' WHERE finished_at IS NOT NULL AND finished_at < :cutoff')
        ->execute(['cutoff' => gmdate('Y-m-d H:i:s', $now - TRIP_REPORT_RETENTION_DAYS * 86400)]);
    return $result;
}
