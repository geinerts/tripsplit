<?php
declare(strict_types=1);

/**
 * Words on the shared quick split page (/split), in the same languages as the other share
 * pages. `{name}` and `{total}` are filled in by split.php.
 */
const SPLYTO_SPLIT_PAGE_TEXT = [
    'en' => [
        'title_fallback' => 'Shared bill',
        'paid_by' => 'Paid by {name}',
        'total' => 'Total',
        'who_pays' => 'Who pays what',
        'everyone' => 'Everyone',
        'paid' => 'Paid',
        'items' => 'Items',
        'shared' => 'Shared',
        'extra' => 'Other costs',
        'receipt' => 'Receipt',
        'view' => 'View',
        'close' => 'Close',
        'cta' => 'Split bills with friends in SPLYTO',
        'not_shared' => 'This bill is no longer shared.',
        'og_title' => '{name} shared a bill: {total}',
        'og_description' => 'See your share',
    ],
    'lv' => [
        'title_fallback' => 'Kopīgs rēķins',
        'paid_by' => 'Samaksāja {name}',
        'total' => 'Kopā',
        'who_pays' => 'Kurš cik maksā',
        'everyone' => 'Visi',
        'paid' => 'Samaksāja',
        'items' => 'Pozīcijas',
        'shared' => 'Kopīgi',
        'extra' => 'Citas izmaksas',
        'receipt' => 'Čeks',
        'view' => 'Skatīt',
        'close' => 'Aizvērt',
        'cta' => 'Dali rēķinus ar draugiem SPLYTO',
        'not_shared' => 'Šis rēķins vairs netiek kopīgots.',
        'og_title' => '{name} kopīgoja rēķinu: {total}',
        'og_description' => 'Apskati savu daļu',
    ],
    'de' => [
        'title_fallback' => 'Geteilte Rechnung',
        'paid_by' => 'Bezahlt von {name}',
        'total' => 'Gesamt',
        'who_pays' => 'Wer zahlt was',
        'everyone' => 'Alle',
        'paid' => 'Bezahlt',
        'items' => 'Positionen',
        'shared' => 'Geteilt',
        'extra' => 'Weitere Kosten',
        'receipt' => 'Beleg',
        'view' => 'Ansehen',
        'close' => 'Schließen',
        'cta' => 'Teile Rechnungen mit Freunden in SPLYTO',
        'not_shared' => 'Diese Rechnung wird nicht mehr geteilt.',
        'og_title' => '{name} hat eine Rechnung geteilt: {total}',
        'og_description' => 'Sieh dir deinen Anteil an',
    ],
    'es' => [
        'title_fallback' => 'Cuenta compartida',
        'paid_by' => 'Pagó {name}',
        'total' => 'Total',
        'who_pays' => 'Quién paga qué',
        'everyone' => 'Todos',
        'paid' => 'Pagó',
        'items' => 'Artículos',
        'shared' => 'Compartido',
        'extra' => 'Otros gastos',
        'receipt' => 'Recibo',
        'view' => 'Ver',
        'close' => 'Cerrar',
        'cta' => 'Divide cuentas con amigos en SPLYTO',
        'not_shared' => 'Esta cuenta ya no se comparte.',
        'og_title' => '{name} compartió una cuenta: {total}',
        'og_description' => 'Mira tu parte',
    ],
    'fr' => [
        'title_fallback' => 'Addition partagée',
        'paid_by' => 'Payé par {name}',
        'total' => 'Total',
        'who_pays' => 'Qui paie quoi',
        'everyone' => 'Tout le monde',
        'paid' => 'A payé',
        'items' => 'Articles',
        'shared' => 'Partagé',
        'extra' => 'Autres frais',
        'receipt' => 'Ticket',
        'view' => 'Voir',
        'close' => 'Fermer',
        'cta' => 'Partagez les additions entre amis avec SPLYTO',
        'not_shared' => "Cette addition n'est plus partagée.",
        'og_title' => '{name} a partagé une addition : {total}',
        'og_description' => 'Voir votre part',
    ],
    'it' => [
        'title_fallback' => 'Conto condiviso',
        'paid_by' => 'Pagato da {name}',
        'total' => 'Totale',
        'who_pays' => 'Chi paga cosa',
        'everyone' => 'Tutti',
        'paid' => 'Ha pagato',
        'items' => 'Voci',
        'shared' => 'Condiviso',
        'extra' => 'Altri costi',
        'receipt' => 'Scontrino',
        'view' => 'Vedi',
        'close' => 'Chiudi',
        'cta' => 'Dividi i conti con gli amici su SPLYTO',
        'not_shared' => 'Questo conto non è più condiviso.',
        'og_title' => '{name} ha condiviso un conto: {total}',
        'og_description' => 'Guarda la tua quota',
    ],
    'pt' => [
        'title_fallback' => 'Conta partilhada',
        'paid_by' => 'Pago por {name}',
        'total' => 'Total',
        'who_pays' => 'Quem paga o quê',
        'everyone' => 'Todos',
        'paid' => 'Pagou',
        'items' => 'Artigos',
        'shared' => 'Partilhado',
        'extra' => 'Outros custos',
        'receipt' => 'Recibo',
        'view' => 'Ver',
        'close' => 'Fechar',
        'cta' => 'Divide contas com amigos no SPLYTO',
        'not_shared' => 'Esta conta já não está partilhada.',
        'og_title' => '{name} partilhou uma conta: {total}',
        'og_description' => 'Vê a tua parte',
    ],
    'pl' => [
        'title_fallback' => 'Wspólny rachunek',
        'paid_by' => 'Zapłacił(a) {name}',
        'total' => 'Razem',
        'who_pays' => 'Kto ile płaci',
        'everyone' => 'Wszyscy',
        'paid' => 'Zapłacił(a)',
        'items' => 'Pozycje',
        'shared' => 'Wspólne',
        'extra' => 'Inne koszty',
        'receipt' => 'Paragon',
        'view' => 'Zobacz',
        'close' => 'Zamknij',
        'cta' => 'Dziel rachunki ze znajomymi w SPLYTO',
        'not_shared' => 'Ten rachunek nie jest już udostępniany.',
        'og_title' => '{name} udostępnił(a) rachunek: {total}',
        'og_description' => 'Zobacz swoją część',
    ],
    'nl' => [
        'title_fallback' => 'Gedeelde rekening',
        'paid_by' => 'Betaald door {name}',
        'total' => 'Totaal',
        'who_pays' => 'Wie betaalt wat',
        'everyone' => 'Iedereen',
        'paid' => 'Betaalde',
        'items' => 'Items',
        'shared' => 'Gedeeld',
        'extra' => 'Overige kosten',
        'receipt' => 'Bon',
        'view' => 'Bekijken',
        'close' => 'Sluiten',
        'cta' => 'Deel rekeningen met vrienden in SPLYTO',
        'not_shared' => 'Deze rekening wordt niet meer gedeeld.',
        'og_title' => '{name} deelde een rekening: {total}',
        'og_description' => 'Bekijk je deel',
    ],
    'sv' => [
        'title_fallback' => 'Delad nota',
        'paid_by' => 'Betalad av {name}',
        'total' => 'Totalt',
        'who_pays' => 'Vem betalar vad',
        'everyone' => 'Alla',
        'paid' => 'Betalade',
        'items' => 'Artiklar',
        'shared' => 'Delad',
        'extra' => 'Övriga kostnader',
        'receipt' => 'Kvitto',
        'view' => 'Visa',
        'close' => 'Stäng',
        'cta' => 'Dela notor med vänner i SPLYTO',
        'not_shared' => 'Den här notan delas inte längre.',
        'og_title' => '{name} delade en nota: {total}',
        'og_description' => 'Se din del',
    ],
    'da' => [
        'title_fallback' => 'Delt regning',
        'paid_by' => 'Betalt af {name}',
        'total' => 'I alt',
        'who_pays' => 'Hvem betaler hvad',
        'everyone' => 'Alle',
        'paid' => 'Betalte',
        'items' => 'Varer',
        'shared' => 'Delt',
        'extra' => 'Andre omkostninger',
        'receipt' => 'Kvittering',
        'view' => 'Se',
        'close' => 'Luk',
        'cta' => 'Del regninger med venner i SPLYTO',
        'not_shared' => 'Denne regning deles ikke længere.',
        'og_title' => '{name} delte en regning: {total}',
        'og_description' => 'Se din del',
    ],
    'nb' => [
        'title_fallback' => 'Delt regning',
        'paid_by' => 'Betalt av {name}',
        'total' => 'Totalt',
        'who_pays' => 'Hvem betaler hva',
        'everyone' => 'Alle',
        'paid' => 'Betalte',
        'items' => 'Varer',
        'shared' => 'Delt',
        'extra' => 'Andre kostnader',
        'receipt' => 'Kvittering',
        'view' => 'Vis',
        'close' => 'Lukk',
        'cta' => 'Del regninger med venner i SPLYTO',
        'not_shared' => 'Denne regningen deles ikke lenger.',
        'og_title' => '{name} delte en regning: {total}',
        'og_description' => 'Se din del',
    ],
    'fi' => [
        'title_fallback' => 'Jaettu lasku',
        'paid_by' => 'Maksaja: {name}',
        'total' => 'Yhteensä',
        'who_pays' => 'Kuka maksaa mitä',
        'everyone' => 'Kaikki',
        'paid' => 'Maksoi',
        'items' => 'Tuotteet',
        'shared' => 'Jaettu',
        'extra' => 'Muut kulut',
        'receipt' => 'Kuitti',
        'view' => 'Näytä',
        'close' => 'Sulje',
        'cta' => 'Jaa laskut ystävien kanssa SPLYTOssa',
        'not_shared' => 'Tätä laskua ei enää jaeta.',
        'og_title' => '{name} jakoi laskun: {total}',
        'og_description' => 'Katso osuutesi',
    ],
    'cs' => [
        'title_fallback' => 'Sdílený účet',
        'paid_by' => 'Zaplatil(a) {name}',
        'total' => 'Celkem',
        'who_pays' => 'Kdo platí kolik',
        'everyone' => 'Všichni',
        'paid' => 'Zaplatil(a)',
        'items' => 'Položky',
        'shared' => 'Společné',
        'extra' => 'Další náklady',
        'receipt' => 'Účtenka',
        'view' => 'Zobrazit',
        'close' => 'Zavřít',
        'cta' => 'Dělte účty s přáteli v SPLYTO',
        'not_shared' => 'Tento účet už není sdílený.',
        'og_title' => '{name} sdílel(a) účet: {total}',
        'og_description' => 'Podívej se na svůj podíl',
    ],
    'ru' => [
        'title_fallback' => 'Общий счёт',
        'paid_by' => 'Оплатил(а) {name}',
        'total' => 'Итого',
        'who_pays' => 'Кто сколько платит',
        'everyone' => 'Все',
        'paid' => 'Оплатил(а)',
        'items' => 'Позиции',
        'shared' => 'Общее',
        'extra' => 'Прочие расходы',
        'receipt' => 'Чек',
        'view' => 'Открыть',
        'close' => 'Закрыть',
        'cta' => 'Делите счета с друзьями в SPLYTO',
        'not_shared' => 'Этот счёт больше не доступен по ссылке.',
        'og_title' => '{name} поделился(-ась) счётом: {total}',
        'og_description' => 'Посмотрите свою долю',
    ],
    'uk' => [
        'title_fallback' => 'Спільний рахунок',
        'paid_by' => 'Оплатив(ла) {name}',
        'total' => 'Разом',
        'who_pays' => 'Хто скільки платить',
        'everyone' => 'Усі',
        'paid' => 'Оплатив(ла)',
        'items' => 'Позиції',
        'shared' => 'Спільне',
        'extra' => 'Інші витрати',
        'receipt' => 'Чек',
        'view' => 'Переглянути',
        'close' => 'Закрити',
        'cta' => 'Діліть рахунки з друзями в SPLYTO',
        'not_shared' => 'Цей рахунок більше не доступний за посиланням.',
        'og_title' => '{name} поділився(-лася) рахунком: {total}',
        'og_description' => 'Перегляньте свою частку',
    ],
];

/** Language keys the share pages use, mapped to a locale for numbers and dates. */
const SPLYTO_SPLIT_PAGE_LOCALES = [
    'en' => 'en_GB', 'lv' => 'lv_LV', 'de' => 'de_DE', 'es' => 'es_ES', 'fr' => 'fr_FR',
    'it' => 'it_IT', 'pt' => 'pt_PT', 'pl' => 'pl_PL', 'nl' => 'nl_NL', 'sv' => 'sv_SE',
    'da' => 'da_DK', 'nb' => 'nb_NO', 'fi' => 'fi_FI', 'cs' => 'cs_CZ', 'ru' => 'ru_RU',
    'uk' => 'uk_UA',
];

function splyto_split_text(string $language, string $key, array $values = []): string
{
    $text = SPLYTO_SPLIT_PAGE_TEXT[$language][$key] ?? SPLYTO_SPLIT_PAGE_TEXT['en'][$key] ?? $key;
    foreach ($values as $name => $value) {
        $text = str_replace('{' . $name . '}', (string) $value, $text);
    }
    return $text;
}

function splyto_split_money(int $cents, string $currency, string $language): string
{
    $locale = SPLYTO_SPLIT_PAGE_LOCALES[$language] ?? 'en_GB';
    $noDecimals = defined('CURRENCY_CODES_WITHOUT_DECIMALS') && in_array($currency, CURRENCY_CODES_WITHOUT_DECIMALS, true);
    if (class_exists('NumberFormatter')) {
        $formatter = new NumberFormatter($locale, NumberFormatter::CURRENCY);
        if ($noDecimals) {
            $formatter->setAttribute(NumberFormatter::FRACTION_DIGITS, 0);
        }
        $out = $formatter->formatCurrency($cents / 100, $currency);
        if (is_string($out) && $out !== '') {
            return $out;
        }
    }
    return $currency . ' ' . number_format($cents / 100, $noDecimals ? 0 : 2, '.', ' ');
}

function splyto_split_date(string $date, string $language): string
{
    $time = strtotime($date . ' 12:00:00 UTC');
    if ($time === false) {
        return $date;
    }
    if (class_exists('IntlDateFormatter')) {
        $formatter = new IntlDateFormatter(
            SPLYTO_SPLIT_PAGE_LOCALES[$language] ?? 'en_GB',
            IntlDateFormatter::MEDIUM,
            IntlDateFormatter::NONE,
            'UTC'
        );
        $out = $formatter->format($time);
        if (is_string($out) && $out !== '') {
            return $out;
        }
    }
    return gmdate('j M Y', $time);
}
