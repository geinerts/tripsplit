<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/../../lib/actions/settlements/settlements_core.php';
require __DIR__ . '/../../lib/actions/settlements/settlements_algorithm.php';
require __DIR__ . '/../../lib/actions/settlements/settlements_balance.php';
require __DIR__ . '/../../lib/actions/settlements/settlements_payload.php';
require __DIR__ . '/../../lib/actions/settlements/settlements_payments.php';
require __DIR__ . '/../../lib/actions/settlements/settlements_actions.php';
require __DIR__ . '/../../lib/helpers/helper_validation.php';
require __DIR__ . '/trip_invitations.php';
require_once __DIR__ . '/../../lib/helpers/helper_email.php';
require_once __DIR__ . '/../../lib/helpers/helper_premium.php';
require_once __DIR__ . '/../../lib/helpers/push/push_localization.php';
function normalize_profile_currency_code_or_default($value): string { return (string) ($value ?: 'EUR'); }
function fetch_historical_fx_rate(string $from, string $to, string $date): float {
    $GLOBALS['fx_calls']++;
    if ($from === 'XXX') throw new RuntimeException('no rate');
    return 2.0;
}
if (!function_exists('load_user_notification_preferences')) {
    function load_user_notification_preferences(PDO $pdo, int $id): array {
        return ['email_trip_report_enabled' => !in_array($id, $GLOBALS['report_opt_out'] ?? [], true)];
    }
}
require_once __DIR__ . '/../../lib/actions/trip_reports_actions.php';

ini_set('error_log', '/dev/null');
$assertions = 0;
$fx_calls = 0;
$pdo = invitation_test_setup(false);
foreach ([
    'ALTER TABLE trip_users ADD COLUMN created_at TIMESTAMP',
    'ALTER TABLE trip_users ADD COLUMN email VARCHAR(255)',
    'ALTER TABLE trip_users ADD COLUMN email_verified_at TIMESTAMP',
    'ALTER TABLE trip_users ADD COLUMN locale VARCHAR(8)',
    'ALTER TABLE trip_users ADD COLUMN preferred_currency_code VARCHAR(3) DEFAULT "EUR"',
    'ALTER TABLE trip_trips ADD COLUMN date_from DATE',
    'ALTER TABLE trip_trips ADD COLUMN date_to DATE',
    'ALTER TABLE trip_trips ADD COLUMN destinations_json TEXT',
    'ALTER TABLE trip_trip_members ADD COLUMN joined_at TIMESTAMP',
    'ALTER TABLE trip_trip_members ADD COLUMN ready_to_settle INT DEFAULT 1',
    'ALTER TABLE trip_trip_members ADD COLUMN ready_to_settle_at TIMESTAMP',
    'ALTER TABLE trip_expenses ADD COLUMN amount DECIMAL(10,2)',
    'ALTER TABLE trip_expenses ADD COLUMN currency_code VARCHAR(3)',
    'ALTER TABLE trip_expenses ADD COLUMN source_amount DECIMAL(10,2)',
    'ALTER TABLE trip_expenses ADD COLUMN fx_rate_to_trip DECIMAL(18,8)',
    'ALTER TABLE trip_expenses ADD COLUMN category VARCHAR(64)',
    'ALTER TABLE trip_expenses ADD COLUMN note VARCHAR(255)',
    'ALTER TABLE trip_expenses ADD COLUMN expense_date DATE',
    'ALTER TABLE trip_expense_participants ADD COLUMN owed_cents INT',
    'DROP TABLE trip_settlements',
    'CREATE TABLE trip_settlements (id INTEGER PRIMARY KEY AUTOINCREMENT, trip_id INT, from_user_id INT, to_user_id INT,
        amount_cents INT, status VARCHAR(20), created_at TIMESTAMP, marked_sent_at TIMESTAMP, confirmed_at TIMESTAMP)',
    'DROP TABLE trip_payments',
    'CREATE TABLE trip_payments (id INTEGER PRIMARY KEY AUTOINCREMENT, trip_id INT, from_user_id INT, to_user_id INT,
        amount_cents INT, status VARCHAR(20))',
    'CREATE TABLE trip_report_deliveries (id INTEGER PRIMARY KEY AUTOINCREMENT, trip_id INT, user_id INT,
        status VARCHAR(10) DEFAULT "pending", attempts INT DEFAULT 0, next_attempt_at DATETIME, created_at DATETIME,
        finished_at DATETIME NULL, UNIQUE(trip_id, user_id))',
    'CREATE TABLE trip_fx_rate_cache (rate_date DATE, from_currency VARCHAR(3), to_currency VARCHAR(3), rate DECIMAL(24,10),
        PRIMARY KEY (rate_date, from_currency, to_currency))',
    'CREATE TABLE trip_premium_grants (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INT, source VARCHAR(20),
        starts_at DATETIME, ends_at DATETIME, revoked_at DATETIME NULL)',
    'CREATE TABLE trip_travel_places (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INT, city VARCHAR(120), country VARCHAR(120),
        country_code VARCHAR(2), visited_on DATE)',
] as $sql) {
    $pdo->exec($sql);
}
$pdo->exec('INSERT INTO trip_users(id,nickname,first_name,account_status,email,email_verified_at,locale) VALUES
    (4,"Ēriks","Ēriks","active","e@example.invalid","2026-01-01","lv"),
    (5,"Unverified",NULL,"active","u@example.invalid",NULL,NULL),
    (6,"OptedOut",NULL,"active","o@example.invalid","2026-01-01",NULL),
    (7,"Gone",NULL,"deleted","g@example.invalid","2026-01-01",NULL),
    (8,"Plain=1",NULL,"active","p@example.invalid","2026-01-01",NULL)');
$report_opt_out = [6];

// Group trip in EUR: Ēriks paid 300, split between Ēriks and Plain.
$pdo->exec('INSERT INTO trip_trips(id,name,created_by,trip_mode,currency_code,date_from,date_to,destinations_json) VALUES
    (10,"Rīga & <Rome>",4,"group","EUR","2026-03-01","2026-03-05",\'[{"city":"Rome","country":"Italy","country_code":"IT"}]\')');
foreach ([4, 5, 6, 7, 8] as $user) {
    $role = $user === 4 ? 'owner' : 'member';
    $pdo->exec("INSERT INTO trip_trip_members(trip_id,user_id,role,ready_to_settle) VALUES (10,$user,'$role',1)");
}
$pdo->exec('INSERT INTO trip_expenses(id,trip_id,paid_by,amount,currency_code,source_amount,fx_rate_to_trip,category,note,expense_date) VALUES
    (100,10,4,200.00,"EUR",200.00,1,"food","=SUM(A1) dinner","2026-03-02"),
    (101,10,4,100.00,"JPY",16000.00,0.00625,"Surf lessons","<b>lesson</b>","2026-03-03")');
$pdo->exec('INSERT INTO trip_expense_participants(expense_id,user_id,owed_cents) VALUES (100,4,10000),(100,8,10000),(101,4,5000),(101,8,5000)');

$_SERVER['HTTP_X_TRIP_ID'] = '10';
$finish = invitation_call('end_trip_action', 4);
invitation_expect($finish['status'] === 200, 'Finishing still succeeds with the queue');
invitation_expect(!array_key_exists('report', $finish['body']), 'end_trip response is unchanged');
invitation_expect((int) $pdo->query('SELECT COUNT(*) FROM trip_report_deliveries WHERE trip_id=10')->fetchColumn() === 5, 'One delivery per member');
trip_report_enqueue($pdo, 10, [4, 5]);
invitation_expect((int) $pdo->query('SELECT COUNT(*) FROM trip_report_deliveries WHERE trip_id=10')->fetchColumn() === 5, 'Enqueue is idempotent');

// Delivery: only the eligible people get mail, and each report is personal.
$sent = [];
$html = [];
$send = static function (string $to, string $subject, string $body, array $attachments) use (&$sent): bool {
    $sent[] = compact('to', 'subject', 'body', 'attachments');
    return true;
};
$render = static function (string $document) use (&$html): string { $html[] = $document; return '%PDF-test'; };
$result = process_trip_report_deliveries($pdo, $send, $render);
invitation_expect($result['sent'] === 2 && $result['skipped'] === 3, 'Unverified, opted-out and deleted accounts are skipped');
invitation_expect(array_column($sent, 'to') === ['e@example.invalid', 'p@example.invalid'], 'Recipients are the eligible members');
invitation_expect(str_contains($sent[0]['subject'], 'atskaite'), 'Stored language selects the Latvian report');
invitation_expect(str_contains($sent[1]['subject'], 'trip report'), 'No stored language falls back to English');
invitation_expect($sent[0]['attachments'][0]['content'] === base64_encode('%PDF-test'), 'PDF is attached');
invitation_expect(str_contains($sent[0]['attachments'][0]['filename'], '.pdf'), 'Attachment has a PDF name');
invitation_expect(!str_contains($html[0], '<Rome>') && str_contains($html[0], '&lt;Rome&gt;'), 'Trip name is escaped in the PDF');
invitation_expect(!str_contains($sent[0]['body'], '<Rome>'), 'Trip name is escaped in the email');
invitation_expect(str_contains($html[0], '+150.00') , 'Balance belongs to the viewer');
invitation_expect(str_contains($html[1], '-150.00'), 'Other member sees their own balance');
invitation_expect(!str_contains($html[0], 'example.invalid'), 'Report has no email addresses');
invitation_expect(!str_contains($html[0], '=SUM') && !str_contains($html[0], 'lesson&lt;'), 'Free report has no individual expenses');
invitation_expect(process_trip_report_deliveries($pdo, $send, $render)['picked'] === 0, 'Sent reports are not sent twice');

// Retries back off, then stop.
$pdo->exec('INSERT INTO trip_trips(id,name,created_by,trip_mode,currency_code,status) VALUES (11,"Empty",4,"solo","EUR","archived")');
$pdo->exec('INSERT INTO trip_trip_members(trip_id,user_id,role) VALUES (11,4,"owner")');
trip_report_enqueue($pdo, 11, [4], 1000);
invitation_expect(process_trip_report_deliveries($pdo, $send, $render, 20, 2000)['skipped'] === 1, 'A trip without expenses sends no report');
$pdo->exec('INSERT INTO trip_trips(id,name,created_by,trip_mode,currency_code,status) VALUES (12,"Solo",4,"solo","JPY","archived")');
$pdo->exec('INSERT INTO trip_trip_members(trip_id,user_id,role) VALUES (12,4,"owner")');
$pdo->exec('INSERT INTO trip_expenses(id,trip_id,paid_by,amount,currency_code,source_amount,fx_rate_to_trip,category,note,expense_date) VALUES
    (120,12,4,1500.00,"JPY",1500.00,1,"food","Ramen","2026-04-01")');
$pdo->exec('INSERT INTO trip_expense_participants(expense_id,user_id,owed_cents) VALUES (120,4,150000)');
trip_report_enqueue($pdo, 12, [4], 1000);
$failing = static fn(): bool => false;
$time = 2000;
for ($attempt = 1; $attempt <= TRIP_REPORT_MAX_ATTEMPTS; $attempt++) {
    $outcome = process_trip_report_deliveries($pdo, $failing, $render, 20, $time);
    invitation_expect($outcome[$attempt === TRIP_REPORT_MAX_ATTEMPTS ? 'failed' : 'retried'] === 1, 'Failure ' . $attempt);
    invitation_expect(process_trip_report_deliveries($pdo, $failing, $render, 20, $time)['picked'] === 0, 'Waits before retrying');
    $time += 100000;
}
invitation_expect($pdo->query('SELECT status FROM trip_report_deliveries WHERE trip_id=12')->fetchColumn() === 'failed', 'Gives up after the limit');
$soloHtml = trip_report_html(trip_report_load($pdo, 12, 4), trip_report_strings('en'), 'en', false);
invitation_expect(str_contains($soloHtml, "1\u{00A0}500\u{00A0}JPY"), 'JPY shows no decimals');
invitation_expect(!str_contains($soloHtml, 'Your settlements'), 'Solo report has no settlement section');
process_trip_report_deliveries($pdo, $failing, $render, 20, time() + 40 * 86400);
invitation_expect((int) $pdo->query('SELECT COUNT(*) FROM trip_report_deliveries')->fetchColumn() === 0, 'Old rows are deleted');

// Premium gating.
$_GET = ['format' => 'csv'];
$denied = invitation_call('trip_export_action', 4);
invitation_expect($denied['status'] === 403 && $denied['body']['code'] === 'premium_required', 'Free account cannot export');
$pdo->exec('INSERT INTO trip_premium_grants(user_id,source,starts_at,ends_at) VALUES (4,"testing","2000-01-01","2100-01-01")');
$pdo->exec('INSERT INTO trip_premium_grants(user_id,source,starts_at,ends_at,revoked_at) VALUES (8,"testing","2000-01-01","2100-01-01","2020-01-01")');
invitation_expect(invitation_call('trip_export_action', 8)['status'] === 403, 'Revoked grant cannot export');
$_SERVER['HTTP_X_TRIP_ID'] = '12';
invitation_expect(invitation_call('trip_export_action', 8)['status'] !== 200, 'Non-member cannot export');
$_SERVER['HTTP_X_TRIP_ID'] = '10';
$_GET = ['format' => 'xls'];
invitation_expect(invitation_call('trip_export_action', 4)['status'] === 400, 'Unknown format is rejected');

// CSV.
$_GET = ['format' => 'csv', 'locale' => 'en'];
$export = invitation_call('trip_export_action', 4);
invitation_expect($export['status'] === 200 && $export['body']['mime_type'] === 'text/csv', 'Premium account can export CSV');
$csv = base64_decode($export['body']['content_base64']);
invitation_expect(str_starts_with($csv, "\xEF\xBB\xBF"), 'CSV has a byte order mark');
invitation_expect(str_contains($csv, "'=SUM(A1) dinner"), 'Formula cells are neutralised');
invitation_expect(str_contains($csv, "'Plain=1") === false && str_contains($csv, 'Plain=1'), 'Only leading formula characters are escaped');
invitation_expect(str_contains($csv, '16000.00;JPY') === false && str_contains($csv, '16000;JPY'), 'JPY original amount has no decimals');
invitation_expect(str_contains($csv, 'Surf lessons'), 'Custom category stays as written');
invitation_expect(!str_contains($csv, 'example.invalid'), 'CSV has no email addresses');

// Detailed PDF, rendered for real.
$_GET = ['format' => 'pdf', 'locale' => 'ru'];
$export = invitation_call('trip_export_action', 4);
invitation_expect($export['status'] === 200 && $export['body']['mime_type'] === 'application/pdf', 'Premium account can export a PDF');
invitation_expect(str_starts_with((string) base64_decode($export['body']['content_base64']), '%PDF-'), 'Output is a PDF');
$detailed = trip_report_html(trip_report_load($pdo, 10, 4), trip_report_strings('en'), 'en', true);
invitation_expect(str_contains($detailed, '=SUM(A1) dinner') && str_contains($detailed, '&lt;b&gt;lesson'), 'Detailed report lists escaped expenses');
invitation_expect(str_contains($detailed, 'All expenses') && !str_contains($detailed, '<b>lesson'), 'Detailed report has its section');

// Every language has every phrase.
$english = array_keys(trip_report_strings('en'));
foreach (['en','de','es','fr','it','pt','pl','nl','sv','da','nb','fi','cs','uk','lv','ru'] as $locale) {
    $catalog = json_decode((string) file_get_contents(__DIR__ . '/../../lib/helpers/trip_report_locales/' . $locale . '.json'), true);
    invitation_expect(array_keys($catalog) === $english, 'Catalog ' . $locale . ' is complete');
}

// Language action.
$updated = invitation_call('set_account_locale_action', 8, ['locale' => 'de-AT']);
invitation_expect($updated['body']['locale'] === 'de' && trip_report_user_locale($pdo, 8) === 'de', 'Language is stored');
invitation_expect(invitation_call('set_account_locale_action', 8, ['locale' => 'xx'])['body']['locale'] === 'en', 'Unknown language becomes English');

// Year summary.
$pdo->exec('INSERT INTO trip_trips(id,name,created_by,trip_mode,currency_code,status,date_from,date_to,ended_at,destinations_json) VALUES
    (20,"Overlap A",4,"group","EUR","archived","2025-06-01","2025-06-10","2025-06-11",\'[{"city":"Oslo","country":"Norway","country_code":"NO"}]\'),
    (21,"Overlap B",4,"group","USD","settling","2025-06-08","2025-06-12","2025-06-13",\'[{"city":"Oslo","country":"Norway","country_code":"NO"}]\'),
    (22,"No rate",4,"solo","XXX","archived","2025-09-01","2025-09-01","2025-09-02",NULL),
    (23,"Still open",4,"group","EUR","active","2025-10-01","2025-10-02",NULL,NULL),
    (24,"Not mine",7,"group","EUR","archived","2025-01-01","2025-01-02","2025-01-03",\'[{"city":"Paris","country":"France","country_code":"FR"}]\')');
foreach ([[20,4],[20,8],[21,4],[21,8],[22,4],[23,4],[24,7]] as [$trip, $user]) {
    $pdo->exec("INSERT INTO trip_trip_members(trip_id,user_id,role) VALUES ($trip,$user,'member')");
}
$pdo->exec('INSERT INTO trip_expenses(id,trip_id,paid_by,amount,currency_code,source_amount,fx_rate_to_trip,category,note,expense_date) VALUES
    (200,20,4,100.00,"EUR",100.00,1,"food","a","2025-06-02"),
    (210,21,8,100.00,"USD",100.00,1,"transport","b","2025-06-09"),
    (220,22,4,50.00,"XXX",50.00,1,"food","c","2025-09-01")');
$pdo->exec('INSERT INTO trip_expense_participants(expense_id,user_id,owed_cents) VALUES (200,4,10000),(210,4,10000),(220,4,5000)');
$pdo->exec('INSERT INTO trip_travel_places(user_id,city,country,country_code,visited_on) VALUES
    (4,"Tallinn","Estonia","EE","2025-02-02"),(4,"Vilnius","Lithuania","LT","2024-02-02"),(7,"Tokyo","Japan","JP","2025-02-02")');
$_GET = ['year' => '2025'];
$yearDenied = invitation_call('travel_year_summary_action', 8);
invitation_expect($yearDenied['status'] === 403 && $yearDenied['body']['code'] === 'premium_required', 'Year summary requires Premium');
$year = invitation_call('travel_year_summary_action', 4)['body']['summary'];
invitation_expect($year['trip_count'] === 3, 'Only finished trips of the account count');
invitation_expect($year['days_away'] === 13, 'Overlapping days count once');
invitation_expect(array_column($year['countries'], 'code') === ['EE', 'NO'], 'Countries combine trips and own visits');
invitation_expect($year['cities'] === ['Oslo', 'Tallinn'], 'Cities are unique and from this year');
invitation_expect($year['total_share'] === 300.0, 'Shares convert to the preferred currency');
invitation_expect($year['conversion_complete'] === false, 'A missing rate is reported');
invitation_expect($year['biggest_trip']['name'] === 'Overlap B' && $year['biggest_trip']['share'] === 200.0, 'Biggest trip uses converted amounts');
invitation_expect($year['top_category']['key'] === 'transport', 'Top category uses converted amounts');
invitation_expect($year['top_companion'] === ['nickname' => 'Plain=1', 'trip_count' => 2], 'Top companion counts shared trips');
invitation_expect(!isset($year['top_companion']['email']), 'Companion has only a nickname');
$calls = $fx_calls;
invitation_expect((int) $pdo->query('SELECT COUNT(*) FROM trip_fx_rate_cache')->fetchColumn() === 1, 'Fetched rates are kept');
invitation_call('travel_year_summary_action', 4);
invitation_expect($fx_calls === $calls + 1, 'A kept rate is not fetched again; the missing one still is');
invitation_expect(in_array(2025, $year['available_years'], true), 'Years with trips are listed');
$_GET = ['year' => '1999'];
invitation_expect(invitation_call('travel_year_summary_action', 4)['status'] === 400, 'Year out of range is rejected');
$_GET = ['year' => 'abc'];
invitation_expect(invitation_call('travel_year_summary_action', 4)['status'] === 400, 'Year must be a number');
$_GET = ['year' => '2020'];
$emptyYear = invitation_call('travel_year_summary_action', 4)['body']['summary'];
invitation_expect($emptyYear['trip_count'] === 0 && $emptyYear['biggest_trip'] === null && $emptyYear['top_category'] === null, 'Empty year has nulls');

// Without the migration, finishing a trip still works and nothing is queued.
$pdo->exec('DROP TABLE trip_report_deliveries');
invitation_expect(!trip_report_queue_available($pdo), 'Missing queue is detected');
$pdo->exec('INSERT INTO trip_trips(id,name,created_by,trip_mode,currency_code) VALUES (30,"Late",4,"solo","EUR")');
$pdo->exec('INSERT INTO trip_trip_members(trip_id,user_id,role) VALUES (30,4,"owner")');
$_SERVER['HTTP_X_TRIP_ID'] = '30';
invitation_expect(invitation_call('end_trip_action', 4)['status'] === 200, 'Finish works before the migration');
invitation_expect(process_trip_report_deliveries($pdo, $send, $render)['picked'] === 0, 'Worker is idle before the migration');
invitation_expect(!$pdo->inTransaction(), 'No transaction leaked');

echo json_encode(['assertions' => $assertions], JSON_THROW_ON_ERROR);
