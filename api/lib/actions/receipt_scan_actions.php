<?php
declare(strict_types=1);

// scan_receipt: reads an uploaded receipt photo with AI. Contract:
// docs/api/receipt-scan.md. Checks run cheapest first; the paid call happens
// only after the flag, limits, ownership, file checks and budget reservation.

require_once __DIR__ . '/../helpers/helper_feature_flags.php';
require_once __DIR__ . '/../helpers/helper_receipt_ai.php';

/** The scan as the API returns it, from a validated result. */
function receipt_ai_response_scan(int $scanId, string $requestId, bool $cached, array $result): array
{
    return ['id' => $scanId, 'request_id' => $requestId, 'cached' => $cached]
        + receipt_ai_reconcile_totals($result);
}

function scan_receipt_action(): void
{
    require_post();
    $me = get_me();
    $userId = (int) $me['id'];
    $body = read_json();
    $pdo = db();
    $now = time();

    // 1. A verified email account (device-only and trip-guest accounts cannot use AI).
    $stmt = $pdo->prepare('SELECT email, email_verified_at FROM ' . table_name('users') . ' WHERE id = ? LIMIT 1');
    $stmt->execute([$userId]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!is_array($user) || trim((string) ($user['email'] ?? '')) === '' || empty($user['email_verified_at'])) {
        receipt_ai_error('email_not_verified', 'Verify your email to use receipt reading.', 403);
    }
    // 2. Feature flag, read fresh: "off" applies at once.
    if (!feature_enabled_for_user($pdo, $userId, 'receipt_ai')) {
        receipt_ai_error('feature_disabled', 'Receipt reading is not available for your account.', 403);
    }

    $requestId = trim((string) ($body['request_id'] ?? ''));
    $receiptPath = trim((string) ($body['receipt_path'] ?? ''));
    $rescan = $body['rescan'] ?? false;
    if (array_key_exists('rescan', $body) && !is_bool($body['rescan'])) {
        json_out(['ok' => false, 'error' => 'rescan must be a boolean.'], 400);
    }
    if (preg_match('/^[A-Za-z0-9_-]{8,64}$/D', $requestId) !== 1 || $receiptPath === '' || strlen($receiptPath) > 255) {
        json_out(['ok' => false, 'error' => 'receipt_path and request_id are required.'], 400);
    }

    // Same request again: never a second AI call. Answered before the
    // per-minute limits, so the app can ask again while a slow scan runs.
    $existing = $pdo->prepare('SELECT id, receipt_path, status, result_json FROM ' . table_name('ai_scans')
        . ' WHERE user_id = ? AND request_id = ? LIMIT 1');
    $existing->execute([$userId, $requestId]);
    $previous = $existing->fetch(PDO::FETCH_ASSOC);
    if (is_array($previous)) {
        if ((string) $previous['receipt_path'] !== $receiptPath) {
            receipt_ai_error('request_id_reused', 'This request id was used for another receipt.', 409);
        }
        if ($previous['status'] === 'done' && $previous['result_json'] !== null) {
            $result = json_decode((string) $previous['result_json'], true);
            json_out(['ok' => true, 'scan' => receipt_ai_response_scan((int) $previous['id'], $requestId, false, (array) $result),
                'quota' => receipt_ai_quota_remaining($pdo, $userId, $now)]);
        }
        if (in_array($previous['status'], ['reserved', 'sent'], true)) {
            receipt_ai_error('scan_in_progress', 'This receipt is still being read.', 409);
        }
        receipt_ai_error('ai_unavailable', 'Receipt reading did not work this time. You can add the expense by hand.', 503);
    }

    // 3. Per-minute limits (fail closed), for new scans only.
    enforce_rate_limit($pdo, 'receipt_ai_user', (string) $userId, 2, 60);
    enforce_rate_limit($pdo, 'receipt_ai_ip', client_ip_address(), 10, 60);

    // 4. Ownership and file checks.
    assert_receipt_attachment_owned($receiptPath, $userId);
    $absPath = upload_relative_path_to_abs($receiptPath);
    if ($absPath === null || !is_file($absPath)) {
        receipt_ai_error('receipt_not_found', 'The receipt photo is no longer available.', 404);
    }
    [$imageBytes, $mime] = receipt_ai_prepare_image($absPath);
    $hash = hash_file('sha256', $absPath);

    // 5. Same image read in the last 7 days: no AI call, no quota.
    $cached = $rescan ? null : receipt_ai_cached_result($pdo, $userId, $hash, $now);
    if ($cached !== null) {
        $scanId = (int) $cached['id'];
        unset($cached['id'], $cached['request_id']);
        json_out(['ok' => true, 'scan' => receipt_ai_response_scan($scanId, $requestId, true, $cached),
            'quota' => receipt_ai_quota_remaining($pdo, $userId, $now)]);
    }

    if (OPENAI_API_KEY === '') {
        receipt_ai_error('ai_unavailable', 'Receipt reading is not available right now. You can add the expense by hand.', 503);
    }

    // 6. Quota, one-at-a-time and global budget, reserved together.
    $scanId = receipt_ai_reserve($pdo, $userId, $requestId, $receiptPath, $hash, $now);
    // Re-check the emergency switch after reserving; an "off" in between wins.
    if (!feature_enabled_for_user($pdo, $userId, 'receipt_ai')) {
        receipt_ai_settle($pdo, $scanId, 'failed', 0, ['error_code' => 'feature_disabled'], time());
        receipt_ai_error('feature_disabled', 'Receipt reading is not available for your account.', 403);
    }

    // 7. One provider call; from here the call may cost money.
    $pdo->prepare('UPDATE ' . table_name('ai_scans') . " SET status = 'sent' WHERE id = ?")->execute([$scanId]);
    $started = microtime(true);
    try {
        $answer = (receipt_ai_provider())($imageBytes, $mime);
    } catch (Throwable $error) {
        $answer = ['ok' => false, 'data' => null, 'input_tokens' => null, 'output_tokens' => null,
            'error_code' => 'provider_exception'];
    }
    $fields = ['duration_ms' => (int) round((microtime(true) - $started) * 1000),
        'input_tokens' => $answer['input_tokens'] ?? null, 'output_tokens' => $answer['output_tokens'] ?? null];
    $cost = isset($answer['input_tokens'], $answer['output_tokens'])
        ? receipt_ai_cost_microusd((int) $answer['input_tokens'], (int) $answer['output_tokens'])
        : null;

    if (($answer['ok'] ?? false) !== true || !is_array($answer['data'] ?? null)) {
        // Unknown cost: the whole reservation counts as spent.
        receipt_ai_settle($pdo, $scanId, 'failed', $cost, $fields + ['error_code' => (string) ($answer['error_code'] ?? 'provider_failed')], time());
        error_log('Receipt AI call failed: ' . (string) ($answer['error_code'] ?? 'provider_failed'));
        receipt_ai_error('ai_unavailable', 'Receipt reading did not work this time. You can add the expense by hand.', 503);
    }

    // 8. Validate in code; nothing from the model is trusted as is.
    $result = receipt_ai_validate($answer['data'], $now);
    receipt_ai_settle($pdo, $scanId, 'done', $cost, $fields + ['result_json' => json_encode($result, JSON_UNESCAPED_UNICODE)], time());
    if (random_int(1, 50) === 1) {
        receipt_ai_clear_old_results($pdo, $now);
    }
    json_out(['ok' => true, 'scan' => receipt_ai_response_scan($scanId, $requestId, false, $result),
        'quota' => receipt_ai_quota_remaining($pdo, $userId, time())]);
}
