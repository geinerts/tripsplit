<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require_once __DIR__ . '/../Fixtures/isolated_mysql.php';
$pdo = isolated_test_mysql();
$before = $pdo->query('SELECT * FROM trip_user_identities ORDER BY id')->fetchAll();
$migration = file_get_contents(__DIR__ . '/../../../sql/migrations/2026-10-04-social-identity-subject-case.sql');
if ($migration === false) { throw new RuntimeException('Missing subject collation migration'); }
// Apply the actual migration twice: rows must survive and reruns must be harmless.
for ($run = 0; $run < 2; $run++) {
    $pdo->exec($migration);
    $collation = $pdo->query("SELECT COLLATION_NAME FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'trip_user_identities'
        AND COLUMN_NAME = 'provider_subject'")->fetchColumn();
    if ($collation !== 'ascii_bin'
        || $before !== $pdo->query('SELECT * FROM trip_user_identities ORDER BY id')->fetchAll()) {
        throw new RuntimeException('Subject migration changed identities or has wrong collation');
    }
}
$pdo->beginTransaction();
try {
    $insert = $pdo->prepare('INSERT INTO trip_user_identities
        (user_id, provider, provider_subject) VALUES (?, ?, ?)');
    $insert->execute([901, 'google', 'Migration-Case-Probe']);
    $insert->execute([902, 'google', 'migration-case-probe']);
    $lookup = $pdo->prepare('SELECT user_id FROM trip_user_identities
        WHERE provider = ? AND provider_subject = ?');
    foreach (['Migration-Case-Probe' => 901, 'migration-case-probe' => 902] as $subject => $userId) {
        $lookup->execute(['google', $subject]);
        if (array_map('intval', $lookup->fetchAll(PDO::FETCH_COLUMN)) !== [$userId]) {
            throw new RuntimeException('Migrated subjects are not case-sensitive');
        }
    }
    try {
        $insert->execute([903, 'google', 'Migration-Case-Probe']);
        throw new RuntimeException('Migrated identity uniqueness is not enforced');
    } catch (PDOException $e) {
        if ($e->getCode() !== '23000') { throw $e; }
    }
} finally {
    $pdo->rollBack();
}
echo "Social subject migration: rows preserved, rerun and case-sensitive uniqueness PASS\n";
