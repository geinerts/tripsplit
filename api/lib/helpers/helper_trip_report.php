<?php
declare(strict_types=1);

require_once __DIR__ . '/helper_currency_catalog.php';

/** Language of a report: a stored app language, then the newest push token, then English. */
function trip_report_user_locale(PDO $pdo, int $userId): string
{
    try {
        $stmt = $pdo->prepare('SELECT locale FROM ' . table_name('users') . ' WHERE id = :id');
        $stmt->execute(['id' => $userId]);
        $stored = $stmt->fetchColumn();
        if (is_string($stored) && $stored !== '') {
            return normalize_push_locale_code($stored);
        }
    } catch (PDOException $error) {
        // The column arrives with the migration.
    }
    try {
        $stmt = $pdo->prepare('SELECT locale FROM ' . table_name('push_tokens')
            . ' WHERE user_id = :id ORDER BY updated_at DESC, id DESC LIMIT 1');
        $stmt->execute(['id' => $userId]);
        $token = $stmt->fetchColumn();
        if (is_string($token) && $token !== '') {
            return normalize_push_locale_code($token);
        }
    } catch (PDOException $error) {
        // Fall through to the default.
    }
    return 'en';
}

function trip_report_strings(string $locale): array
{
    static $catalogs = [];
    if (isset($catalogs[$locale])) {
        return $catalogs[$locale];
    }
    $read = static function (string $code): array {
        $path = __DIR__ . '/trip_report_locales/' . $code . '.json';
        if (!preg_match('/^[a-z]{2}$/D', $code) || !is_file($path)) {
            return [];
        }
        $decoded = json_decode((string) file_get_contents($path), true);
        return is_array($decoded) ? $decoded : [];
    };
    return $catalogs[$locale] = array_replace($read('en'), $read($locale));
}

function trip_report_text(array $strings, string $key, string ...$args): string
{
    $text = (string) ($strings[$key] ?? $key);
    foreach ($args as $index => $value) {
        $text = str_replace('{arg' . ($index + 1) . '}', $value, $text);
    }
    return $text;
}

function trip_report_decimals(string $currency): int
{
    return in_array(strtoupper($currency), CURRENCY_CODES_WITHOUT_DECIMALS, true) ? 0 : 2;
}

/** Plain number with the currency's display decimals, as used in CSV cells. */
function trip_report_number(int $cents, string $currency): string
{
    return number_format($cents / 100, trip_report_decimals($currency), '.', '');
}

function trip_report_money(int $cents, string $currency, bool $signed = false): string
{
    $text = number_format(abs($cents) / 100, trip_report_decimals($currency), '.', "\u{00A0}");
    $isZero = (float) str_replace("\u{00A0}", '', $text) === 0.0;
    $sign = $isZero ? '' : ($cents < 0 ? '-' : ($signed ? '+' : ''));
    return $sign . $text . "\u{00A0}" . strtoupper($currency);
}

function trip_report_date(?string $value): string
{
    $day = substr((string) $value, 0, 10);
    $date = DateTimeImmutable::createFromFormat('!Y-m-d', $day);
    return $date && $date->format('Y-m-d') === $day ? $date->format('d.m.Y') : '';
}

function trip_report_category_label(array $strings, string $key): string
{
    $builtIn = ['food', 'groceries', 'fuel', 'transport', 'accommodation', 'activities', 'tickets',
        'shopping', 'party', 'parking', 'other'];
    $normalized = strtolower(trim($key));
    return in_array($normalized, $builtIn, true)
        ? trip_report_text($strings, 'category_' . $normalized)
        : trim($key);
}

/** One person's share of each expense, matching how balances treat legacy rows. */
function trip_report_expense_shares(int $amountCents, array $participants): array
{
    if (!$participants) {
        return [];
    }
    $stored = array_sum(array_map(static fn(array $p): int => (int) ($p['owed_cents'] ?? 0), $participants));
    $shares = [];
    if ($stored === $amountCents) {
        foreach ($participants as $participant) {
            $shares[(int) $participant['user_id']] = (int) $participant['owed_cents'];
        }
        return $shares;
    }
    $count = count($participants);
    $base = intdiv($amountCents, $count);
    $remainder = $amountCents - $base * $count;
    foreach (array_values($participants) as $index => $participant) {
        $shares[(int) $participant['user_id']] = $base + ($index < $remainder ? 1 : 0);
    }
    return $shares;
}

/** Everything a report can show about a trip, for one viewer. No contact or payment details. */
function trip_report_load(PDO $pdo, int $tripId, int $viewerId): ?array
{
    $stmt = $pdo->prepare('SELECT * FROM ' . table_name('trips') . ' WHERE id = :id');
    $stmt->execute(['id' => $tripId]);
    $trip = $stmt->fetch();
    if (!is_array($trip)) {
        return null;
    }
    $currency = strtoupper((string) ($trip['currency_code'] ?? 'EUR'));

    $computed = compute_trip_balance_data($pdo, $tripId);
    $stats = $computed['stats'] ?? [];
    $names = [];
    foreach ($stats as $id => $stat) {
        $names[(int) $id] = (string) ($stat['nickname'] ?? '');
    }

    $stmt = $pdo->prepare('SELECT * FROM ' . table_name('expenses')
        . ' WHERE trip_id = :id ORDER BY expense_date ASC, id ASC');
    $stmt->execute(['id' => $tripId]);
    $expenses = $stmt->fetchAll();

    $stmt = $pdo->prepare('SELECT p.expense_id, p.user_id, p.owed_cents FROM ' . table_name('expense_participants')
        . ' p JOIN ' . table_name('expenses') . ' e ON e.id = p.expense_id'
        . ' WHERE e.trip_id = :id ORDER BY p.expense_id ASC, p.user_id ASC');
    $stmt->execute(['id' => $tripId]);
    $participantsByExpense = [];
    foreach ($stmt->fetchAll() as $row) {
        $participantsByExpense[(int) $row['expense_id']][] = $row;
    }

    // People who left a trip are no longer members, but their expenses remain.
    $missing = [];
    foreach ($expenses as $expense) {
        $missing[(int) $expense['paid_by']] = true;
        foreach ($participantsByExpense[(int) $expense['id']] ?? [] as $participant) {
            $missing[(int) $participant['user_id']] = true;
        }
    }
    $missing = array_values(array_diff(array_keys($missing), array_keys($names)));
    if ($missing) {
        $stmt = $pdo->prepare('SELECT id, nickname FROM ' . table_name('users') . ' WHERE id IN ('
            . implode(',', array_fill(0, count($missing), '?')) . ')');
        $stmt->execute($missing);
        foreach ($stmt->fetchAll() as $row) {
            $names[(int) $row['id']] = (string) $row['nickname'];
        }
    }

    $totalCents = 0;
    $categoryTotals = [];
    $rows = [];
    foreach ($expenses as $expense) {
        $expenseId = (int) $expense['id'];
        $amountCents = decimal_to_cents($expense['amount']);
        $totalCents += $amountCents;
        $category = trim((string) ($expense['category'] ?? '')) ?: 'other';
        $categoryTotals[$category] = ($categoryTotals[$category] ?? 0) + $amountCents;
        $sourceCurrency = strtoupper((string) ($expense['currency_code'] ?? '')) ?: $currency;
        $sourceAmount = (float) ($expense['source_amount'] ?? 0);
        $rows[] = [
            'id' => $expenseId,
            'date' => (string) ($expense['expense_date'] ?? ''),
            'note' => trim((string) ($expense['note'] ?? '')),
            'category' => $category,
            'paid_by' => $names[(int) $expense['paid_by']] ?? '',
            'amount_cents' => $amountCents,
            'source_cents' => $sourceAmount > 0 ? decimal_to_cents($expense['source_amount']) : $amountCents,
            'source_currency' => $sourceCurrency,
            'rate' => (float) ($expense['fx_rate_to_trip'] ?? 1),
            'shares' => trip_report_expense_shares($amountCents, $participantsByExpense[$expenseId] ?? []),
        ];
    }
    arsort($categoryTotals);
    $categories = [];
    foreach ($categoryTotals as $key => $cents) {
        $categories[] = ['key' => (string) $key, 'cents' => $cents];
    }

    $adjustments = [];
    $payments = [];
    if (function_exists('load_trip_confirmed_payment_rows')) {
        foreach (load_trip_confirmed_payment_rows($pdo, $tripId) as $payment) {
            $from = (int) $payment['from_user_id'];
            $to = (int) $payment['to_user_id'];
            $cents = (int) $payment['amount_cents'];
            $adjustments[$from] = ($adjustments[$from] ?? 0) + $cents;
            $adjustments[$to] = ($adjustments[$to] ?? 0) - $cents;
            $payments[] = ['from' => $names[$from] ?? '', 'to' => $names[$to] ?? '', 'cents' => $cents];
        }
    }

    $members = [];
    foreach ($stats as $id => $stat) {
        $paid = (int) ($stat['paid_cents'] ?? 0);
        $owed = (int) ($stat['owed_cents'] ?? 0);
        $members[] = [
            'id' => (int) $id,
            'nickname' => (string) ($stat['nickname'] ?? ''),
            'paid_cents' => $paid,
            'owed_cents' => $owed,
            'net_cents' => $paid - $owed + ($adjustments[(int) $id] ?? 0),
        ];
    }

    $stmt = $pdo->prepare('SELECT from_user_id, to_user_id, amount_cents, status FROM ' . table_name('settlements')
        . ' WHERE trip_id = :id ORDER BY id ASC');
    $stmt->execute(['id' => $tripId]);
    $settlements = [];
    foreach ($stmt->fetchAll() as $row) {
        $settlements[] = [
            'from_id' => (int) $row['from_user_id'],
            'to_id' => (int) $row['to_user_id'],
            'from' => $names[(int) $row['from_user_id']] ?? '',
            'to' => $names[(int) $row['to_user_id']] ?? '',
            'cents' => (int) $row['amount_cents'],
            'status' => (string) ($row['status'] ?? 'pending'),
        ];
    }

    $destinations = [];
    foreach (json_decode((string) ($trip['destinations_json'] ?? '[]'), true) ?: [] as $place) {
        if (is_array($place)) {
            $label = implode(', ', array_filter([trim((string) ($place['city'] ?? '')), trim((string) ($place['country'] ?? ''))]));
            if ($label !== '') {
                $destinations[] = $label;
            }
        }
    }

    $people = [];
    foreach ($names as $id => $name) {
        $people[] = ['id' => $id, 'nickname' => $name];
    }

    return [
        'name' => trim((string) ($trip['name'] ?? '')) ?: 'Trip',
        'is_solo' => (string) ($trip['trip_mode'] ?? 'group') === 'solo',
        'currency' => $currency,
        'date_from' => $trip['date_from'] ?? null,
        'date_to' => $trip['date_to'] ?? null,
        'ended_at' => $trip['ended_at'] ?? null,
        'destinations' => $destinations,
        'total_cents' => $totalCents,
        'expense_count' => count($rows),
        'expenses' => $rows,
        'categories' => $categories,
        'members' => $members,
        'people' => $people,
        'payments' => $payments,
        'settlements' => $settlements,
        'viewer_id' => $viewerId,
    ];
}

function trip_report_viewer(array $report): ?array
{
    foreach ($report['members'] as $member) {
        if ($member['id'] === $report['viewer_id']) {
            return $member;
        }
    }
    return null;
}

function trip_report_date_range(array $report): string
{
    $from = trip_report_date($report['date_from'] ?? null);
    $to = trip_report_date($report['date_to'] ?? null);
    if ($from !== '' && $to !== '') {
        return $from === $to ? $from : $from . ' – ' . $to;
    }
    if ($from !== '' || $to !== '') {
        return $from . $to;
    }
    $dates = array_values(array_filter(array_column($report['expenses'], 'date')));
    if (!$dates) {
        return trip_report_date($report['ended_at'] ?? null);
    }
    $first = trip_report_date((string) min($dates));
    $last = trip_report_date((string) max($dates));
    return $first === $last ? $first : $first . ' – ' . $last;
}

function trip_report_file_name(string $tripName, string $extension, ?string $date): string
{
    $ascii = function_exists('iconv') ? (string) @iconv('UTF-8', 'ASCII//TRANSLIT//IGNORE', $tripName) : $tripName;
    $slug = trim((string) preg_replace('/[^a-z0-9]+/', '-', strtolower($ascii)), '-');
    $slug = substr($slug, 0, 60);
    $year = substr((string) $date, 0, 4);
    return 'splyto-' . ($slug !== '' ? $slug : 'trip')
        . (preg_match('/^\d{4}$/D', $year) ? '-' . $year : '') . '.' . $extension;
}
