<?php
declare(strict_types=1);

function trip_report_e(string $value): string
{
    return htmlspecialchars($value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

function trip_report_logo_data_uri(): string
{
    $path = __DIR__ . '/../../../email-logo-dark-v2.png';
    return is_file($path) ? 'data:image/png;base64,' . base64_encode((string) file_get_contents($path)) : '';
}

function trip_report_table(array $headers, array $rows, array $alignRight = []): string
{
    $html = '<table class="data"><thead><tr>';
    foreach ($headers as $index => $header) {
        $html .= '<th' . (in_array($index, $alignRight, true) ? ' class="r"' : '') . '>' . trip_report_e($header) . '</th>';
    }
    $html .= '</tr></thead><tbody>';
    foreach ($rows as $row) {
        $html .= '<tr>';
        foreach ($row as $index => $cell) {
            $html .= '<td' . (in_array($index, $alignRight, true) ? ' class="r"' : '') . '>' . trip_report_e((string) $cell) . '</td>';
        }
        $html .= '</tr>';
    }
    return $html . '</tbody></table>';
}

function trip_report_settlement_rows(array $report, array $s): array
{
    $rows = [];
    $statuses = ['pending' => 'status_pending', 'sent' => 'status_sent', 'confirmed' => 'status_confirmed'];
    foreach ($report['settlements'] as $settlement) {
        $isPayer = $settlement['from_id'] === $report['viewer_id'];
        if (!$isPayer && $settlement['to_id'] !== $report['viewer_id']) {
            continue;
        }
        $rows[] = [
            $isPayer
                ? trip_report_text($s, 'you_pay', $settlement['to'])
                : trip_report_text($s, 'pays_you', $settlement['from']),
            trip_report_money($settlement['cents'], $report['currency']),
            trip_report_text($s, $statuses[$settlement['status']] ?? 'status_pending'),
        ];
    }
    return $rows;
}

/** Report HTML. Every value from the database is escaped; nothing loads from outside the file. */
function trip_report_html(array $report, array $s, string $locale, bool $detailed): string
{
    $currency = $report['currency'];
    $money = static fn(int $cents, bool $signed = false): string => trip_report_money($cents, $currency, $signed);
    $viewer = trip_report_viewer($report);
    $title = trip_report_text($s, $detailed ? 'detailed_title' : 'title');

    $facts = [[trip_report_text($s, 'dates'), trip_report_date_range($report)]];
    if ($report['destinations']) {
        $facts[] = [trip_report_text($s, 'destinations'), implode('; ', $report['destinations'])];
    }

    $tiles = [[trip_report_text($s, 'total_spent'), $money($report['total_cents'])],
        [trip_report_text($s, 'expenses'), (string) $report['expense_count']]];
    if (!$report['is_solo'] && $viewer !== null) {
        $tiles[] = [trip_report_text($s, 'you_paid'), $money($viewer['paid_cents'])];
        $tiles[] = [trip_report_text($s, 'your_share'), $money($viewer['owed_cents'])];
        $tiles[] = [trip_report_text($s, 'your_balance'), $money($viewer['net_cents'], true)];
    }

    $tileCells = '';
    foreach ($tiles as $tile) {
        $tileCells .= '<td class="tile"><div class="label">' . trip_report_e($tile[0]) . '</div><div class="value">'
            . trip_report_e($tile[1]) . '</div></td>';
    }

    $factRows = '';
    foreach ($facts as $fact) {
        if ($fact[1] !== '') {
            $factRows .= '<tr><td class="fact-label">' . trip_report_e($fact[0]) . '</td><td>' . trip_report_e($fact[1]) . '</td></tr>';
        }
    }

    $body = '';
    if (!$report['is_solo']) {
        $settlementRows = trip_report_settlement_rows($report, $s);
        $body .= '<h2>' . trip_report_e(trip_report_text($s, 'your_settlements')) . '</h2>';
        $body .= $settlementRows
            ? trip_report_table([trip_report_text($s, 'description'), trip_report_text($s, 'amount'), trip_report_text($s, 'status')], $settlementRows, [1])
            : '<p>' . trip_report_e(trip_report_text($s, 'no_settlements')) . '</p>';
    }

    if ($report['categories']) {
        $rows = [];
        foreach ($report['categories'] as $category) {
            $percent = $report['total_cents'] > 0 ? (int) round($category['cents'] * 100 / $report['total_cents']) : 0;
            $rows[] = [trip_report_category_label($s, $category['key']), $money($category['cents']), $percent . '%'];
        }
        $body .= '<h2>' . trip_report_e(trip_report_text($s, 'by_category')) . '</h2>'
            . trip_report_table([trip_report_text($s, 'category'), trip_report_text($s, 'amount'), '%'], $rows, [1, 2]);
    }

    if (!$report['is_solo'] && $report['members']) {
        $rows = [];
        foreach ($report['members'] as $member) {
            $rows[] = [$member['nickname'], $money($member['paid_cents']), $money($member['owed_cents']), $money($member['net_cents'], true)];
        }
        $body .= '<h2>' . trip_report_e(trip_report_text($s, 'members')) . '</h2>'
            . trip_report_table([trip_report_text($s, 'member'), trip_report_text($s, 'paid'), trip_report_text($s, 'share'), trip_report_text($s, 'balance')], $rows, [1, 2, 3]);
    }

    if ($detailed) {
        $people = [];
        foreach ($report['people'] as $person) {
            $people[$person['id']] = $person['nickname'];
        }
        $rows = [];
        foreach ($report['expenses'] as $expense) {
            $shares = [];
            foreach ($expense['shares'] as $userId => $cents) {
                $shares[] = ($people[$userId] ?? '') . ': ' . $money($cents);
            }
            $original = trip_report_money($expense['source_cents'], $expense['source_currency']);
            if ($expense['source_currency'] !== $currency) {
                $original .= ' × ' . rtrim(rtrim(number_format($expense['rate'], 6, '.', ''), '0'), '.');
            }
            $rows[] = [trip_report_date($expense['date']),
                $expense['note'] !== '' ? $expense['note'] : trip_report_category_label($s, $expense['category']),
                trip_report_category_label($s, $expense['category']), $expense['paid_by'], $original,
                $money($expense['amount_cents']), implode('; ', $shares)];
        }
        $body .= '<h2>' . trip_report_e(trip_report_text($s, 'all_expenses')) . '</h2>'
            . '<div class="small">' . trip_report_table([trip_report_text($s, 'date'), trip_report_text($s, 'description'),
                trip_report_text($s, 'category'), trip_report_text($s, 'paid_by'), trip_report_text($s, 'original_amount'),
                trip_report_text($s, 'amount'), trip_report_text($s, 'share')], $rows, [4, 5]) . '</div>';

        if ($report['payments']) {
            $rows = array_map(static fn(array $p): array => [$p['from'], $p['to'], $money($p['cents'])], $report['payments']);
            $body .= '<h2>' . trip_report_e(trip_report_text($s, 'payments')) . '</h2>'
                . trip_report_table([trip_report_text($s, 'from'), trip_report_text($s, 'to'), trip_report_text($s, 'amount')], $rows, [2]);
        }
    }

    $logoUri = trip_report_logo_data_uri();
    $logo = $logoUri !== '' ? '<img src="' . $logoUri . '" alt="Splyto" style="width:105px;height:42px;">' : 'Splyto';
    $footer = trip_report_e(trip_report_text($s, 'footer'));
    $name = trip_report_e($report['name']);
    $titleEscaped = trip_report_e($title);
    $lang = trip_report_e($locale);

    return <<<HTML
<!DOCTYPE html>
<html lang="{$lang}">
<head>
<meta charset="UTF-8">
<title>{$name}</title>
<style>
  @page { margin: 0 0 56px 0; }
  body { margin: 0; font-family: 'DejaVu Sans', sans-serif; font-size: 10.5px; line-height: 1.45; color: #193149; }
  .band { background: #15222E; padding: 20px 36px 16px; }
  .accent { height: 3px; background: #008576; }
  .content { padding: 22px 36px 0; }
  .eyebrow { color: #008576; font-size: 9px; font-weight: bold; letter-spacing: 1px; text-transform: uppercase; }
  h1 { margin: 2px 0 12px; font-size: 22px; line-height: 1.2; }
  h2 { margin: 22px 0 8px; font-size: 13px; }
  .facts { margin-bottom: 12px; border-collapse: collapse; }
  .facts td { padding: 1px 12px 1px 0; vertical-align: top; }
  .fact-label { color: #53626B; }
  .tiles { width: 100%; border-collapse: separate; border-spacing: 0 6px; }
  .tile { background: #F2F6F5; padding: 9px 10px; border-right: 4px solid #FFFFFF; vertical-align: top; }
  .label { color: #53626B; font-size: 8.5px; }
  .value { font-size: 12px; font-weight: bold; margin-top: 2px; }
  table.data { width: 100%; border-collapse: collapse; }
  table.data th { text-align: left; color: #53626B; font-size: 9px; font-weight: bold; padding: 5px 6px; border-bottom: 1px solid #C9D6D2; }
  table.data td { padding: 5px 6px; border-bottom: 1px solid #E7EEEB; vertical-align: top; }
  table.data thead { display: table-header-group; }
  table.data tr { page-break-inside: avoid; }
  .r { text-align: right !important; white-space: nowrap; }
  .small table.data td, .small table.data th { font-size: 8px; padding: 4px 4px; }
  .footer { position: fixed; bottom: -36px; left: 36px; right: 36px; color: #68777D; font-size: 8.5px; }
</style>
</head>
<body>
  <div class="footer">{$footer}</div>
  <div class="band">{$logo}</div>
  <div class="accent"></div>
  <div class="content">
    <div class="eyebrow">{$titleEscaped}</div>
    <h1>{$name}</h1>
    <table class="facts">{$factRows}</table>
    <table class="tiles"><tr>{$tileCells}</tr></table>
    {$body}
  </div>
</body>
</html>
HTML;
}

function trip_report_render_pdf(string $html): string
{
    require_once __DIR__ . '/../dompdf/packages/autoload.php';
    $work = sys_get_temp_dir() . '/splyto-dompdf-' . (function_exists('posix_geteuid') ? posix_geteuid() : 'app');
    if (!is_dir($work) && !@mkdir($work, 0700, true) && !is_dir($work)) {
        throw new RuntimeException('PDF working directory is unavailable.');
    }
    $options = new \Dompdf\Options();
    $options->setIsRemoteEnabled(false);
    $options->setIsPhpEnabled(false);
    $options->setIsJavascriptEnabled(false);
    $options->setIsFontSubsettingEnabled(true);
    $options->setDefaultFont('DejaVu Sans');
    $options->setFontCache($work);
    $options->setTempDir($work);
    $options->setLogOutputFile($work . '/dompdf.log');

    // Third-party deprecation notices must not reach API responses or the worker's output.
    $previous = error_reporting(error_reporting() & ~E_DEPRECATED & ~E_USER_DEPRECATED);
    try {
        $dompdf = new \Dompdf\Dompdf($options);
        $dompdf->setPaper('A4');
        $dompdf->loadHtml($html, 'UTF-8');
        $dompdf->render();
        return (string) $dompdf->output();
    } finally {
        error_reporting($previous);
    }
}

function trip_report_csv_text(string $value): string
{
    return $value !== '' && in_array($value[0], ['=', '+', '-', '@', "\t", "\r"], true) ? "'" . $value : $value;
}

/** One row per expense and one share column per person; UTF-8 with BOM and `;` for Excel. */
function trip_report_csv(array $report, array $s): string
{
    $handle = fopen('php://temp', 'w+b');
    if ($handle === false) {
        throw new RuntimeException('CSV buffer is unavailable.');
    }
    $currency = $report['currency'];
    $people = $report['people'];
    $headers = [trip_report_text($s, 'date'), trip_report_text($s, 'description'), trip_report_text($s, 'category'),
        trip_report_text($s, 'paid_by'), trip_report_text($s, 'original_amount'), trip_report_text($s, 'currency'),
        trip_report_text($s, 'rate'), trip_report_text($s, 'amount'), trip_report_text($s, 'currency')];
    foreach ($people as $person) {
        $headers[] = trip_report_csv_text($person['nickname']);
    }
    fputcsv($handle, $headers, ';', '"', '');
    foreach ($report['expenses'] as $expense) {
        $row = [substr($expense['date'], 0, 10), trip_report_csv_text($expense['note']),
            trip_report_csv_text(trip_report_category_label($s, $expense['category'])),
            trip_report_csv_text($expense['paid_by']),
            trip_report_number($expense['source_cents'], $expense['source_currency']), $expense['source_currency'],
            rtrim(rtrim(number_format($expense['rate'], 8, '.', ''), '0'), '.'),
            trip_report_number($expense['amount_cents'], $currency), $currency];
        foreach ($people as $person) {
            $row[] = isset($expense['shares'][$person['id']])
                ? trip_report_number($expense['shares'][$person['id']], $currency) : '';
        }
        fputcsv($handle, $row, ';', '"', '');
    }
    rewind($handle);
    $csv = (string) stream_get_contents($handle);
    fclose($handle);
    return "\xEF\xBB\xBF" . $csv;
}
