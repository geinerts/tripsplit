<?php
declare(strict_types=1);

function db(): PDO
{
    static $pdo = null;
    if ($pdo instanceof PDO) {
        return $pdo;
    }

    if (DB_NAME === '' || DB_USER === '') {
        throw new RuntimeException('Database is not configured. Set TRIP_DB_NAME and TRIP_DB_USER in .env.');
    }

    $dsn = sprintf('mysql:host=%s;dbname=%s;charset=utf8mb4', DB_HOST, DB_NAME);
    $pdo = new PDO($dsn, DB_USER, DB_PASS, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);

    return $pdo;
}

function table_name(string $key): string
{
    $map = [
        'users' => DB_TABLE_PREFIX . 'users',
        'trips' => DB_TABLE_PREFIX . 'trips',
        'trip_members' => DB_TABLE_PREFIX . 'trip_members',
        'expenses' => DB_TABLE_PREFIX . 'expenses',
        'expense_participants' => DB_TABLE_PREFIX . 'expense_participants',
        'settlements' => DB_TABLE_PREFIX . 'settlements',
        'notifications' => DB_TABLE_PREFIX . 'notifications',
        'feedback' => DB_TABLE_PREFIX . 'feedback',
        'feedback_status_history' => DB_TABLE_PREFIX . 'feedback_status_history',
        'random_orders' => DB_TABLE_PREFIX . 'random_orders',
        'random_order_members' => DB_TABLE_PREFIX . 'random_order_members',
        'random_draw_state' => DB_TABLE_PREFIX . 'random_draw_state',
        'friends' => DB_TABLE_PREFIX . 'friends',
        'request_limits' => DB_TABLE_PREFIX . 'request_limits',
        'upload_daily_usage' => DB_TABLE_PREFIX . 'upload_daily_usage',
        'refresh_tokens' => DB_TABLE_PREFIX . 'refresh_tokens',
        'push_tokens' => DB_TABLE_PREFIX . 'user_push_tokens',
        'push_queue' => DB_TABLE_PREFIX . 'push_queue',
        'notification_preferences' => DB_TABLE_PREFIX . 'user_notification_preferences',
        'settlement_reminder_state' => DB_TABLE_PREFIX . 'settlement_reminder_state',
        'mutation_idempotency' => DB_TABLE_PREFIX . 'mutation_idempotency',
        'password_resets'      => DB_TABLE_PREFIX . 'password_resets',
        'email_verification_tokens' => DB_TABLE_PREFIX . 'email_verification_tokens',
        'email_change_requests' => DB_TABLE_PREFIX . 'email_change_requests',
        'account_action_tokens' => DB_TABLE_PREFIX . 'account_action_tokens',
        'user_identities' => DB_TABLE_PREFIX . 'user_identities',
        'trip_invites'         => DB_TABLE_PREFIX . 'trip_invites',
        'trip_invite_preview_tokens' => DB_TABLE_PREFIX . 'trip_invite_preview_tokens',
    ];

    $raw = $map[$key] ?? '';
    if ($raw === '' || !preg_match('/^[A-Za-z0-9_]+$/', $raw)) {
        throw new RuntimeException('Invalid table mapping for key: ' . $key);
    }

    return '`' . $raw . '`';
}
