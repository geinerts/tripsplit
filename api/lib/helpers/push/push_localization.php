<?php
declare(strict_types=1);

function normalize_push_locale_code(?string $raw): string
{
    $value = strtolower(trim((string) $raw));
    if ($value === '') {
        return 'en';
    }

    if (str_contains($value, '-')) {
        $value = explode('-', $value, 2)[0];
    } elseif (str_contains($value, '_')) {
        $value = explode('_', $value, 2)[0];
    }

    if ($value === 'lv' || $value === 'latvian' || $value === 'latviesu' || $value === 'latviešu') {
        return 'lv';
    }
    if ($value === 'es' || $value === 'spanish' || $value === 'espanol' || $value === 'español') {
        return 'es';
    }

    if ($value === 'no') $value = 'nb';
    return in_array($value, ['en', 'de', 'fr', 'it', 'pt', 'pl', 'nl', 'sv', 'da', 'nb', 'fi', 'cs', 'uk', 'ru'], true) ? $value : 'en';
}

function push_localize_notification_for_locale(array $notification, string $localeCode): array
{
    $locale = normalize_push_locale_code($localeCode);
    $title = trim((string) ($notification['title'] ?? ''));
    $body = trim((string) ($notification['body'] ?? ''));
    $type = strtolower(trim((string) ($notification['type'] ?? 'info')));

    if ($title === '') {
        $title = 'Notification';
    }
    if ($locale === 'en') {
        return ['title' => $title, 'body' => $body];
    }

    $localizedTitle = push_localized_notification_title($type, $title, $locale);
    $localizedBody = push_localized_notification_body($type, $body, $locale);

    return [
        'title' => $localizedTitle !== '' ? $localizedTitle : $title,
        'body' => $localizedBody !== '' ? $localizedBody : $body,
    ];
}

function push_localized_notification_title(string $type, string $rawTitle, string $locale): string
{
    switch ($type) {
        case 'friend_invite':
        case 'friend_invite_received':
            return push_locale_phrase($locale, 'friend_invite_title');
        case 'friend_invite_accepted':
            return push_locale_phrase($locale, 'friend_invite_accepted_title');
        case 'trip_invitation':
            return push_locale_phrase($locale, 'trip_invitation_title');
        case 'trip_added':
        case 'trip_member_added':
            return push_locale_phrase($locale, 'trip_added_title');
        case 'expense_added':
            return push_locale_phrase($locale, 'expense_added_title');
        case 'expense_comment_mention':
            return push_locale_phrase($locale, 'comment_mention_title');
        case 'expense_comment_added':
            return push_locale_phrase($locale, 'comment_added_title');
        case 'trip_finished':
            return push_locale_phrase($locale, 'trip_finished_title');
        case 'member_ready_to_settle':
            return push_locale_phrase($locale, 'member_ready_title');
        case 'trip_ready_to_settle':
            return push_locale_phrase($locale, 'trip_ready_title');
        case 'payment_requested':
            return push_locale_phrase($locale, 'payment_requested_title');
        case 'payment_request_sent':
            return push_locale_phrase($locale, 'payment_request_sent_title');
        case 'payment_request_cancelled':
            return push_locale_phrase($locale, 'payment_request_cancelled_title');
        case 'payment_request_declined':
            return push_locale_phrase($locale, 'payment_request_declined_title');
        case 'payment_sent':
            return push_locale_phrase($locale, 'payment_sent_title');
        case 'payment_confirmed':
            return push_locale_phrase($locale, 'payment_confirmed_title');
        case 'payment_cancelled':
            return push_locale_phrase($locale, 'payment_cancelled_title');
        case 'payment_not_received':
            return push_locale_phrase($locale, 'payment_not_received_title');
        case 'settlement_reminder':
            return push_locale_phrase($locale, 'settlement_reminder_title');
        case 'settlement_auto_reminder':
            if (str_contains(strtolower($rawTitle), 'confirmation')) {
                return push_locale_phrase($locale, 'confirmation_reminder_title');
            }
            return push_locale_phrase($locale, 'payment_reminder_title');
        case 'settlement_sent':
            return push_locale_phrase($locale, 'settlement_sent_title');
        case 'settlement_confirmed':
            return push_locale_phrase($locale, 'settlement_confirmed_title');
        default:
            return '';
    }
}

function push_localized_notification_body(string $type, string $rawBody, string $locale): string
{
    if ($rawBody === '') {
        return '';
    }

    switch ($type) {
        case 'trip_invitation':
            return push_locale_phrase($locale, 'trip_invitation_body');
        case 'friend_invite':
        case 'friend_invite_received':
            if (preg_match('/^(.+?) sent you a friend invite\.$/u', $rawBody, $match) === 1) {
                return push_locale_format(
                    push_locale_phrase($locale, 'friend_invite_body'),
                    ['name' => trim((string) ($match[1] ?? ''))]
                );
            }
            return push_locale_phrase($locale, 'friend_invite_body_generic');
        case 'friend_invite_accepted':
            if (preg_match('/^(.+?) accepted your friend invite\.$/u', $rawBody, $match) === 1) {
                return push_locale_format(
                    push_locale_phrase($locale, 'friend_invite_accepted_body'),
                    ['name' => trim((string) ($match[1] ?? ''))]
                );
            }
            return push_locale_phrase($locale, 'friend_invite_accepted_body_generic');
        case 'trip_added':
        case 'trip_member_added':
            if (preg_match('/^(.+?) added you to trip "(.+?)"\.$/u', $rawBody, $match) === 1) {
                return push_locale_format(
                    push_locale_phrase($locale, 'trip_added_body'),
                    [
                        'name' => trim((string) ($match[1] ?? '')),
                        'trip' => trim((string) ($match[2] ?? '')),
                    ]
                );
            }
            return push_locale_phrase($locale, 'trip_added_body_generic');
        case 'expense_added':
            if (preg_match('/^(.+?) added an expense of (.+?) in "(.+?)"\.$/u', $rawBody, $match) === 1) {
                return push_locale_format(
                    push_locale_phrase($locale, 'expense_added_body_trip'),
                    [
                        'name' => trim((string) ($match[1] ?? '')),
                        'amount' => trim((string) ($match[2] ?? '')),
                        'trip' => trim((string) ($match[3] ?? '')),
                    ]
                );
            }
            if (preg_match('/^(.+?) added an expense of (.+?): (.+)$/u', $rawBody, $match) === 1) {
                return push_locale_format(
                    push_locale_phrase($locale, 'expense_added_body_note'),
                    [
                        'name' => trim((string) ($match[1] ?? '')),
                        'amount' => trim((string) ($match[2] ?? '')),
                        'note' => trim((string) ($match[3] ?? '')),
                    ]
                );
            }
            return push_locale_phrase($locale, 'expense_added_body_generic');
        case 'expense_comment_mention':
            if (preg_match('/^(.+?) mentioned you in a comment on "(.+)"\.$/u', $rawBody, $match) === 1) {
                return push_locale_format(
                    push_locale_phrase($locale, 'comment_mention_body'),
                    [
                        'name' => trim((string) ($match[1] ?? '')),
                        'note' => trim((string) ($match[2] ?? '')),
                    ]
                );
            }
            if (preg_match('/^(.+?) mentioned you in a comment\.$/u', $rawBody, $match) === 1) {
                return push_locale_format(
                    push_locale_phrase($locale, 'comment_mention_body_generic'),
                    ['name' => trim((string) ($match[1] ?? ''))]
                );
            }
            return '';
        case 'expense_comment_added':
            if (preg_match('/^(.+?) commented on "(.+)"\.$/u', $rawBody, $match) === 1) {
                return push_locale_format(
                    push_locale_phrase($locale, 'comment_added_body'),
                    [
                        'name' => trim((string) ($match[1] ?? '')),
                        'note' => trim((string) ($match[2] ?? '')),
                    ]
                );
            }
            if (preg_match('/^(.+?) commented on your expense\.$/u', $rawBody, $match) === 1) {
                return push_locale_format(
                    push_locale_phrase($locale, 'comment_added_body_generic'),
                    ['name' => trim((string) ($match[1] ?? ''))]
                );
            }
            return '';
        case 'trip_finished':
            if (preg_match('/^(.+?) finished "(.+?)"\. Settlements are ready\.$/u', $rawBody, $match) === 1) {
                return push_locale_format(
                    push_locale_phrase($locale, 'trip_finished_body_settling'),
                    [
                        'name' => trim((string) ($match[1] ?? '')),
                        'trip' => trim((string) ($match[2] ?? '')),
                    ]
                );
            }
            if (preg_match('/^(.+?) finished "(.+?)"\. Trip is archived\.$/u', $rawBody, $match) === 1) {
                return push_locale_format(
                    push_locale_phrase($locale, 'trip_finished_body_archived'),
                    [
                        'name' => trim((string) ($match[1] ?? '')),
                        'trip' => trim((string) ($match[2] ?? '')),
                    ]
                );
            }
            return push_locale_phrase($locale, 'trip_finished_body_generic');
        case 'member_ready_to_settle':
            if (preg_match('/^(.+?) is ready to settle in "(.+?)"\.$/u', $rawBody, $match) === 1) {
                return push_locale_format(
                    push_locale_phrase($locale, 'member_ready_body'),
                    [
                        'name' => trim((string) ($match[1] ?? '')),
                        'trip' => trim((string) ($match[2] ?? '')),
                    ]
                );
            }
            return push_locale_phrase($locale, 'member_ready_body_generic');
        case 'trip_ready_to_settle':
            if (preg_match('/^All members marked ready in "(.+?)"\. You can start settlements\.$/u', $rawBody, $match) === 1) {
                return push_locale_format(
                    push_locale_phrase($locale, 'trip_ready_body'),
                    ['trip' => trim((string) ($match[1] ?? ''))]
                );
            }
            return push_locale_phrase($locale, 'trip_ready_body_generic');
        case 'payment_requested':
            if (preg_match('/^(.+?) requested (.+?) from you\.$/u', $rawBody, $match) === 1) {
                return push_locale_format(
                    push_locale_phrase($locale, 'payment_requested_body'),
                    [
                        'name' => trim((string) ($match[1] ?? '')),
                        'amount' => trim((string) ($match[2] ?? '')),
                    ]
                );
            }
            return push_locale_phrase($locale, 'payment_requested_body_generic');
        case 'payment_request_sent':
            if (preg_match('/^(.+?) marked your (.+?) payment request as paid\.$/u', $rawBody, $match) === 1) {
                return push_locale_format(
                    push_locale_phrase($locale, 'payment_request_sent_body'),
                    [
                        'name' => trim((string) ($match[1] ?? '')),
                        'amount' => trim((string) ($match[2] ?? '')),
                    ]
                );
            }
            return push_locale_phrase($locale, 'payment_request_sent_body_generic');
        case 'payment_request_cancelled':
            if (preg_match('/^(.+?) cancelled the (.+?) payment request\.$/u', $rawBody, $match) === 1) {
                return push_locale_format(
                    push_locale_phrase($locale, 'payment_request_cancelled_body'),
                    [
                        'name' => trim((string) ($match[1] ?? '')),
                        'amount' => trim((string) ($match[2] ?? '')),
                    ]
                );
            }
            return push_locale_phrase($locale, 'payment_request_cancelled_body_generic');
        case 'payment_request_declined':
            if (preg_match('/^(.+?) declined your (.+?) payment request\.$/u', $rawBody, $match) === 1) {
                return push_locale_format(
                    push_locale_phrase($locale, 'payment_request_declined_body'),
                    [
                        'name' => trim((string) ($match[1] ?? '')),
                        'amount' => trim((string) ($match[2] ?? '')),
                    ]
                );
            }
            return push_locale_phrase($locale, 'payment_request_declined_body_generic');
        case 'payment_sent':
            if (preg_match('/^(.+?) marked (.+?) as paid to you\.$/u', $rawBody, $match) === 1) {
                return push_locale_format(
                    push_locale_phrase($locale, 'payment_sent_body'),
                    [
                        'name' => trim((string) ($match[1] ?? '')),
                        'amount' => trim((string) ($match[2] ?? '')),
                    ]
                );
            }
            return push_locale_phrase($locale, 'payment_sent_body_generic');
        case 'payment_confirmed':
            if (preg_match('/^(.+?) confirmed receiving (.+?) from you\.$/u', $rawBody, $match) === 1) {
                return push_locale_format(
                    push_locale_phrase($locale, 'payment_confirmed_body'),
                    [
                        'name' => trim((string) ($match[1] ?? '')),
                        'amount' => trim((string) ($match[2] ?? '')),
                    ]
                );
            }
            return push_locale_phrase($locale, 'payment_confirmed_body_generic');
        case 'payment_cancelled':
            if (preg_match('/^(.+?) cancelled the (.+?) payment mark\.$/u', $rawBody, $match) === 1) {
                return push_locale_format(
                    push_locale_phrase($locale, 'payment_cancelled_body'),
                    [
                        'name' => trim((string) ($match[1] ?? '')),
                        'amount' => trim((string) ($match[2] ?? '')),
                    ]
                );
            }
            return push_locale_phrase($locale, 'payment_cancelled_body_generic');
        case 'payment_not_received':
            if (preg_match('/^(.+?) marked the (.+?) payment as not received\.$/u', $rawBody, $match) === 1) {
                return push_locale_format(
                    push_locale_phrase($locale, 'payment_not_received_body'),
                    [
                        'name' => trim((string) ($match[1] ?? '')),
                        'amount' => trim((string) ($match[2] ?? '')),
                    ]
                );
            }
            return push_locale_phrase($locale, 'payment_not_received_body_generic');
        case 'settlement_reminder':
            if (preg_match('/^(.+?) reminded (.+?) to mark (.+?) as sent\.$/u', $rawBody, $match) === 1) {
                return push_locale_format(
                    push_locale_phrase($locale, 'settlement_reminder_mark_sent_body'),
                    [
                        'actor' => trim((string) ($match[1] ?? '')),
                        'target' => trim((string) ($match[2] ?? '')),
                        'amount' => trim((string) ($match[3] ?? '')),
                    ]
                );
            }
            if (preg_match('/^(.+?) reminded (.+?) to confirm receiving (.+?)\.$/u', $rawBody, $match) === 1) {
                return push_locale_format(
                    push_locale_phrase($locale, 'settlement_reminder_confirm_body'),
                    [
                        'actor' => trim((string) ($match[1] ?? '')),
                        'target' => trim((string) ($match[2] ?? '')),
                        'amount' => trim((string) ($match[3] ?? '')),
                    ]
                );
            }
            return push_locale_phrase($locale, 'settlement_reminder_body_generic');
        case 'settlement_auto_reminder':
            if (preg_match('/^Reminder: please mark (.+?) as sent to (.+?) in "(.+?)"\.$/u', $rawBody, $match) === 1) {
                return push_locale_format(
                    push_locale_phrase($locale, 'payment_reminder_body'),
                    [
                        'amount' => trim((string) ($match[1] ?? '')),
                        'target' => trim((string) ($match[2] ?? '')),
                        'trip' => trim((string) ($match[3] ?? '')),
                    ]
                );
            }
            if (preg_match('/^Reminder: please confirm receiving (.+?) from (.+?) in "(.+?)"\.$/u', $rawBody, $match) === 1) {
                return push_locale_format(
                    push_locale_phrase($locale, 'confirmation_reminder_body'),
                    [
                        'amount' => trim((string) ($match[1] ?? '')),
                        'payer' => trim((string) ($match[2] ?? '')),
                        'trip' => trim((string) ($match[3] ?? '')),
                    ]
                );
            }
            if (str_contains(strtolower($rawBody), 'confirm receiving')) {
                return push_locale_phrase($locale, 'confirmation_reminder_body_generic');
            }
            return push_locale_phrase($locale, 'payment_reminder_body_generic');
        case 'settlement_sent':
            if (preg_match('/^(.+?) marked (.+?) as sent to you\.$/u', $rawBody, $match) === 1) {
                return push_locale_format(
                    push_locale_phrase($locale, 'settlement_sent_body'),
                    [
                        'name' => trim((string) ($match[1] ?? '')),
                        'amount' => trim((string) ($match[2] ?? '')),
                    ]
                );
            }
            return push_locale_phrase($locale, 'settlement_sent_body_generic');
        case 'settlement_confirmed':
            if (preg_match('/^(.+?) confirmed receiving (.+?) from you\.$/u', $rawBody, $match) === 1) {
                return push_locale_format(
                    push_locale_phrase($locale, 'settlement_confirmed_body'),
                    [
                        'name' => trim((string) ($match[1] ?? '')),
                        'amount' => trim((string) ($match[2] ?? '')),
                    ]
                );
            }
            return push_locale_phrase($locale, 'settlement_confirmed_body_generic');
        default:
            return '';
    }
}

function push_locale_format(string $template, array $params): string
{
    if ($template === '' || !$params) {
        return $template;
    }

    $replace = [];
    foreach ($params as $key => $value) {
        $replace['{' . $key . '}'] = trim((string) $value);
    }

    return strtr($template, $replace);
}

function push_locale_phrase(string $locale, string $key): string
{
    static $catalogs = [];
    $locale = normalize_push_locale_code($locale);
    if (!array_key_exists($locale, $catalogs)) {
        $path = __DIR__ . '/locales/' . $locale . '.json';
        $json = is_file($path) ? file_get_contents($path) : false;
        $catalogs[$locale] = $json !== false ? (json_decode($json, true) ?? []) : [];
    }
    return (string) ($catalogs[$locale][$key] ?? '');
}
