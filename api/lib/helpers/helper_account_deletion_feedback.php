<?php
declare(strict_types=1);

function account_deletion_reason_codes(mixed $input): array
{
    if (!is_array($input) || !array_is_list($input)) {
        return [];
    }
    $allowed = ['not_using', 'another_way', 'too_complicated', 'technical_issue', 'privacy', 'other'];
    return array_values(array_filter($allowed, static fn(string $code): bool => in_array($code, $input, true)));
}

function record_account_deletion_feedback(PDO $pdo, array $reasons): void
{
    $reasons = account_deletion_reason_codes($reasons);
    if ($reasons === []) {
        return;
    }
    // Optional anonymous feedback must never block account deletion.
    try {
        $table = table_name('account_deletion_reason_counts');
        $sql = 'INSERT INTO ' . $table . ' (reason_code, request_count) VALUES (:reason, 1) ';
        $sql .= $pdo->getAttribute(PDO::ATTR_DRIVER_NAME) === 'sqlite'
            ? 'ON CONFLICT(reason_code) DO UPDATE SET request_count = request_count + 1'
            : 'ON DUPLICATE KEY UPDATE request_count = request_count + 1';
        $statement = $pdo->prepare($sql);
        foreach ($reasons as $code) {
            $statement->execute(['reason' => $code]);
        }
    } catch (Throwable $error) {
        error_log('Optional account deletion feedback could not be counted.');
    }
}

function account_deletion_feedback_summary(PDO $pdo): array
{
    $counts = array_fill_keys(account_deletion_reason_codes([
        'not_using', 'another_way', 'too_complicated', 'technical_issue', 'privacy', 'other',
    ]), 0);
    try {
        $table = table_name('account_deletion_reason_counts');
        foreach ($pdo->query("SELECT reason_code, request_count FROM {$table}")->fetchAll(PDO::FETCH_ASSOC) as $row) {
            $code = (string) $row['reason_code'];
            if (array_key_exists($code, $counts)) {
                $counts[$code] = max(0, (int) $row['request_count']);
            }
        }
    } catch (Throwable $error) {
        return ['available' => false, 'total_selections' => null, 'reasons' => []];
    }
    $reasons = [];
    foreach ($counts as $code => $count) {
        $reasons[] = ['code' => $code, 'count' => $count];
    }
    return ['available' => true, 'total_selections' => array_sum($counts), 'reasons' => $reasons];
}
