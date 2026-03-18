<?php
declare(strict_types=1);

function normalize_feedback_history_actor(string $raw, string $fallback = 'system'): string
{
    $value = trim(preg_replace('/\s+/', ' ', $raw) ?? '');
    if ($value === '') {
        return $fallback;
    }
    if (str_length($value) > 80) {
        return substr($value, 0, 80);
    }
    return $value;
}

function append_feedback_history_event(
    PDO $pdo,
    int $feedbackId,
    string $action,
    ?string $fromStatus,
    ?string $toStatus,
    ?string $comment,
    string $actor,
    ?string $createdAt = null
): void {
    if ($feedbackId <= 0) {
        return;
    }

    $allowedActions = ['created', 'archived', 'deleted'];
    if (!in_array($action, $allowedActions, true)) {
        throw new RuntimeException('Unsupported feedback history action.');
    }

    $normalizeStatus = static function (?string $raw): ?string {
        if ($raw === null) {
            return null;
        }
        $value = strtolower(trim($raw));
        if ($value === '') {
            return null;
        }
        if ($value !== 'open' && $value !== 'archived') {
            throw new RuntimeException('Unsupported feedback status in history event.');
        }
        return $value;
    };

    $fromStatus = $normalizeStatus($fromStatus);
    $toStatus = $normalizeStatus($toStatus);
    $actor = normalize_feedback_history_actor($actor, 'system');

    $comment = $comment !== null ? trim($comment) : null;
    if ($comment === '') {
        $comment = null;
    }
    if ($comment !== null && str_length($comment) > 500) {
        $comment = substr($comment, 0, 500);
    }

    $table = table_name('feedback_status_history');
    try {
        if ($createdAt !== null && trim($createdAt) !== '') {
            $insert = $pdo->prepare(
                'INSERT INTO ' . $table . '
                 (feedback_id, action, from_status, to_status, comment, actor, created_at)
                 VALUES (:feedback_id, :action, :from_status, :to_status, :comment, :actor, :created_at)'
            );
            $insert->execute([
                'feedback_id' => $feedbackId,
                'action' => $action,
                'from_status' => $fromStatus,
                'to_status' => $toStatus,
                'comment' => $comment,
                'actor' => $actor,
                'created_at' => trim($createdAt),
            ]);
            return;
        }

        $insert = $pdo->prepare(
            'INSERT INTO ' . $table . '
             (feedback_id, action, from_status, to_status, comment, actor)
             VALUES (:feedback_id, :action, :from_status, :to_status, :comment, :actor)'
        );
        $insert->execute([
            'feedback_id' => $feedbackId,
            'action' => $action,
            'from_status' => $fromStatus,
            'to_status' => $toStatus,
            'comment' => $comment,
            'actor' => $actor,
        ]);
    } catch (Throwable $error) {
        if (is_missing_table_error($error)) {
            return;
        }
        throw $error;
    }
}

function load_feedback_history_map(PDO $pdo, array $feedbackIds): array
{
    $ids = [];
    foreach ($feedbackIds as $feedbackId) {
        $id = (int) $feedbackId;
        if ($id > 0) {
            $ids[$id] = $id;
        }
    }
    if (count($ids) === 0) {
        return [];
    }

    $table = table_name('feedback_status_history');
    $values = array_values($ids);
    $placeholders = implode(',', array_fill(0, count($values), '?'));
    try {
        $stmt = $pdo->prepare(
            'SELECT
                feedback_id,
                action,
                from_status,
                to_status,
                comment,
                actor,
                created_at
             FROM ' . $table . '
             WHERE feedback_id IN (' . $placeholders . ')
             ORDER BY id ASC'
        );
        foreach ($values as $index => $value) {
            $stmt->bindValue($index + 1, $value, PDO::PARAM_INT);
        }
        $stmt->execute();
    } catch (Throwable $error) {
        if (is_missing_table_error($error)) {
            return [];
        }
        throw $error;
    }

    $out = [];
    foreach ($stmt->fetchAll() as $row) {
        $feedbackId = (int) ($row['feedback_id'] ?? 0);
        if ($feedbackId <= 0) {
            continue;
        }
        if (!array_key_exists($feedbackId, $out)) {
            $out[$feedbackId] = [];
        }
        $out[$feedbackId][] = [
            'action' => (string) ($row['action'] ?? ''),
            'from_status' => $row['from_status'] !== null ? (string) $row['from_status'] : null,
            'to_status' => $row['to_status'] !== null ? (string) $row['to_status'] : null,
            'comment' => $row['comment'] !== null ? (string) $row['comment'] : null,
            'actor' => (string) ($row['actor'] ?? 'system'),
            'created_at' => $row['created_at'] !== null ? (string) $row['created_at'] : null,
        ];
    }

    return $out;
}
