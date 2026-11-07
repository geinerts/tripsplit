<?php
declare(strict_types=1);

require_once __DIR__ . '/../helpers/helper_analytics_summary.php';
require_once __DIR__ . '/../helpers/helper_feature_usage.php';

function analytics_summary_action(): void
{
    $me = get_me();
    $pdo = db();
    $userId = (int) $me['id'];
    enforce_rate_limit($pdo, 'analytics_summary_user', (string) $userId, 120, 900);

    try {
        $trips = analytics_summary_build($pdo, $userId);
    } catch (AnalyticsIncompleteException $error) {
        json_out(['ok' => false, 'code' => 'analytics_incomplete', 'error' => 'Analytics could not be calculated.'], 500);
    }
    record_feature_use($pdo, 'analytics_open');
    if (!headers_sent()) {
        header('Cache-Control: private, no-store');
    }
    json_out(['ok' => true, 'trips' => $trips]);
}
