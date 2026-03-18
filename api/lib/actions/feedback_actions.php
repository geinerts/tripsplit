<?php
declare(strict_types=1);

function normalize_feedback_type(string $raw): string
{
    $type = strtolower(trim($raw));
    if ($type === 'bug' || $type === 'suggestion') {
        return $type;
    }
    json_out(['ok' => false, 'error' => 'Feedback type must be bug or suggestion.'], 400);
}

function feedback_optional_text_field(string $raw, int $maxChars, string $fieldName): ?string
{
    $value = trim($raw);
    if ($value === '') {
        return null;
    }
    if (str_length($value) > $maxChars) {
        json_out(['ok' => false, 'error' => $fieldName . ' is too long.'], 400);
    }
    return $value;
}

function submit_feedback_action(): void
{
    require_post();
    $me = get_me();
    $pdo = db();
    $userId = (int) ($me['id'] ?? 0);

    enforce_rate_limit(
        $pdo,
        'feedback_ip',
        client_ip_address(),
        RATE_LIMIT_FEEDBACK_IP_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'feedback_user',
        (string) $userId,
        RATE_LIMIT_FEEDBACK_USER_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );

    $type = normalize_feedback_type((string) ($_POST['type'] ?? ''));
    $note = trim((string) ($_POST['note'] ?? ''));
    if ($note !== '') {
        if (str_length($note) > 2_000) {
            json_out(['ok' => false, 'error' => 'Feedback text is too long.'], 400);
        }
        ensure_text_has_no_links($note, 'Feedback text');
    }

    $tripIdRaw = (int) ($_POST['trip_id'] ?? 0);
    $tripId = null;
    if ($tripIdRaw > 0) {
        $trip = find_trip_for_user($pdo, $userId, $tripIdRaw);
        if (!$trip) {
            json_out(['ok' => false, 'error' => 'Trip not found or access denied.'], 403);
        }
        $tripId = (int) ($trip['id'] ?? 0);
    }

    $screenshotPath = '';
    $screenshotBytes = null;
    $hasScreenshotUpload = isset($_FILES['screenshot']) &&
        is_array($_FILES['screenshot']) &&
        (int) ($_FILES['screenshot']['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_NO_FILE;

    if ($hasScreenshotUpload) {
        $validated = validate_uploaded_image_file(
            $_FILES['screenshot'],
            FEEDBACK_MAX_BYTES,
            'Screenshot size must be up to 8 MB.'
        );
        $sourceSize = (int) ($validated['size'] ?? 0);

        enforce_upload_daily_quota(
            $pdo,
            'user',
            $userId,
            $sourceSize,
            UPLOAD_USER_MAX_FILES_PER_DAY,
            UPLOAD_USER_MAX_BYTES_PER_DAY
        );

        $stored = store_uploaded_image_as_webp(
            (string) ($validated['tmp'] ?? ''),
            FEEDBACK_REL_DIR,
            'ensure_feedback_dir',
            (string) ($validated['mime'] ?? '')
        );
        $screenshotPath = (string) ($stored['path'] ?? '');
        $screenshotBytes = (int) ($stored['size'] ?? $sourceSize);
    }

    if ($note === '' && $screenshotPath === '') {
        json_out(['ok' => false, 'error' => 'Add details or attach screenshot before sending.'], 400);
    }

    $platform = feedback_optional_text_field(
        (string) ($_POST['platform'] ?? ''),
        32,
        'Platform'
    );
    $appVersion = feedback_optional_text_field(
        (string) ($_POST['app_version'] ?? ''),
        64,
        'App version'
    );
    $buildNumber = feedback_optional_text_field(
        (string) ($_POST['build_number'] ?? ''),
        32,
        'Build number'
    );
    $locale = feedback_optional_text_field(
        (string) ($_POST['locale'] ?? ''),
        24,
        'Locale'
    );

    $contextJson = null;
    $rawContext = trim((string) ($_POST['context_json'] ?? ''));
    if ($rawContext !== '') {
        if (strlen($rawContext) > 8_000) {
            json_out(['ok' => false, 'error' => 'Feedback context is too large.'], 400);
        }
        $decodedContext = json_decode($rawContext, true);
        if (!is_array($decodedContext)) {
            json_out(['ok' => false, 'error' => 'Feedback context is invalid JSON.'], 400);
        }
        $encodedContext = json_encode($decodedContext, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        if (!is_string($encodedContext) || $encodedContext === '') {
            json_out(['ok' => false, 'error' => 'Feedback context could not be encoded.'], 400);
        }
        if (strlen($encodedContext) > 8_000) {
            json_out(['ok' => false, 'error' => 'Feedback context is too large.'], 400);
        }
        $contextJson = $encodedContext;
    }

    $feedbackTable = table_name('feedback');
    try {
        $insert = $pdo->prepare(
            'INSERT INTO ' . $feedbackTable . '
             (user_id, trip_id, type, note, screenshot_path, screenshot_size, app_platform, app_version, build_number, locale, context_json)
             VALUES (:user_id, :trip_id, :type, :note, :screenshot_path, :screenshot_size, :app_platform, :app_version, :build_number, :locale, :context_json)'
        );
        $insert->execute([
            'user_id' => $userId,
            'trip_id' => $tripId,
            'type' => $type,
            'note' => $note !== '' ? $note : null,
            'screenshot_path' => $screenshotPath !== '' ? $screenshotPath : null,
            'screenshot_size' => $screenshotBytes,
            'app_platform' => $platform,
            'app_version' => $appVersion,
            'build_number' => $buildNumber,
            'locale' => $locale,
            'context_json' => $contextJson,
        ]);
    } catch (Throwable $error) {
        if ($screenshotPath !== '') {
            delete_feedback_file($screenshotPath);
        }
        throw $error;
    }

    $feedbackId = (int) $pdo->lastInsertId();
    append_feedback_history_event(
        $pdo,
        $feedbackId,
        'created',
        null,
        'open',
        null,
        'user:' . (string) $userId
    );

    json_out([
        'ok' => true,
        'feedback_id' => $feedbackId,
        'type' => $type,
        'screenshot_url' => $screenshotPath !== '' ? feedback_public_url($screenshotPath) : null,
        'screenshot_thumb_url' => $screenshotPath !== '' ? feedback_thumb_public_url($screenshotPath) : null,
    ]);
}
