<?php
declare(strict_types=1);

require_once __DIR__ . '/../helpers/helper_trip_report.php';
require_once __DIR__ . '/../helpers/helper_trip_report_render.php';
require_once __DIR__ . '/../helpers/helper_trip_report_delivery.php';
require_once __DIR__ . '/../helpers/helper_year_summary.php';
require_once __DIR__ . '/../helpers/helper_feature_usage.php';

function require_premium_feature(PDO $pdo, array $me, string $feature, ?int $tripId = null): void
{
    $access = premium_access_for_user($pdo, (int) $me['id']);
    if (!premium_feature_allowed_for($pdo, $access, $feature, $tripId)) {
        json_out(['ok' => false, 'code' => 'premium_required', 'error' => 'This feature requires Premium.'], 403);
    }
}

function set_account_locale_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $locale = normalize_push_locale_code(is_string($body['locale'] ?? null) ? $body['locale'] : '');
    $pdo = db();
    try {
        $pdo->prepare('UPDATE ' . table_name('users') . ' SET locale = :locale WHERE id = :id')
            ->execute(['locale' => $locale, 'id' => (int) $me['id']]);
    } catch (PDOException $error) {
        // Older schema: reports fall back to the push token language.
    }
    json_out(['ok' => true, 'locale' => $locale]);
}

function trip_export_action(): void
{
    $me = get_me();
    $pdo = db();
    $trip = get_current_trip($pdo, $me, true);
    require_premium_feature($pdo, $me, 'trip_export', (int) $trip['id']);

    $format = strtolower(trim((string) ($_GET['format'] ?? '')));
    if ($format !== 'pdf' && $format !== 'csv') {
        json_out(['ok' => false, 'error' => 'Unsupported export format.'], 400);
    }
    enforce_rate_limit($pdo, 'trip_export_user', (string) ((int) $me['id']), 20, 900);

    $report = trip_report_load($pdo, (int) $trip['id'], (int) $me['id']);
    if ($report === null) {
        json_out(['ok' => false, 'error' => 'Trip not found.'], 404);
    }
    $requested = trim((string) ($_GET['locale'] ?? ''));
    $locale = $requested !== '' ? normalize_push_locale_code($requested) : trip_report_user_locale($pdo, (int) $me['id']);
    $s = trip_report_strings($locale);

    $content = $format === 'pdf'
        ? trip_report_render_pdf(trip_report_html($report, $s, $locale, true))
        : trip_report_csv($report, $s);
    record_feature_use($pdo, 'trip_export_' . $format);

    if (!headers_sent()) {
        header('Cache-Control: private, no-store');
    }
    json_out([
        'ok' => true,
        'filename' => trip_report_file_name($report['name'], $format, $report['ended_at'] ?? gmdate('Y-m-d')),
        'mime_type' => $format === 'pdf' ? 'application/pdf' : 'text/csv',
        'content_base64' => base64_encode($content),
    ]);
}

function travel_year_summary_action(): void
{
    $me = get_me();
    $pdo = db();
    require_premium_feature($pdo, $me, 'year_summary');

    $thisYear = (int) gmdate('Y');
    $rawYear = $_GET['year'] ?? null;
    $year = $rawYear === null ? $thisYear : filter_var($rawYear, FILTER_VALIDATE_INT);
    if (!is_int($year) || $year < 2000 || $year > $thisYear) {
        json_out(['ok' => false, 'error' => 'Invalid year.'], 400);
    }
    enforce_rate_limit($pdo, 'year_summary_user', (string) ((int) $me['id']), 30, 900);

    $currency = normalize_profile_currency_code_or_default($me['preferred_currency_code'] ?? '');
    $summary = year_summary_build(
        $pdo,
        (int) $me['id'],
        $year,
        $currency,
        static fn(string $from, string $to, string $date): float => year_summary_fx_rate($pdo, $from, $to, $date)
    );
    record_feature_use($pdo, 'year_summary_view');
    if (!headers_sent()) {
        header('Cache-Control: private, no-store');
    }
    json_out(['ok' => true, 'summary' => $summary]);
}
