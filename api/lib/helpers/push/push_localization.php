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
    static $phrases = [
        'lv' => [
            'friend_invite_title' => 'Drauga uzaicinājums',
            'friend_invite_body' => '{name} tev nosūtīja drauga uzaicinājumu.',
            'friend_invite_body_generic' => 'Tu saņēmi drauga uzaicinājumu.',
            'friend_invite_accepted_title' => 'Uzaicinājums apstiprināts',
            'friend_invite_accepted_body' => '{name} apstiprināja tavu drauga uzaicinājumu.',
            'friend_invite_accepted_body_generic' => 'Tavs drauga uzaicinājums tika apstiprināts.',
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
            'payment_requested_title' => 'Pieprasīts maksājums',
            'payment_requested_body' => '{name} pieprasīja no tevis {amount}.',
            'payment_requested_body_generic' => 'Tu saņēmi maksājuma pieprasījumu.',
            'payment_request_sent_title' => 'Pieprasītais maksājums nosūtīts',
            'payment_request_sent_body' => '{name} atzīmēja tavu {amount} maksājuma pieprasījumu kā samaksātu.',
            'payment_request_sent_body_generic' => 'Tavs maksājuma pieprasījums atzīmēts kā samaksāts.',
            'payment_request_cancelled_title' => 'Maksājuma pieprasījums atcelts',
            'payment_request_cancelled_body' => '{name} atcēla {amount} maksājuma pieprasījumu.',
            'payment_request_cancelled_body_generic' => 'Maksājuma pieprasījums tika atcelts.',
            'payment_request_declined_title' => 'Maksājuma pieprasījums noraidīts',
            'payment_request_declined_body' => '{name} noraidīja tavu {amount} maksājuma pieprasījumu.',
            'payment_request_declined_body_generic' => 'Tavs maksājuma pieprasījums tika noraidīts.',
            'payment_sent_title' => 'Maksājums atzīmēts kā nosūtīts',
            'payment_sent_body' => '{name} atzīmēja {amount} kā samaksātu tev.',
            'payment_sent_body_generic' => 'Maksājums tika atzīmēts kā nosūtīts tev.',
            'payment_confirmed_title' => 'Maksājums apstiprināts',
            'payment_confirmed_body' => '{name} apstiprināja, ka saņēma {amount} no tevis.',
            'payment_confirmed_body_generic' => 'Tavs maksājums tika apstiprināts.',
            'payment_cancelled_title' => 'Maksājums atcelts',
            'payment_cancelled_body' => '{name} atcēla {amount} maksājuma atzīmi.',
            'payment_cancelled_body_generic' => 'Maksājuma atzīme tika atcelta.',
            'payment_not_received_title' => 'Maksājums nav saņemts',
            'payment_not_received_body' => '{name} atzīmēja {amount} maksājumu kā nesaņemtu.',
            'payment_not_received_body_generic' => 'Maksājums tika atzīmēts kā nesaņemts.',
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
            'payment_requested_title' => 'Pago solicitado',
            'payment_requested_body' => '{name} te solicitó {amount}.',
            'payment_requested_body_generic' => 'Has recibido una solicitud de pago.',
            'payment_request_sent_title' => 'Pago solicitado enviado',
            'payment_request_sent_body' => '{name} marcó tu solicitud de {amount} como pagada.',
            'payment_request_sent_body_generic' => 'Tu solicitud de pago fue marcada como pagada.',
            'payment_request_cancelled_title' => 'Solicitud de pago cancelada',
            'payment_request_cancelled_body' => '{name} canceló la solicitud de pago de {amount}.',
            'payment_request_cancelled_body_generic' => 'Se canceló una solicitud de pago.',
            'payment_request_declined_title' => 'Solicitud de pago rechazada',
            'payment_request_declined_body' => '{name} rechazó tu solicitud de pago de {amount}.',
            'payment_request_declined_body_generic' => 'Tu solicitud de pago fue rechazada.',
            'payment_sent_title' => 'Pago marcado como enviado',
            'payment_sent_body' => '{name} marcó {amount} como pagado para ti.',
            'payment_sent_body_generic' => 'Se marcó un pago como enviado para ti.',
            'payment_confirmed_title' => 'Pago confirmado',
            'payment_confirmed_body' => '{name} confirmó haber recibido {amount} de ti.',
            'payment_confirmed_body_generic' => 'Tu pago fue confirmado.',
            'payment_cancelled_title' => 'Pago cancelado',
            'payment_cancelled_body' => '{name} canceló la marca de pago de {amount}.',
            'payment_cancelled_body_generic' => 'Se canceló una marca de pago.',
            'payment_not_received_title' => 'Pago no recibido',
            'payment_not_received_body' => '{name} marcó el pago de {amount} como no recibido.',
            'payment_not_received_body_generic' => 'Se marcó un pago como no recibido.',
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
