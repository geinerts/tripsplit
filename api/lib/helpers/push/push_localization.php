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

    return 'en';
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
        case 'friend_invite_rejected':
            return push_locale_phrase($locale, 'friend_invite_rejected_title');
        case 'trip_added':
        case 'trip_member_added':
            return push_locale_phrase($locale, 'trip_added_title');
        case 'expense_added':
            return push_locale_phrase($locale, 'expense_added_title');
        case 'trip_finished':
            return push_locale_phrase($locale, 'trip_finished_title');
        case 'member_ready_to_settle':
            return push_locale_phrase($locale, 'member_ready_title');
        case 'trip_ready_to_settle':
            return push_locale_phrase($locale, 'trip_ready_title');
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
        case 'friend_invite_rejected':
            if (preg_match('/^(.+?) declined your friend invite\.$/u', $rawBody, $match) === 1) {
                return push_locale_format(
                    push_locale_phrase($locale, 'friend_invite_rejected_body'),
                    ['name' => trim((string) ($match[1] ?? ''))]
                );
            }
            return push_locale_phrase($locale, 'friend_invite_rejected_body_generic');
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
    static $phrases = [
        'lv' => [
            'friend_invite_title' => 'Drauga uzaicinājums',
            'friend_invite_body' => '{name} tev nosūtīja drauga uzaicinājumu.',
            'friend_invite_body_generic' => 'Tu saņēmi drauga uzaicinājumu.',
            'friend_invite_accepted_title' => 'Uzaicinājums apstiprināts',
            'friend_invite_accepted_body' => '{name} apstiprināja tavu drauga uzaicinājumu.',
            'friend_invite_accepted_body_generic' => 'Tavs drauga uzaicinājums tika apstiprināts.',
            'friend_invite_rejected_title' => 'Uzaicinājums noraidīts',
            'friend_invite_rejected_body' => '{name} noraidīja tavu drauga uzaicinājumu.',
            'friend_invite_rejected_body_generic' => 'Tavs drauga uzaicinājums tika noraidīts.',
            'trip_added_title' => 'Pievienots ceļojumam',
            'trip_added_body' => '{name} tevi pievienoja ceļojumam "{trip}".',
            'trip_added_body_generic' => 'Tu tiki pievienots ceļojumam.',
            'expense_added_title' => 'Pievienots jauns izdevums',
            'expense_added_body_trip' => '{name} pievienoja izdevumu {amount} ceļojumā "{trip}".',
            'expense_added_body_note' => '{name} pievienoja izdevumu {amount}: {note}',
            'expense_added_body_generic' => 'Pievienots jauns izdevums.',
            'trip_finished_title' => 'Ceļojums pabeigts',
            'trip_finished_body_settling' => '{name} pabeidza "{trip}". Norēķini ir gatavi.',
            'trip_finished_body_archived' => '{name} pabeidza "{trip}". Ceļojums ir arhivēts.',
            'trip_finished_body_generic' => 'Ceļojuma statuss tika atjaunināts.',
            'member_ready_title' => 'Dalībnieks atzīmēja gatavību',
            'member_ready_body' => '{name} ir gatavs norēķināties ceļojumā "{trip}".',
            'member_ready_body_generic' => 'Kāds dalībnieks ir gatavs norēķināties.',
            'trip_ready_title' => 'Visi dalībnieki ir gatavi',
            'trip_ready_body' => 'Visi dalībnieki atzīmēja gatavību ceļojumā "{trip}". Vari sākt norēķinus.',
            'trip_ready_body_generic' => 'Visi dalībnieki ir gatavi. Vari sākt norēķinus.',
            'settlement_reminder_title' => 'Atgādinājums par norēķinu',
            'settlement_reminder_mark_sent_body' => '{actor} atgādināja {target} atzīmēt {amount} kā nosūtītu.',
            'settlement_reminder_confirm_body' => '{actor} atgādināja {target} apstiprināt {amount} saņemšanu.',
            'settlement_reminder_body_generic' => 'Saņemts atgādinājums par norēķinu.',
            'payment_reminder_title' => 'Maksājuma atgādinājums',
            'payment_reminder_body' => 'Atgādinājums: lūdzu atzīmē {amount} kā nosūtītu lietotājam {target} ceļojumā "{trip}".',
            'payment_reminder_body_generic' => 'Atgādinājums: lūdzu atzīmē maksājumu kā nosūtītu.',
            'confirmation_reminder_title' => 'Apstiprinājuma atgādinājums',
            'confirmation_reminder_body' => 'Atgādinājums: lūdzu apstiprini {amount} saņemšanu no {payer} ceļojumā "{trip}".',
            'confirmation_reminder_body_generic' => 'Atgādinājums: lūdzu apstiprini maksājuma saņemšanu.',
            'settlement_sent_title' => 'Pārskaitījums atzīmēts kā nosūtīts',
            'settlement_sent_body' => '{name} atzīmēja {amount} kā nosūtītu tev.',
            'settlement_sent_body_generic' => 'Pārskaitījums tika atzīmēts kā nosūtīts.',
            'settlement_confirmed_title' => 'Pārskaitījums apstiprināts',
            'settlement_confirmed_body' => '{name} apstiprināja, ka saņēma {amount} no tevis.',
            'settlement_confirmed_body_generic' => 'Pārskaitījums tika apstiprināts.',
        ],
        'es' => [
            'friend_invite_title' => 'Invitación de amistad',
            'friend_invite_body' => '{name} te envió una invitación de amistad.',
            'friend_invite_body_generic' => 'Recibiste una invitación de amistad.',
            'friend_invite_accepted_title' => 'Invitación aceptada',
            'friend_invite_accepted_body' => '{name} aceptó tu invitación de amistad.',
            'friend_invite_accepted_body_generic' => 'Tu invitación de amistad fue aceptada.',
            'friend_invite_rejected_title' => 'Invitación rechazada',
            'friend_invite_rejected_body' => '{name} rechazó tu invitación de amistad.',
            'friend_invite_rejected_body_generic' => 'Tu invitación de amistad fue rechazada.',
            'trip_added_title' => 'Añadido al viaje',
            'trip_added_body' => '{name} te añadió al viaje "{trip}".',
            'trip_added_body_generic' => 'Fuiste añadido a un viaje.',
            'expense_added_title' => 'Nuevo gasto añadido',
            'expense_added_body_trip' => '{name} añadió un gasto de {amount} en "{trip}".',
            'expense_added_body_note' => '{name} añadió un gasto de {amount}: {note}',
            'expense_added_body_generic' => 'Se añadió un nuevo gasto.',
            'trip_finished_title' => 'Viaje finalizado',
            'trip_finished_body_settling' => '{name} finalizó "{trip}". Las liquidaciones están listas.',
            'trip_finished_body_archived' => '{name} finalizó "{trip}". El viaje está archivado.',
            'trip_finished_body_generic' => 'Se actualizó el estado del viaje.',
            'member_ready_title' => 'Miembro marcado como listo',
            'member_ready_body' => '{name} está listo para liquidar en "{trip}".',
            'member_ready_body_generic' => 'Un miembro está listo para liquidar.',
            'trip_ready_title' => 'Todos los miembros están listos',
            'trip_ready_body' => 'Todos los miembros se marcaron como listos en "{trip}". Puedes iniciar las liquidaciones.',
            'trip_ready_body_generic' => 'Todos los miembros están listos. Puedes iniciar las liquidaciones.',
            'settlement_reminder_title' => 'Recordatorio de liquidación',
            'settlement_reminder_mark_sent_body' => '{actor} recordó a {target} marcar {amount} como enviado.',
            'settlement_reminder_confirm_body' => '{actor} recordó a {target} confirmar la recepción de {amount}.',
            'settlement_reminder_body_generic' => 'Recibiste un recordatorio de liquidación.',
            'payment_reminder_title' => 'Recordatorio de pago',
            'payment_reminder_body' => 'Recordatorio: marca {amount} como enviado a {target} en "{trip}".',
            'payment_reminder_body_generic' => 'Recordatorio: marca el pago como enviado.',
            'confirmation_reminder_title' => 'Recordatorio de confirmación',
            'confirmation_reminder_body' => 'Recordatorio: confirma la recepción de {amount} de {payer} en "{trip}".',
            'confirmation_reminder_body_generic' => 'Recordatorio: confirma la recepción del pago.',
            'settlement_sent_title' => 'Transferencia marcada como enviada',
            'settlement_sent_body' => '{name} marcó {amount} como enviado para ti.',
            'settlement_sent_body_generic' => 'Se marcó una transferencia como enviada.',
            'settlement_confirmed_title' => 'Transferencia confirmada',
            'settlement_confirmed_body' => '{name} confirmó haber recibido {amount} de ti.',
            'settlement_confirmed_body_generic' => 'Se confirmó una transferencia.',
        ],
    ];

    return (string) (($phrases[$locale][$key] ?? ''));
}
