<?php
declare(strict_types=1);

// Optional during rollout. NULL deliberately preserves uncertain legacy accounts.
function users_password_capability_available(PDO $pdo): bool
{
    if ($pdo->getAttribute(PDO::ATTR_DRIVER_NAME) === 'sqlite') {
        $stmt = $pdo->query('PRAGMA table_info(' . table_name('users') . ')');
        foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $column) {
            if ($column['name'] === 'has_password') { return true; }
        }
        return false;
    }
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM information_schema.columns
        WHERE table_schema = DATABASE() AND table_name = :table_name
          AND column_name = 'has_password'");
    $stmt->execute(['table_name' => table_name('users')]);
    return (int) $stmt->fetchColumn() > 0;
}

function user_password_capability(PDO $pdo, int $userId): ?bool
{
    if (!users_password_capability_available($pdo)) { return null; }
    $stmt = $pdo->prepare('SELECT has_password FROM ' . table_name('users') . ' WHERE id = :id');
    $stmt->execute(['id' => $userId]);
    $value = $stmt->fetchColumn();
    return $value === null || $value === false ? null : (int) $value === 1;
}

// Call within the credential mutation's transaction, after ownership proof.
function record_user_password_capability(PDO $pdo, int $userId, bool $hasPassword): void
{
    if (!users_password_capability_available($pdo)) { return; }
    $pdo->prepare('UPDATE ' . table_name('users') . ' SET has_password = :value WHERE id = :id')
        ->execute(['value' => $hasPassword ? 1 : 0, 'id' => $userId]);
}
