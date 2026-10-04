<?php
declare(strict_types=1);

function receipt_owned_upload_path(string $path, int $userId): string
{
    $path = normalize_receipt_path($path, false);
    if ($userId <= 0 || pathinfo($path, PATHINFO_EXTENSION) !== 'webp') {
        throw new InvalidArgumentException('Invalid receipt upload owner or format.');
    }
    $stem = substr($path, 0, -5);
    $signature = hash_hmac('sha256', 'receipt-upload|' . $userId . '|' . $stem, auth_access_token_secret());
    return $stem . '_owner_' . $signature . '.webp';
}

function assert_receipt_attachment_owned(string $path, int $userId, string $existingPath = ''): void
{
    // An unchanged, previously authorized attachment remains valid after upgrades/key rotation.
    if ($path === '' || ($existingPath !== '' && $path === $existingPath)) {
        return;
    }
    if ($userId > 0 && preg_match('/^(.*)_owner_([a-f0-9]{64})\.webp$/D', $path, $match)) {
        $expected = receipt_owned_upload_path($match[1] . '.webp', $userId);
        if (hash_equals($expected, $path)) {
            return;
        }
    }
    json_out(['ok' => false, 'error' => 'Receipt must be uploaded by you. Please upload it again.'], 403);
}

function bind_stored_receipt_to_owner(array $stored, int $userId): string
{
    $path = (string) $stored['path'];
    $ownedPath = receipt_owned_upload_path($path, $userId);
    $source = upload_relative_path_to_abs($path);
    $target = upload_relative_path_to_abs($ownedPath);
    if ($source === null || $target === null || !rename($source, $target)) {
        delete_receipt_file($path);
        throw new RuntimeException('Could not secure receipt upload.');
    }
    $thumbPath = $stored['thumb_path'] ?? null;
    if (is_string($thumbPath) && $thumbPath !== '') {
        $thumbSource = upload_relative_path_to_abs($thumbPath);
        $thumbTargetPath = upload_thumb_relative_path($ownedPath);
        $thumbTarget = $thumbTargetPath !== null ? upload_relative_path_to_abs($thumbTargetPath) : null;
        if ($thumbSource === null || $thumbTarget === null || !rename($thumbSource, $thumbTarget)) {
            delete_receipt_file($path);
            delete_receipt_file($ownedPath);
            throw new RuntimeException('Could not secure receipt thumbnail.');
        }
    }
    return $ownedPath;
}

function delete_unreferenced_receipt(PDO $pdo, string $path): void
{
    if ($path === '') {
        return;
    }
    $stmt = $pdo->prepare('SELECT 1 FROM ' . table_name('expenses') . ' WHERE receipt_path = :path LIMIT 1');
    $stmt->execute(['path' => $path]);
    if (!$stmt->fetchColumn()) {
        delete_receipt_file($path);
    }
}
