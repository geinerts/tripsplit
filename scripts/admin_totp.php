#!/usr/bin/env php
<?php
declare(strict_types=1);

// Operator tool for administrator 2FA. Run on the server as root; never prints secrets.
//   status                        list admins and their 2FA state
//   rotate-key [--apply]          re-encrypt stored secrets with TRIP_ADMIN_TOTP_ENCRYPTION_KEY
//                                 (old key in TRIP_ADMIN_TOTP_ENCRYPTION_KEY_PREVIOUS)
//   reset --username=NAME [--apply]  lost authenticator: remove 2FA and sign the admin out;
//                                 the next login must enrol a new authenticator
// Without --apply nothing is changed. See docs/security/admin-mfa.md.

if (PHP_SAPI !== 'cli') {
    fwrite(STDERR, "This script must be run from CLI.\n");
    exit(1);
}

require __DIR__ . '/../api/config.php';
require __DIR__ . '/../api/lib/bootstrap.php';

exit(admin_totp_cli(array_slice($argv, 1)));

function admin_totp_cli(array $args): int
{
    $command = (string) ($args[0] ?? '');
    $apply = in_array('--apply', $args, true);
    $username = '';
    foreach ($args as $arg) {
        if (str_starts_with($arg, '--username=')) {
            $username = trim(substr($arg, 11));
        }
    }
    $pdo = db();
    $table = table_name('admin_users');

    if ($command === 'status') {
        $rows = $pdo->query("SELECT username, role, is_active, totp_enabled,
                totp_pending_secret IS NOT NULL AS pending FROM {$table} ORDER BY id")->fetchAll(PDO::FETCH_ASSOC);
        foreach ($rows as $row) {
            printf("%-24s %-10s active=%d 2fa=%d pending=%d\n", $row['username'], $row['role'],
                (int) $row['is_active'], (int) $row['totp_enabled'], (int) $row['pending']);
        }
        return 0;
    }

    if ($command === 'rotate-key') {
        $result = admin_totp_reencrypt_all($pdo, $apply);
        echo 'Accounts with stored secrets: ' . $result['accounts'] . "\n";
        if ($result['unreadable'] !== []) {
            echo 'Unreadable with current or previous key (nothing changed): '
                . implode(', ', $result['unreadable']) . "\n";
            return 2;
        }
        echo $result['applied']
            ? "Re-encrypted with the current key. Remove TRIP_ADMIN_TOTP_ENCRYPTION_KEY_PREVIOUS now.\n"
            : "Dry run: all secrets are readable. Re-run with --apply.\n";
        return 0;
    }

    if ($command === 'reset' && $username !== '') {
        $stmt = $pdo->prepare("SELECT id FROM {$table} WHERE username = ? LIMIT 1");
        $stmt->execute([$username]);
        $id = (int) ($stmt->fetchColumn() ?: 0);
        if ($id <= 0) {
            fwrite(STDERR, "Admin user not found.\n");
            return 1;
        }
        if (!$apply) {
            echo "Dry run: would remove 2FA from {$username} and sign out all sessions. Re-run with --apply.\n";
            return 0;
        }
        $pdo->beginTransaction();
        $revoked = admin_totp_reset_user($pdo, $id);
        admin_audit_event($pdo, null, 'operator-cli', 'admin.totp.reset', 'admin_user', $id,
            ['revoked_sessions' => $revoked], true);
        $pdo->commit();
        echo "2FA removed from {$username}; {$revoked} session(s) signed out. Log in and enrol a new authenticator.\n";
        return 0;
    }

    fwrite(STDERR, "Usage: admin_totp.php status | rotate-key [--apply] | reset --username=NAME [--apply]\n");
    return 1;
}
