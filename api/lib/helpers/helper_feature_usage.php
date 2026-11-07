<?php
declare(strict_types=1);

const FEATURE_USAGE_NAMES = [
    'trip_export_pdf',
    'trip_export_csv',
    'year_summary_view',
    'receipt_upload',
    'travel_map_open',
    'travel_place_save',
    'live_location_start',
    'random_pick',
    'analytics_open',
];
const FEATURE_USAGE_KEEP_MONTHS = 24;
const FEATURE_USAGE_SHOWN_MONTHS = 6;

/**
 * Adds one to this month's total. Stores no user, trip, device or IP address, and
 * never affects the feature. See docs/api/feature-usage-counters.md.
 */
function record_feature_use(PDO $pdo, string $feature, ?int $now = null): void
{
    if (!in_array($feature, FEATURE_USAGE_NAMES, true)) {
        return;
    }
    $now ??= time();
    try {
        $table = table_name('feature_usage_counts');
        $sql = 'INSERT INTO ' . $table . ' (usage_month, feature, use_count) VALUES (:month, :feature, 1) ';
        $sql .= $pdo->getAttribute(PDO::ATTR_DRIVER_NAME) === 'sqlite'
            ? 'ON CONFLICT(usage_month, feature) DO UPDATE SET use_count = use_count + 1'
            : 'ON DUPLICATE KEY UPDATE use_count = use_count + 1';
        $statement = $pdo->prepare($sql);
        $statement->execute(['month' => gmdate('Y-m', $now), 'feature' => $feature]);
        // MySQL reports 1 for a new row and 2 for an update, so this runs once per month and feature.
        if ($statement->rowCount() === 1) {
            $oldest = gmdate('Y-m', gmmktime(0, 0, 0, (int) gmdate('n', $now) - (FEATURE_USAGE_KEEP_MONTHS - 1), 1, (int) gmdate('Y', $now)));
            $pdo->prepare('DELETE FROM ' . $table . ' WHERE usage_month < :oldest')->execute(['oldest' => $oldest]);
        }
    } catch (Throwable) {
        // Optional statistics must never break the feature being counted.
    }
}

function feature_usage_summary(PDO $pdo): array
{
    try {
        $table = table_name('feature_usage_counts');
        $rows = $pdo->query("SELECT usage_month, feature, use_count FROM {$table}")->fetchAll(PDO::FETCH_ASSOC);
    } catch (Throwable) {
        return ['available' => false, 'months' => []];
    }
    $totals = [];
    foreach ($rows as $row) {
        $feature = (string) $row['feature'];
        if (in_array($feature, FEATURE_USAGE_NAMES, true)) {
            $totals[(string) $row['usage_month']][$feature] = max(0, (int) $row['use_count']);
        }
    }
    krsort($totals, SORT_STRING);
    $months = [];
    foreach (array_slice($totals, 0, FEATURE_USAGE_SHOWN_MONTHS, true) as $month => $counts) {
        $months[] = [
            'month' => (string) $month,
            'counts' => array_map(
                static fn(string $feature): array => ['feature' => $feature, 'count' => $counts[$feature] ?? 0],
                FEATURE_USAGE_NAMES
            ),
        ];
    }
    return ['available' => true, 'months' => $months];
}
