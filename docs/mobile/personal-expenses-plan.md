# Personīgie izdevumi grupas ceļojumos: plāns

Statuss (2026-11-25): īpašnieks apstiprināja plānu un visus ieteikumus 8. sadaļā. 1.1.0 vēl
nebija iesniegta, tāpēc tas tiek būvēts tajā pašā versijā. Uzbūvēts lokāli: API līgums
`docs/api/personal-expenses.md`, migrācija `sql/migrations/2026-11-25-add-expense-is-personal.sql`,
serveris un lietotne. Nekas nav izvietots un migrācija nav palaista. Datums slēgtajā rindā paliek
API (saraksta kārtībai un lapošanai) un lietotnē rinda ir zem sava datuma virsraksta.

Sākotnējais plāns (2026-11-23) zemāk.

## Mērķis

Grupas ceļojumā cilvēks var pierakstīt savu personīgo izdevumu (suvenīri, sava kafija), lai
redzētu, cik kopā iztērējis, bet tas **neietekmē parādus** un neuzblīst grupas kopsummu.

## Apstiprinātais dizains (no sarunas)

1. Pievienot izdevumu: dalījuma metožu sarakstā jauna metode **Personal** (solo ceļojumos
   paslēpta). Izvēle atstāj "Split between" tikai maksātāju un bloķē pārējos. Ja izvēlas citu
   dalībnieku, metode pāriet atpakaļ uz Equal.
2. Jauns glabāts lauks `is_personal` uz izdevuma (API + DB). Vecie = false. Rediģējot
   personīgo izdevumu, metode paliek.
3. "Cienasts" (maksātājs maksā, dalībnieks tikai viņš, Equal) **nav** personīgs un skaitās
   grupas kopsummā kā tagad. Nekādas jaunas funkcijas.
4. Saraksts: personas ikona (`Icons.person_outline_rounded`, nevis ⚡) uz personīgajām rindām;
   filtrā jauna izvēle "Only personal", atsevišķi no kategorijām; maksātāja filtrs strādā.
5. Galvene: `Trip total` = grupas izdevumi bez personīgajiem; `Your share` nemainās (daļa no
   grupas kopsummas); jauna rinda tikai ja lietotājam ir personīgie: "Personal €X · Total
   spent €Y", kur Total spent = tava daļa + personīgie.
6. **Grozīts 2026-11-25:** citi dalībnieki redz personīgo izdevumu tikai kā **slēgtu rindu** ar
   atslēgas ikonu: teksts "Personal expense" + summa (+ maksātāja vārds, sk. 9. sadaļu). Nav
   kategorijas, piezīmes, čeka, komentāru, datuma, detaļu. Atvērt, labot, dzēst, komentēt var
   tikai maksātājs, un viņam rinda izskatās kā parasts izdevums ar personas ikonu. Tas ir
   servera noteikums, ne tikai lietotnes ekrāns (9. sadaļa).

## Kritiskais skatījums (lēmumiem pirms būvēšanas)

- **Cienasts pret personīgo gandrīz neatšķiras lietotājam.** Abiem ir viens dalībnieks. Atšķirība
  ir tikai tajā, vai skaitās grupas kopsummā. Tāpēc metodes aprakstā jābūt vienā teikumā:
  "Only you. Not in the trip total, no debts." Citādi cilvēki izvēlēsies nepareizo.
- **`is_personal` ir atvasināms no datiem tikai daļēji.** Pēc datiem nevar atšķirt cienastu no
  personīgā, tāpēc lauks tiešām vajadzīgs. Bet serverim jāsargā invariants:
  `is_personal = 1` ⇒ `participants = [paid_by]` un `split_mode = 'equal'`. Citādi vecā
  lietotne (kas lauku nesūta) varētu salauzt datus.
- **Maksātāja maiņa rediģējot.** Ja personīgam izdevumam maina "Paid by", dalībniekam jāseko
  maksātājam (lietotnē automātiski, serverī pārbaude). Citādi izdevums kļūst "personīgs" citam.
- **Slēgtā rinda** (6. punkts): cits dalībnieks redz tikai "Personal expense" un summu. Teksts
  nedrīkst solīt vairāk par to: summa un maksātājs paliek redzami, un tas ir atvērts jautājums 6.
- **Analītika un gada kopsavilkums** dod pretrunu: ja personīgie nav grupas kategoriju sadalījumā,
  bet ir "Total spent", cipari neies kopā. Ieteikums zemāk (7. un 8. sadaļa).
- **Vecās lietotnes (1.1.0 un agrāk)** personīgo izdevumu rāda kā Equal ar vienu dalībnieku,
  bez ikonas. Servera bilances to izslēdz, tāpēc parādi un galvenes kopsummas sakrīt. Izdevumu
  sarakstā vecā lietotne to tomēr rādīs, tātad saraksta rindu summa var pārsniegt galvenes
  `Trip total`. Pieņemams, bet jāpārbauda uz vecas lietotnes versijas pirms izlaišanas.

## 1. API un DB izmaiņas (jāapstiprina atsevišķi)

Jauns dokuments `docs/api/personal-expenses.md` (rakstīt pirmais, rādīt īpašniekam).

**Migrācija** `sql/migrations/2026-XX-XX-add-expense-is-personal.sql`:
`ALTER TABLE trip_expenses ADD COLUMN is_personal TINYINT(1) NOT NULL DEFAULT 0`
(prefikss pēc `table_name()`), plus `api/sql/schema.sql`. Indekss nav vajadzīgs
(filtrē pēc `trip_id`). Vecie = 0. Migrācija jāpalaiž **pirms** servera atjaunināšanas;
kods jātur atpakaļsaderīgs ar nemigrētu bāzi tāpat kā `trips_currency_column_available`
(kolonnas pieejamības pārbaude), lai deploy secība nav kritiska.

**`add_expense` / `update_expense`** (`api/lib/actions/expenses_actions.php`, ap 725 un 1021):
- jauns neobligāts `is_personal` (bool). Nav lauka add gadījumā = false.
- `update_expense` bez lauka: **saglabā esošo vērtību**, bet ja dalībnieki vairs nav
  `[paid_by]` vai metode nav `equal`, noņem karogu (vecā lietotne rediģē).
- Ja `is_personal = true`: serveris pats iestata `participants = [paid_by]`, `split_mode = equal`,
  ignorē `splits`/`items`. Kļūda 400 `Personal expenses cannot be shared.` ja klients sūta
  citus dalībniekus.
- Solo ceļojumā `is_personal` ignorē/noraida (`validate_solo_expense` jau ierobežo).

**Atbildes:** `list_expenses`, workspace snapshot (`workspace_actions.php` ap 194/236) un
`expenses_actions.php` ap 1311/1378 pievieno `is_personal` (bool) katram izdevumam.
`helper_quick_split_origin.php` ir paraugs, kā tiek pievienots `from_quick_split`.

**Workspace snapshot:** jauns lauks `personal_total_cents` (tikai pieprasītāja personīgie, ceļojuma
valūtā). Klientā to nevar saskaitīt, jo `snapshot.expenses` ir ierobežots (komentārs
`workspace_page_layout_overview.dart:6`). Tāpat `balances` jāatgriež **bez** personīgajiem
(sk. 2. sadaļu), tāpēc `Trip total` un `Your share` paliek pareizi bez klienta loģikas.

**Aktivitāte** (`docs/api/trip-activity.md`): `expense.created/updated` metadatiem pievienot
`is_personal`.

## 2. Kur tiek rēķinātas kopsummas (pilns saraksts)

| Vieta | Fails | Ko darīt |
| --- | --- | --- |
| Bilances un norēķini | `api/lib/actions/settlements/settlements_balance.php` (vaicājums `id, amount, paid_by`), `settlements_algorithm.php` `compute_balance_from_data` | Filtrēt `WHERE is_personal = 0`. Tad `paid`, `owed`, `net` un ieteiktie norēķini ir tikai grupas daļa. Personīgajam `paid = owed = amount`, tātad `net` tāpat nemainās, tests to pierāda. Šī ir **viena** vieta, kas ietekmē galveni, budžetu, norēķinus un PDF atskaiti. |
| Galvene `Trip total`, `Your share`, `You get back` | `workspace_page_layout_overview.dart` (`total` = Σ`paid`, `mine.owed`, `net`) | Bez izmaiņām aprēķinā (bilances jau bez personīgajiem). Pievienot rindu "Personal · Total spent" no `personal_total_cents`; Total spent = `mine.owed + personal`. Rinda tikai ja `personal_total_cents > 0`. Teksta mērogs, šauri ekrāni: tāda pati `LayoutBuilder` loģika kā metrikām. |
| Ceļojumu saraksts (trips lapa) | `api/lib/actions/trips_actions.php` ap 321–335 (`total_amount_cents`, `my_paid_cents`, `my_owed_cents`); `trips_page_widgets_hero.dart`, `trips_page_widgets_cards.dart` | Trīs apakšvaicājumiem pievienot `AND e.is_personal = 0`, citādi trips lapas "Your share" nesakritīs ar galveni. Personīgo rindu šeit nerādīt (atvērts jautājums 1). |
| Budžets | `trip_budget_card.dart`, tērētais nāk no pilnām bilancēm | Ņem no bilancēm, tātad būs **tikai grupas** izdevumi. Jāapstiprina ar īpašnieku (atvērts jautājums 2). |
| Analītika (kopsavilkums) | `helper_analytics_summary.php` (`analytics_trip_summary`, `analytics_summary_build`; vaicājums ap 123), klienta `analytics_page_*.dart` | Grupas rādītāji (`Trip total`, `Your share`, kategorijas, lielākie) bez personīgajiem. Pievienot `personal_cents` atsevišķi un vienu rindu analītikā. Jāatjauno `docs/api/analytics-summary.md` un fixtūra `api/tests/Fixtures/analytics_summary.php`. |
| Gada kopsavilkums | `helper_year_summary.php` ap 83 (`sharesStmt` savieno ar dalībniekiem) | Personīgie šeit **jau automātiski ieskaitās** (maksātājs ir dalībnieks ar `owed`). Tas ir pareizi ("cik tu iztērēji"), bet jāpārbauda, vai gribam. Ieteikums: atstāt iekļautus, pievienot testu, lai tas nemainās nejauši. |
| PDF/e-pasta atskaite | `helper_trip_report.php` (`trip_report_load`: kopsumma ap 168, kategorijas, izdevumu rindas, `compute_trip_balance_data`), `helper_trip_report_render.php`, `trip_report_locales/*` | Grupas kopsumma un kategorijas bez personīgajiem; personas bilance no bilancēm. Personīgos rādīt atsevišķā sadaļā "Personal expenses (not in debts)" ar tekstu 16 valodās. **Saskaņot ar sesiju trip-report-pdf-premium**, jo tā maina to pašu failu. |
| Quick split | `quick_splits_actions.php`, `workspace_quick_split_form.dart`, `docs/api/quick-splits.md` | Quick split nav ceļojuma; metode Personal tur nav. Kad Quick split pievieno ceļojumam, `is_personal = false`. Jānodrošina, ka metodes saraksts ar `ExpenseTarget.quickSplit()` Personal nerāda. |
| Paziņojumi `expense_added` | `expenses_actions.php` ap 819–850 | Saņēmēji ir dalībnieki, kas nav maksātājs un nav lietotājs. Personīgajam dalībnieks ir tikai maksātājs, tātad **nevienam nenāk**. Izmaiņu nav, bet jāpievieno tests, ka personīgais negenerē paziņojumu ne push, ne sarakstā. Paziņojumu kataloga teksti nemainās. |
| Aktivitātes plūsma (`app_event`) | `expenses_actions.php` ap 876 | Pievienot `is_personal` metadatos. Klienta `workspace_page_tab_activity.dart` parāda rindu kā līdz šim; teksts nemainās. |
| Admin panelis | `admin_panel_actions.php` | Pārbaudīt, vai tur ir izdevumu summas; ja ir, nekas nav jāmaina (administratīva statistika), jāapstiprina ar grep pirms būvēšanas. |
| Konta dzēšana | `account_lifecycle_actions.php` | Ja dzēšot kontu izdevumi tiek pārvietoti/noņemti, personīgie izdevumi seko tam pašam noteikumam. Jāpārbauda, ka karogs netiek zaudēts. |
| Bezsaistes rinda | `workspace_offline_queue.dart`, `workspace_page_actions_queue.dart`, `queued_expense_math.dart`, `workspace_pending_snapshot.dart` | Rindā jāglabā `is_personal`; pending izdevumi jārāda ar ikonu; pending snapshot nedrīkst personīgos iekļaut galvenes `Trip total` pagaidu aprēķinā. |
| Lokālais kešs | `workspace_snapshot_codec.dart` (ap 153, 359) | Serializēt/parsēt `is_personal` un `personal_total_cents`; vecs kešs bez lauka = false/0. Konta izolācija nemainās. |

## 3. Mobilā lietotne

- `trip_expense.dart`: `isPersonal` (default false). `expense_draft.dart`: `isPersonal`.
  Parsers `workspace_remote_parsers.dart` (ap 239), mutācijas `workspace_remote_mutation_api.dart`,
  `workspace_remote_data_source.dart`, repozitorijs.
- Forma (`workspace_page_expense_editors.dart` ap 687 `_modeOptions`, `_selectMode`,
  `workspace_expense_form_setup.dart` ap 76–126): jauna opcija `personal` (nav API
  `split_mode` vērtība, tāpēc mutācija sūta `split_mode: equal` + `is_personal: true`).
  - Nerādīt solo ceļojumos un Quick split.
  - Izvēloties: `participants = {payer}`, citi dalībnieki bloķēti (atspējoti čipi).
  - Pieskaroties citam dalībniekam: metode → Equal (karogs nokrīt), dalībnieks pievienots.
  - Maksātāja maiņa personīgā režīmā: dalībnieks seko maksātājam.
  - Rediģēšana: sākuma metode `personal`, ja `expense.isPersonal`.
  - Receipt AI ("Fill from receipt"): nemainīt metodi, ko lietotājs izvēlējies.
- Saraksts (`workspace_page_tab_expenses.dart`): ikona līdzīgi `_withQuickSplitMark`
  (ap 1063), ar `semanticLabel`. Ja izdevums ir gan Quick split, gan personīgs (nevar notikt),
  netiek apstrādāts.
- Filtrs: `_ExpenseFilterMenu` (ap 695–930) jauna rinda "Only personal" ar pārslēdzamu
  stāvokli, ne kategoriju apakšlapa. Saskaņā ar esošo izkārtojumu: `ValueKey('expense-filter-personal-row')`,
  iekļauta "Clear filters". Filtrs darbojas kopā ar maksātāja un kategorijas filtru.
  "Only personal" rāda tikai **paša** personīgos (citu slēgtās rindas filtrā neparādās, jo tur
  nav ko skatīt). Maksātāja filtrs citam maksātājam rāda viņa slēgtās rindas kā parasti.
- Detaļu skats (`workspace_page_actions_expenses_details.dart`, `..._sheet.dart` ap 40): metodes
  etiķete "Personal", ikona, skaidrojums "Not in the trip total. Does not affect debts."
- Galvene: sk. 2. sadaļu.
- Analītika: viena papildu rinda.

## 4. Lokalizācija (16 lokāles)

ARB avoti `mobile/lib/l10n/app_*.arb` (en, lv, de, es, fr, it, nl, pl, pt, ru, uk, cs, da, fi,
nb, sv; precīzi pārbaudīt pēc faila skaita) un `flutter gen-l10n` (docs/mobile/localization.md).
Jaunas atslēgas (nosaukumi provizoriski):

| Atslēga | EN teksts |
| --- | --- |
| `expenseSplitPersonal` | Personal |
| `expenseSplitPersonalHint` | Only you. Not in the trip total, no debts. |
| `expenseFilterOnlyPersonal` | Only personal |
| `expensePersonalLabel` | Personal expense (semantics ikonai) |
| `expensePersonalDetailsNote` | Visible to everyone in the trip. Does not affect debts. |
| `workspacePersonalSpentLine` | Personal {personal} · Total spent {total} (placeholderi `personal`, `total`) |
| `analyticsPersonalLine` | Personal (not in group totals) |
| `tripReportPersonalSection` | Personal expenses (not in debts) |

Servera puses PDF teksti: `api/lib/helpers/trip_report_locales/*` (atsevišķi no ARB, ja
atskaite to rāda). Push katalogs netiek mainīts. Tulkojumus pārskatīt tāpat kā pēdējo
tulkojumu pārskatu (`docs/mobile/localization-review`), īpaši LV: "Personīgs izdevums" nevis
"Personisks".

## 5. Testi

PHP (`api/tests/Unit`): jauns `PersonalExpenseTest.php`
- invariants (personal ⇒ participants=[payer], equal); noraida citus dalībniekus;
  solo ceļojums; `update_expense` bez lauka saglabā karogu, bet noņem, ja dalībnieki mainīti;
  vecais klients bez lauka.
- bilances: ar un bez personīgā `net` un ieteiktie norēķini identiski; `paid`/`owed` bez personīgā.
- `trips_actions` kopsumma/daļa; analītika (fixtūra), gada kopsavilkums (personīgie ieskaitīti),
  PDF atskaite (atsevišķa sadaļa), budžets.
- paziņojumi: personīgais nerada `expense_added`.
- nemigrēta DB: izdevumi strādā, `is_personal` = false.

Flutter (`mobile/test/features/workspace`): forma (izvēle, bloķēšana, pāreja uz Equal, solo un
Quick split bez opcijas, rediģēšana saglabā metodi, maksātāja maiņa); filtrs (Only personal +
maksātājs + kategorija, Clear); galvenes rinda (rāda tikai ja ir personīgie, 320 px, 200%
teksts, tumšais režīms); parsers/kodeks/bezsaistes rinda; widget tests ar EN/LV. `flutter analyze`
un `dart format` tikai mainītajiem failiem. Integrācijas tests tikai ja ir ierīce un
nelīvēta konfigurācija.

## 6. Secība

1. Īpašnieks apstiprina šo plānu un `docs/api/personal-expenses.md`. **Šajā brīdī 1.1.0 jau ir
   izgājusi App Review.**
2. Migrācija + serveris (atpakaļsaderīgs, nemigrētai bāzei): `is_personal` lauks, invarianti,
   bilances filtrs, trips saraksts, analītika, atskaite, snapshot lauki, testi. Migrāciju
   palaist, tad deploy (prefikss un secība pēc `project-deploy-and-secrets`).
3. Lietotne: modelis/parsers/kodeks/rinda, forma, saraksts, filtrs, galvene, analītika, ARB.
4. Pārbaude uz ierīces pret testa serveri: pievienot, rediģēt, bezsaistē, filtrs, galvene,
   vecs konts ar veciem izdevumiem.
5. Versijas izlaišana: tikai pēc 1.1.0 apstiprināšanas; sasaistīt ar nākamo atjauninājumu
   (`docs/mobile/next-update-plan.md`), nepalaist citu izdevumu darbu paralēli ar to pašu
   formu.
6. Serveri drīkst atjaunināt pirms lietotnes: bilances filtrs bez personīgajiem datiem neko
   nemaina. Lietotni izlaist tikai pēc servera.

## 7. Riski

- **Bilances filtrs ir kritiskākā izmaiņa:** kļūda sabojā norēķinus. Jāpārklāj ar testu, kas
  salīdzina `net` ar un bez personīgajiem uz reāliem fixtūru datiem.
- Invarianta pārkāpums no vecās lietotnes (sk. kritisko skatījumu).
- Ceļojumi, kas jau noslēgti/norēķinās: personīgo pievienošana pēc `settling` jāatļauj tikai
  kā līdz šim (esošie noteikumi par izdevumu pievienošanu).
- Divu vietu pretrunas (trips lapa, analītika, atskaite, budžets): vienmēr jābūt vienam
  noteikumam "grupas skaitļi bez personīgajiem". Nodrošina viens kopīgs servera nosacījums.
- Atskaite un tulkojumi aizņem visvairāk laika (16 valodas gan lietotnē, gan serverī).
- Ja vēlāk nāks "dalībnieki bez konta" (`project-unregistered-trip-members`), personīgie var
  būt tikai maksātājam ar kontu; šobrīd nav konflikta.

## 9. Slēgtā rinda citiem (pievienots 2026-11-25)

**Galvenais:** slēgt tikai lietotnes ekrānā nepietiek. Visi dati, ko serveris atdod citiem
dalībniekiem, ir jāaizvieto serverī, citādi kategorija, piezīme un čeks paliek lasāmi
atbildē (un vecā lietotne tos parādītu). Noteikums: ja `is_personal = 1` un pieprasītājs
nav maksātājs, serveris atdod tikai
`{id, is_personal: true, locked: true, amount, paid_by_id, paid_by_nickname}`. Pārējie lauki
(`category`, `note`, `receipt`, `expense_date`, `participants`, `split_mode`, `items`, valūtas
dati) tiek izlaisti vai nullēti. Viena kopīga funkcija `redact_personal_expense_row()`,
ko izsauc visas vietas zemāk, lai nevienu neaizmirstu.

Vietas, kur jāpiemēro redakcija:

| Vieta | Darīt |
| --- | --- |
| `list_expenses`, workspace snapshot (`expenses_actions.php` ap 1311, `workspace_actions.php` ap 194) | Redakcija citiem. Maksātājam pilna rinda. |
| Viena izdevuma lasīšana / detaļas / `update_expense` / `delete_expense` (ap 946, 1217) | Jau tikai maksātājs (`trip_actor_acts_for`); citam 403 `Personal expense is locked.` |
| Komentāri un pieminēšanas (`expense_social_actions.php`) | Citam 403 uz personīgā izdevuma komentāriem; komentāru skaitu nerādīt. |
| Čeka multivide (`receipt-media.php`, `helper_receipt_ownership.php`) | Čeku atdod tikai maksātājam. |
| Aktivitātes plūsma (`trip-activity.md`, `app_event`) | Citiem notikumu rāda kā "Personal expense" + summa, bez `category`, `note`, `split_mode`. Maksātājam kā parasti. |
| PDF/e-pasta atskaite | Citu personīgie: tikai "Personal expense" + summa vai nav vispār (jautājums 3). |
| Analītika, gada kopsavilkums | Skaita tikai pieprasītāja paša personīgos; citu nekad. |
| Meklēšana/filtri klientā | Slēgtajai rindai nav kategorijas, tāpēc kategoriju filtrs to neiekļauj; paliek tikai maksātāja filtrs. |
| Lokālais kešs un bezsaistes snapshot | Kešo to, ko serveris atdeva (jau redaktēts), nekad nepieprasīt pilnu citu rindu. |
| Vecās lietotnes | Redaktētā rinda tiem izskatās kā izdevums ar tukšu kategoriju/piezīmi; atvēršana atgriež 403. Serveris jāatjaunina vispirms, un jānotestē uz 1.1.0 versijas, vai neavarē (piem. null kategorija). Ja avarē, servera redakcijā jāliek drošas vietturu vērtības (`category: "other"`, `note: "Personal expense"`, `expense_date` = izveides diena, `participants: []`). |

Mobilā lietotne:
- `TripExpense`: `isLocked` (= personīgs un nav mans). Slēgtā rinda: atslēgas ikona
  (`Icons.lock_outline_rounded`), nosaukums "Personal expense", summa, maksātāja vārds; bez
  kategorijas ikonas, pieskāriens neatver detaļas (vai īss paskaidrojums, ka tas ir slēgts).
- Mans personīgais: personas ikona, pilns skats kā parasti.
- Detaļu skatā "Personal. Others see only the amount. Does not affect debts."
- Slēgtā rinda nav rediģējama, nav komentējama, nav koplietojama.

Testi: PHP, ka citam nekur neatnāk `category`/`note`/`receipt_path`/`participants` (list,
snapshot, aktivitāte, atskaite, komentāri 403, čeks 403, update/delete 403); ka maksātājam
viss kā parasti; Flutter, ka slēgtā rinda nav atverama un nerāda kategoriju.

Kritiski: summas rādīšana citiem nedod nekādu labumu parādiem, jo personīgie nav bilancē un nav
kopsummā. Tā ir tikai pārredzamība ("kāds kaut ko nopirka"). Ja to nevajag, vienkāršāk un
drošāk citiem rindu **nerādīt vispār**: mazāk koda, nav jāpaskaidro, kāpēc ir rinda, kuru nevar
atvērt. Bet vienkāršāk nozīmē arī, ka sarakstā "pazūd" naudas posteņi; tāpēc atstāts
īpašnieka lēmumam (jautājums 6).

## 8. Atvērti jautājumi īpašniekam

1. Vai ceļojumu saraksta kartītē (trips lapa) rādīt personīgos? Ieteikums: nē, tikai grupas.
2. Vai budžets skaita tikai grupas izdevumus? Ieteikums: jā, bet pieminēt budžeta kartītē
   tekstu "group expenses".
3. Vai analītikā un atskaitē personīgos rādīt atsevišķi? Ieteikums: jā, viena rinda/sadaļa.
4. Vai gada kopsavilkumā personīgie ieskaitās "tavā daļā"? Ieteikums: jā.
5. Vai metodes saraksta pozīcija ir pēdējā? Ieteikums: pēdējā, lai Equal paliek pirmā.
6. Slēgtajā rindā citiem: vai rādīt arī **maksātāja vārdu** un **summu**, vai pat rindu nerādīt?
   Ieteikums: "Personal expense" + summa + vārds. Datumu nerādīt.
7. Vai ceļojuma veidotājs drīkst dzēst citu personīgo izdevumu (kā citus izdevumus)? Ieteikums:
   nē, tikai maksātājs (šobrīd arī parastajiem izdevumiem ir `trip_actor_acts_for`).
8. Jauns ARB: `expenseLockedPersonal` ("Personal expense"), `expenseLockedExplain`
   ("Only the person who added it can open this."), `expenseLockedIconLabel`; pievienot sadaļas 4
   tabulai.
