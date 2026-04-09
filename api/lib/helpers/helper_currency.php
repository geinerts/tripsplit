<?php
declare(strict_types=1);

function trip_supported_currency_codes(): array
{
    static $codes = null;
    if (is_array($codes)) {
        return $codes;
    }

    // Europe currencies + top 5 outside Europe.
    $codes = [
        // Europe
        'EUR', 'GBP', 'CHF', 'NOK', 'SEK', 'DKK',
        'PLN', 'CZK', 'HUF', 'RON', 'BGN', 'ISK',
        'ALL', 'BAM', 'BYN', 'MDL', 'MKD', 'RSD',
        'UAH', 'GEL', 'TRY',
        // Outside Europe (top 5)
        'USD', 'JPY', 'CNY', 'CAD', 'AUD',
    ];

    return $codes;
}

function fx_provider_supported_currency_codes(): array
{
    // Frankfurter-supported set (used for profile overview conversions).
    static $codes = null;
    if (is_array($codes)) {
        return $codes;
    }

    $codes = [
        'AUD', 'BGN', 'CAD', 'CHF', 'CNY', 'CZK', 'DKK', 'EUR',
        'GBP', 'HUF', 'ISK', 'JPY', 'NOK', 'PLN', 'RON', 'SEK',
        'TRY', 'USD',
    ];
    return $codes;
}

function currency_supported_by_fx_provider(string $code): bool
{
    $normalized = normalize_currency_code_or_default($code);
    return in_array($normalized, fx_provider_supported_currency_codes(), true);
}

function normalize_profile_currency_code_or_default($value): string
{
    $normalized = normalize_currency_code_or_default($value);
    if (!currency_supported_by_fx_provider($normalized)) {
        return default_trip_currency_code();
    }
    return $normalized;
}

function default_trip_currency_code(): string
{
    return 'EUR';
}

function normalize_currency_code($value, bool $allowEmpty = false): string
{
    $code = strtoupper(trim((string) $value));
    if ($code === '') {
        return $allowEmpty ? '' : default_trip_currency_code();
    }
    if (!preg_match('/^[A-Z]{3}$/', $code)) {
        json_out(['ok' => false, 'error' => 'Currency must be a 3-letter ISO code.'], 400);
    }

    $allowed = trip_supported_currency_codes();
    if (!in_array($code, $allowed, true)) {
        json_out(['ok' => false, 'error' => 'Unsupported currency code.'], 400);
    }

    return $code;
}

function normalize_currency_code_or_default($value): string
{
    $code = strtoupper(trim((string) $value));
    if ($code === '' || !preg_match('/^[A-Z]{3}$/', $code)) {
        return default_trip_currency_code();
    }
    return in_array($code, trip_supported_currency_codes(), true)
        ? $code
        : default_trip_currency_code();
}

function format_cents_with_currency(int $cents, string $currencyCode): string
{
    $code = normalize_currency_code($currencyCode);
    return $code . ' ' . cents_to_decimal($cents);
}

function trips_currency_column_available(PDO $pdo): bool
{
    static $cached = null;
    if (is_bool($cached)) {
        return $cached;
    }

    $tripsTable = DB_TABLE_PREFIX . 'trips';
    if (!preg_match('/^[A-Za-z0-9_]+$/', $tripsTable)) {
        $cached = false;
        return $cached;
    }

    try {
        $stmt = $pdo->prepare(
            'SELECT COUNT(1)
             FROM information_schema.columns
             WHERE table_schema = DATABASE()
               AND table_name = :table_name
               AND column_name = \'currency_code\''
        );
        $stmt->execute(['table_name' => $tripsTable]);
        $cached = ((int) ($stmt->fetchColumn() ?: 0)) >= 1;
    } catch (Throwable $error) {
        $cached = false;
    }

    return $cached;
}

function expenses_currency_columns_available(PDO $pdo): bool
{
    static $cached = null;
    if (is_bool($cached)) {
        return $cached;
    }

    $expensesTable = DB_TABLE_PREFIX . 'expenses';
    if (!preg_match('/^[A-Za-z0-9_]+$/', $expensesTable)) {
        $cached = false;
        return $cached;
    }

    try {
        $stmt = $pdo->prepare(
            'SELECT COUNT(1)
             FROM information_schema.columns
             WHERE table_schema = DATABASE()
               AND table_name = :table_name
               AND column_name IN (\'currency_code\', \'source_amount\', \'fx_rate_to_trip\')'
        );
        $stmt->execute(['table_name' => $expensesTable]);
        $cached = ((int) ($stmt->fetchColumn() ?: 0)) >= 3;
    } catch (Throwable $error) {
        $cached = false;
    }

    return $cached;
}

function trip_currency_code_from_trip(array $trip): string
{
    $raw = trim((string) ($trip['currency_code'] ?? ''));
    if ($raw === '') {
        return default_trip_currency_code();
    }
    return normalize_currency_code($raw);
}

function fx_provider_base_url(): string
{
    $raw = trim((string) FX_PROVIDER_BASE_URL);
    if ($raw === '') {
        return 'https://api.frankfurter.app';
    }
    return rtrim($raw, '/');
}

function fx_timeout_seconds(): int
{
    $raw = (int) FX_TIMEOUT_SEC;
    if ($raw < 2) {
        return 2;
    }
    if ($raw > 30) {
        return 30;
    }
    return $raw;
}

function http_get_json_assoc(string $url, int $timeoutSeconds): array
{
    $statusCode = 0;
    $body = '';

    if (function_exists('curl_init')) {
        $ch = curl_init();
        if ($ch === false) {
            throw new RuntimeException('Failed to initialize HTTP client.');
        }
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, $timeoutSeconds);
        curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, $timeoutSeconds);
        curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
        curl_setopt($ch, CURLOPT_MAXREDIRS, 2);
        curl_setopt($ch, CURLOPT_HTTPHEADER, ['Accept: application/json']);
        curl_setopt($ch, CURLOPT_USERAGENT, 'TripSplit/1.0 FX Client');
        $rawBody = curl_exec($ch);
        if ($rawBody === false) {
            $error = (string) curl_error($ch);
            curl_close($ch);
            throw new RuntimeException('FX provider request failed: ' . $error);
        }
        $statusCode = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        $body = (string) $rawBody;
    } else {
        $context = stream_context_create([
            'http' => [
                'method' => 'GET',
                'timeout' => $timeoutSeconds,
                'ignore_errors' => true,
                'header' => "Accept: application/json\r\nUser-Agent: TripSplit/1.0 FX Client\r\n",
            ],
            'ssl' => [
                'verify_peer' => true,
                'verify_peer_name' => true,
            ],
        ]);
        $rawBody = @file_get_contents($url, false, $context);
        if ($rawBody === false) {
            throw new RuntimeException('FX provider request failed.');
        }
        $body = (string) $rawBody;
        $headers = function_exists('http_get_last_response_headers')
            ? (http_get_last_response_headers() ?: [])
            : [];
        if ($headers) {
            $first = (string) $headers[0];
            if (preg_match('#\s(\d{3})\s#', $first, $matches)) {
                $statusCode = (int) $matches[1];
            }
        }
    }

    if ($statusCode >= 400) {
        throw new RuntimeException('FX provider returned HTTP ' . $statusCode . '.');
    }

    $decoded = json_decode($body, true);
    if (!is_array($decoded)) {
        throw new RuntimeException('FX provider returned invalid JSON.');
    }
    return $decoded;
}

function fetch_historical_fx_rate(string $fromCurrency, string $toCurrency, string $dateIso): float
{
    $from = normalize_currency_code($fromCurrency);
    $to = normalize_currency_code($toCurrency);
    if ($from === $to) {
        return 1.0;
    }

    $date = validate_date_iso($dateIso);
    static $memoryCache = [];
    $cacheKey = $date . '|' . $from . '|' . $to;
    if (isset($memoryCache[$cacheKey])) {
        return (float) $memoryCache[$cacheKey];
    }

    $url = fx_provider_base_url()
        . '/' . rawurlencode($date)
        . '?from=' . rawurlencode($from)
        . '&to=' . rawurlencode($to);

    $payload = http_get_json_assoc($url, fx_timeout_seconds());
    $rates = $payload['rates'] ?? null;
    if (!is_array($rates) || !array_key_exists($to, $rates)) {
        throw new RuntimeException('FX rate is not available for selected date/currency.');
    }

    $rateRaw = $rates[$to];
    if (!is_numeric($rateRaw)) {
        throw new RuntimeException('FX rate response is invalid.');
    }
    $rate = (float) $rateRaw;
    if ($rate <= 0) {
        throw new RuntimeException('FX rate must be positive.');
    }

    $memoryCache[$cacheKey] = $rate;
    return $rate;
}

function convert_amount_to_trip_currency(
    int $sourceAmountCents,
    string $sourceCurrency,
    string $tripCurrency,
    string $dateIso
): array {
    if ($sourceAmountCents <= 0) {
        json_out(['ok' => false, 'error' => 'Amount must be greater than zero.'], 400);
    }

    $from = normalize_currency_code($sourceCurrency);
    $to = normalize_currency_code($tripCurrency);
    if ($from === $to) {
        return [
            'converted_cents' => $sourceAmountCents,
            'fx_rate_to_trip' => 1.0,
        ];
    }

    try {
        $rate = fetch_historical_fx_rate($from, $to, $dateIso);
    } catch (Throwable $error) {
        json_out([
            'ok' => false,
            'error' => 'Unable to fetch FX rate for selected date. Please try again later.',
        ], 502);
    }

    $convertedCents = (int) round($sourceAmountCents * $rate);
    if ($convertedCents <= 0) {
        json_out(['ok' => false, 'error' => 'Converted amount is out of range.'], 400);
    }

    return [
        'converted_cents' => $convertedCents,
        'fx_rate_to_trip' => $rate,
    ];
}

function convert_expense_amount_to_target_currency_cents(
    int $sourceAmountCents,
    string $sourceCurrency,
    int $tripAmountCents,
    string $tripCurrency,
    string $dateIso,
    string $targetCurrency
): ?int {
    if ($sourceAmountCents <= 0 && $tripAmountCents <= 0) {
        return 0;
    }

    $from = normalize_currency_code_or_default($sourceCurrency);
    $trip = normalize_currency_code_or_default($tripCurrency);
    $target = normalize_currency_code_or_default($targetCurrency);
    $date = validate_date_iso($dateIso);

    if ($sourceAmountCents > 0 && $from === $target) {
        return $sourceAmountCents;
    }
    if ($tripAmountCents > 0 && $trip === $target) {
        return $tripAmountCents;
    }

    if ($sourceAmountCents > 0) {
        try {
            $rate = fetch_historical_fx_rate($from, $target, $date);
            $converted = (int) round($sourceAmountCents * $rate);
            if ($converted > 0) {
                return $converted;
            }
        } catch (Throwable $error) {
            // Fallback below to trip amount conversion if available.
        }
    }

    if ($tripAmountCents > 0) {
        try {
            $rate = fetch_historical_fx_rate($trip, $target, $date);
            $converted = (int) round($tripAmountCents * $rate);
            if ($converted > 0) {
                return $converted;
            }
        } catch (Throwable $error) {
            return null;
        }
    }

    return null;
}
