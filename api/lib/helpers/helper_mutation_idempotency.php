<?php
declare(strict_types=1);

function normalize_client_mutation_id($value): string
{
    $raw = trim((string) $value);
    if ($raw === '') {
        return '';
    }
    if (strlen($raw) > 96) {
        $raw = substr($raw, 0, 96);
    }
    if (!preg_match('/^[A-Za-z0-9._:-]{8,96}$/', $raw)) {
        return '';
    }
    return $raw;
}

function request_client_mutation_id(): string
{
    static $cached = null;
    if (is_string($cached)) {
        return $cached;
    }

    $cached = normalize_client_mutation_id(
        $_SERVER['HTTP_X_CLIENT_MUTATION_ID'] ?? ''
    );
    return $cached;
}

function mutation_idempotency_table_available(PDO $pdo): bool
{
    static $cache = null;
    if (is_bool($cache)) {
        return $cache;
    }

    try {
        $rawTable = trim(table_name('mutation_idempotency'), '`');
        if ($rawTable === '' || !preg_match('/^[A-Za-z0-9_]+$/', $rawTable)) {
            $cache = false;
            return $cache;
        }
        $stmt = $pdo->prepare(
            'SELECT COUNT(1)
             FROM information_schema.tables
             WHERE table_schema = DATABASE()
               AND table_name = :table_name'
        );
        $stmt->execute(['table_name' => $rawTable]);
        $cache = ((int) ($stmt->fetchColumn() ?: 0)) >= 1;
    } catch (Throwable $error) {
        $cache = false;
    }

    return $cache;
}

function mutation_idempotency_try_replay(
    PDO $pdo,
    int $userId,
    int $tripId,
    string $action,
    string $mutationId
): void {
    if ($userId <= 0 || $tripId <= 0) {
        return;
    }
    $normalizedAction = trim($action);
    $normalizedMutationId = normalize_client_mutation_id($mutationId);
    if (
        $normalizedAction === '' ||
        $normalizedMutationId === '' ||
        !mutation_idempotency_table_available($pdo)
    ) {
        return;
    }

    $table = table_name('mutation_idempotency');
    $stmt = $pdo->prepare(
        'SELECT response_status, response_json
         FROM ' . $table . '
         WHERE user_id = :user_id
           AND trip_id = :trip_id
           AND action = :action
           AND mutation_id = :mutation_id
         LIMIT 1'
    );
    $stmt->execute([
        'user_id' => $userId,
        'trip_id' => $tripId,
        'action' => $normalizedAction,
        'mutation_id' => $normalizedMutationId,
    ]);
    $row = $stmt->fetch();
    if (!$row) {
        return;
    }

    $status = (int) ($row['response_status'] ?? 200);
    if ($status < 100 || $status > 599) {
        $status = 200;
    }
    $rawJson = (string) ($row['response_json'] ?? '');
    $payload = json_decode($rawJson, true);
    if (!is_array($payload)) {
        return;
    }

    json_out($payload, $status);
}

function mutation_idempotency_store_response(
    PDO $pdo,
    int $userId,
    int $tripId,
    string $action,
    string $mutationId,
    array $payload,
    int $status = 200
): void {
    if ($userId <= 0 || $tripId <= 0) {
        return;
    }
    $normalizedAction = trim($action);
    $normalizedMutationId = normalize_client_mutation_id($mutationId);
    if (
        $normalizedAction === '' ||
        $normalizedMutationId === '' ||
        !mutation_idempotency_table_available($pdo)
    ) {
        return;
    }

    $statusCode = $status;
    if ($statusCode < 100 || $statusCode > 599) {
        $statusCode = 200;
    }
    $encoded = json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    if (!is_string($encoded) || trim($encoded) === '') {
        return;
    }

    $table = table_name('mutation_idempotency');
    $insert = $pdo->prepare(
        'INSERT INTO ' . $table . '
         (user_id, trip_id, action, mutation_id, response_status, response_json)
         VALUES (:user_id, :trip_id, :action, :mutation_id, :response_status, :response_json)
         ON DUPLICATE KEY UPDATE
           response_status = VALUES(response_status),
           response_json = VALUES(response_json)'
    );
    $insert->execute([
        'user_id' => $userId,
        'trip_id' => $tripId,
        'action' => $normalizedAction,
        'mutation_id' => $normalizedMutationId,
        'response_status' => $statusCode,
        'response_json' => $encoded,
    ]);
}

