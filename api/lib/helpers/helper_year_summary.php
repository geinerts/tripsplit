<?php
declare(strict_types=1);

/** Past rates don't change, so they are kept once fetched. Throws when no rate is available. */
function year_summary_fx_rate(PDO $pdo, string $from, string $to, string $date): float
{
    if ($from === $to) {
        return 1.0;
    }
    $table = table_name('fx_rate_cache');
    try {
        $stmt = $pdo->prepare('SELECT rate FROM ' . $table . ' WHERE rate_date = :d AND from_currency = :f AND to_currency = :t');
        $stmt->execute(['d' => $date, 'f' => $from, 't' => $to]);
        $cached = $stmt->fetchColumn();
        if ($cached !== false && (float) $cached > 0) {
            return (float) $cached;
        }
    } catch (PDOException $error) {
        // The table arrives with the migration; rates can still be fetched.
    }
    $rate = fetch_historical_fx_rate($from, $to, $date);
    try {
        $pdo->prepare('INSERT INTO ' . $table . ' (rate_date, from_currency, to_currency, rate) VALUES (:d, :f, :t, :r)')
            ->execute(['d' => $date, 'f' => $from, 't' => $to, 'r' => number_format($rate, 10, '.', '')]);
    } catch (PDOException $error) {
        // A concurrent request stored it first, or the table is absent.
    }
    return $rate;
}

function year_summary_trip_year(array $trip): int
{
    $start = (string) ($trip['date_from'] ?? '') ?: (string) ($trip['ended_at'] ?? '');
    return (int) substr($start, 0, 4);
}

/** Number of days covered by inclusive [from, to] date ranges, counting overlaps once. */
function year_summary_days(array $ranges): int
{
    usort($ranges, static fn(array $a, array $b): int => $a[0] <=> $b[0]);
    $days = 0;
    $currentEnd = null;
    foreach ($ranges as [$from, $to]) {
        $start = strtotime($from . ' UTC');
        $end = strtotime(max($from, $to) . ' UTC');
        if ($start === false || $end === false) {
            continue;
        }
        if ($currentEnd !== null && $start <= $currentEnd) {
            $start = $currentEnd + 86400;
        }
        if ($end >= $start) {
            $days += (int) (($end - $start) / 86400) + 1;
            $currentEnd = $end;
        }
    }
    return $days;
}

/** $rate(from, to, date) is injected so tests never reach the rate provider. */
function year_summary_build(PDO $pdo, int $userId, int $year, string $currency, callable $rate): array
{
    $stmt = $pdo->prepare('SELECT t.* FROM ' . table_name('trip_members') . ' tm JOIN ' . table_name('trips')
        . ' t ON t.id = tm.trip_id WHERE tm.user_id = :user AND t.status <> "active" AND t.ended_at IS NOT NULL');
    $stmt->execute(['user' => $userId]);
    $finished = $stmt->fetchAll();

    $thisYear = (int) gmdate('Y');
    $availableYears = [];
    $trips = [];
    foreach ($finished as $trip) {
        $tripYear = year_summary_trip_year($trip);
        if ($tripYear >= 2000 && $tripYear <= $thisYear) {
            $availableYears[$tripYear] = true;
        }
        if ($tripYear === $year) {
            $trips[] = $trip;
        }
    }
    $availableYears = array_keys($availableYears);
    rsort($availableYears);

    $sharesStmt = $pdo->prepare('SELECT e.id, e.amount, e.category, e.expense_date, p.owed_cents FROM ' . table_name('expenses')
        . ' e JOIN ' . table_name('expense_participants') . ' p ON p.expense_id = e.id'
        . ' WHERE e.trip_id = :trip AND p.user_id = :user');
    $rangeStmt = $pdo->prepare('SELECT MIN(expense_date) AS first_day, MAX(expense_date) AS last_day FROM '
        . table_name('expenses') . ' WHERE trip_id = :trip');
    $companionStmt = $pdo->prepare('SELECT u.id, u.nickname FROM ' . table_name('trip_members') . ' tm JOIN '
        . table_name('users') . ' u ON u.id = tm.user_id WHERE tm.trip_id = :trip AND tm.user_id <> :user AND u.account_status = "active"');

    $expenseCount = 0;
    $totalCents = 0;
    $complete = true;
    $ranges = [];
    $categoryCents = [];
    $biggest = null;
    $companions = [];
    $countries = [];
    $cities = [];
    $addPlace = static function (string $code, string $country, string $city) use (&$countries, &$cities): void {
        $code = strtoupper(trim($code));
        $country = trim($country);
        $city = trim($city);
        if ($code !== '' && !isset($countries[$code])) {
            $countries[$code] = $country !== '' ? $country : $code;
        }
        if ($city !== '') {
            $cities[$code . '|' . mb_strtolower($city)] = $city;
        }
    };

    foreach ($trips as $trip) {
        $tripId = (int) $trip['id'];
        foreach (json_decode((string) ($trip['destinations_json'] ?? '[]'), true) ?: [] as $place) {
            if (is_array($place)) {
                $addPlace((string) ($place['country_code'] ?? ''), (string) ($place['country'] ?? ''), (string) ($place['city'] ?? ''));
            }
        }

        $rangeStmt->execute(['trip' => $tripId]);
        $span = $rangeStmt->fetch() ?: [];
        $from = (string) ($trip['date_from'] ?? '') ?: (string) ($span['first_day'] ?? '');
        $to = (string) ($trip['date_to'] ?? '') ?: ((string) ($span['last_day'] ?? '') ?: $from);
        if ($from !== '') {
            $ranges[] = [substr($from, 0, 10), substr($to, 0, 10)];
        }

        $companionStmt->execute(['trip' => $tripId, 'user' => $userId]);
        foreach ($companionStmt->fetchAll() as $row) {
            $id = (int) $row['id'];
            $companions[$id] ??= ['id' => $id, 'nickname' => (string) $row['nickname'], 'trip_count' => 0];
            $companions[$id]['trip_count']++;
        }

        $sharesStmt->execute(['trip' => $tripId, 'user' => $userId]);
        $rows = $sharesStmt->fetchAll();
        $expenseCount += count($rows);
        if (!$rows) {
            continue;
        }
        $tripCurrency = strtoupper((string) ($trip['currency_code'] ?? 'EUR'));
        try {
            $factor = (float) $rate($tripCurrency, $currency, substr((string) $trip['ended_at'], 0, 10));
        } catch (Throwable $error) {
            $complete = false;
            continue;
        }
        $tripCents = 0;
        foreach ($rows as $row) {
            $converted = (int) round(((int) $row['owed_cents']) * $factor);
            $tripCents += $converted;
            $category = trim((string) ($row['category'] ?? '')) ?: 'other';
            $categoryCents[$category] = ($categoryCents[$category] ?? 0) + $converted;
        }
        $totalCents += $tripCents;
        if ($biggest === null || $tripCents > $biggest['cents']) {
            $biggest = ['name' => (string) ($trip['name'] ?? ''), 'cents' => $tripCents];
        }
    }

    try {
        $places = $pdo->prepare('SELECT city, country, country_code FROM ' . table_name('travel_places')
            . ' WHERE user_id = :user AND visited_on >= :from AND visited_on <= :to');
        $places->execute(['user' => $userId, 'from' => $year . '-01-01', 'to' => $year . '-12-31']);
        foreach ($places->fetchAll() as $place) {
            $addPlace((string) $place['country_code'], (string) $place['country'], (string) $place['city']);
        }
    } catch (PDOException $error) {
        // Travel map visits are optional for this summary.
    }

    $topCategory = null;
    if ($categoryCents) {
        arsort($categoryCents);
        $key = (string) array_key_first($categoryCents);
        $topCategory = ['key' => $key, 'share' => cents_to_float($categoryCents[$key])];
    }
    $topCompanion = null;
    if ($companions) {
        usort($companions, static fn(array $a, array $b): int => [$b['trip_count'], $a['id']] <=> [$a['trip_count'], $b['id']]);
        $topCompanion = ['nickname' => $companions[0]['nickname'], 'trip_count' => $companions[0]['trip_count']];
    }
    $countryList = [];
    foreach ($countries as $code => $name) {
        $countryList[] = ['code' => (string) $code, 'name' => $name];
    }
    usort($countryList, static fn(array $a, array $b): int => strcmp($a['name'], $b['name']));
    $cityList = array_values($cities);
    sort($cityList);

    return [
        'year' => $year,
        'available_years' => $availableYears,
        'trip_count' => count($trips),
        'days_away' => year_summary_days($ranges),
        'expense_count' => $expenseCount,
        'countries' => $countryList,
        'cities' => $cityList,
        'currency_code' => $currency,
        'total_share' => cents_to_float($totalCents),
        'conversion_complete' => $complete,
        'biggest_trip' => $biggest === null ? null : ['name' => $biggest['name'], 'share' => cents_to_float($biggest['cents'])],
        'top_category' => $topCategory,
        'top_companion' => $topCompanion,
    ];
}
