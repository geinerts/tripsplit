<?php
declare(strict_types=1);

function quick_start_available(PDO $pdo): bool
{
    $stmt = $pdo->prepare('SELECT COUNT(*) FROM information_schema.columns
        WHERE table_schema = DATABASE() AND table_name = :table_name
        AND column_name = \'quick_start_state\'');
    $stmt->execute([
        'table_name' => DB_TABLE_PREFIX . 'users',
    ]);
    return (int) $stmt->fetchColumn() > 0;
}

// Call inside the membership transaction. Leaving/deleting the trip must never
// make a previously experienced account eligible again. Pending invites do not count.
function suppress_quick_start_for_member(PDO $pdo, int $userId): void
{
    if (!quick_start_available($pdo)) return;
    $pdo->prepare('UPDATE ' . table_name('users') . '
        SET quick_start_state = \'experienced\'
        WHERE id = :user_id AND quick_start_state = \'pending\'')
        ->execute(['user_id' => $userId]);
}

function claim_quick_start(PDO $pdo, int $userId): bool
{
    if (!quick_start_available($pdo)) return false;
    $experienced = $pdo->prepare('UPDATE ' . table_name('users') . '
        SET quick_start_state = \'experienced\'
        WHERE id = :user_id AND quick_start_state = \'pending\'
        AND EXISTS (SELECT 1 FROM ' . table_name('trip_members') . '
            WHERE user_id = :member_id)');
    $experienced->execute(['user_id' => $userId, 'member_id' => $userId]);
    // The conditional write is atomic across devices. Persist before displaying,
    // so drag, back, app termination and a lost connection cannot cause a replay.
    $stmt = $pdo->prepare('UPDATE ' . table_name('users') . '
        SET quick_start_state = \'presented\'
        WHERE id = :user_id AND quick_start_state = \'pending\'
        AND NOT EXISTS (SELECT 1 FROM ' . table_name('trip_members') . '
            WHERE user_id = :member_id)');
    $stmt->execute(['user_id' => $userId, 'member_id' => $userId]);
    return $stmt->rowCount() === 1;
}
