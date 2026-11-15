# Nākamais atjauninājums: ceļojuma atgādinājums, PDF čeki, avāriju žurnāli un atzīmes

Statuss: plāns, īpašnieks apstiprinājis virzienu 2026-11-13. Kods, API un datubāze vēl nav
mainīti. Visus darbus ieviest vienā atjauninājumā, ko izlaiž gan iOS, gan Android.

Sagatavots kopā ar Android pirmo Play iesniegšanu. Tur Data safety tika iesniegts **bez**
"Files and docs" (čeki ir tikai attēli), tāpēc pēc B darba forma jāatjauno.

## A. Atgādinājums dienu pirms ceļojuma (servera push)

### Mērķis

Dienu pirms ceļojuma sākuma visi tā aktīvie dalībnieki saņem push paziņojumu "Rīt sākas
ceļojums X". Nav kalendāra atļaujas, un tas strādā arī tad, ja lietotne nav atvērta.

### Kas jau ir

- `trips.date_from` var būt aizpildīts, `date_to` var būt tukšs (`docs/api/trip-dates.md`).
- Push paziņojumi ir sadalīti 9 kategorijās (`docs/api/push-notification-categories.md`).
  Kategorija `reminders` (`push_reminders_enabled`) jau pastāv norēķinu atgādinājumiem.
- Atgādinājumu skripta paraugs ir `scripts/run_settlement_reminders.php` ar `--dry-run`,
  `--limit` un heartbeat (`docs/operations/job-heartbeats.md`).
- Push piegāde jau ir (`scripts/run_push_delivery.php`, FCM un APNs), tātad abām platformām
  nekas jauns nav jāpievieno.

### Ieteicamais risinājums

1. **Jauns paziņojuma veids** `trip_starts_tomorrow`. Tas ietilpst esošajā kategorijā
   `reminders`, tāpēc **jauna slēdža un migrācijas preferencēm nav**. Ja lietotājs ir
   izslēdzis atgādinājumus, šis arī nenāk.
2. **Skripts** `scripts/run_trip_start_reminders.php` pēc `run_settlement_reminders.php`
   parauga: atrod ceļojumus, kuriem `date_from` ir rīt, kas nav pabeigti, un katram aktīvam
   dalībniekam izveido paziņojumu. Ar `--dry-run`, `--limit` un heartbeat
   `trip_start_reminders`.
3. **Dublikātu aizsardzība.** Vajag atzīmi, ka ceļojumam atgādinājums jau nosūtīts. Vai nu
   jauna kolonna `trips.start_reminder_sent_at`, vai maza tabula. **Tā ir datubāzes
   migrācija, tāpēc vajag tavu atsevišķu atļauju.** Bez tās var izmantot esošo paziņojumu
   tabulu un meklēt, vai šāds paziņojums šim ceļojumam jau ir.
4. **Cron.** Viena palaišana stundā (ne reizi dienā), lai atgādinājums nāk apmēram vienā
   vietējā laikā. Pievienot rindu `docs/operations/job-heartbeats.md`.
5. **Teksti.** Jauns ieraksts paziņojumu katalogā un tulkojumi 16 valodās
   (`docs/mobile/localization.md`). Piemērs angliski: `"{trip}" starts tomorrow.`
   Katalogu ģenerēšana var izmainīt servera failus, tāpēc to ierobežot ar šo darbu.
6. **Lietotne.** Pārbaudīt, ka paziņojuma pieskāriens atver pareizo ceļojumu (kā
   `trip_added`). Cita koda lietotnē visticamāk nevajag, bet paziņojuma veids jāpievieno
   saraksta nosaukumiem Notifikāciju iestatījumos, ja tāds ir.

### Jautājumi, kas jāizlemj

- **Laika josla.** Servera glabā laika joslas? Es neatradu lietotāja laika joslas lauku.
  Variants: sūtīt fiksētā stundā (piemēram, 09:00 pēc Rīgas laika), vai pievienot
  lietotāja laika joslu (jauns lauks, API izmaiņa).
- **Solo ceļojumi.** Sūtīt arī solo ceļojumiem (ieteicams, tas ir vienkārši atgādinājums).
- **Ceļojumi, kas sākas šodien vai ir jau sākušies**, kad tos izveido. Neko nesūtīt.
- **Divi atgādinājumi** (3 dienas un 1 diena)? Sākumā tikai viens.

### API un dokumentācija

Jauns paziņojuma veids ir API līguma papildinājums. Pirms koda: tava atļauja un
`docs/api/push-notification-categories.md` papildināšana ar jauno veidu (sākums, ko
saņem, ko satur `payload`: `trip_id`, `date_from`). Datus par atrašanās vietu vai citu
personisko informāciju paziņojums nesatur.

### Pārbaude

PHPUnit testi (atrod pareizos ceļojumus, nesūta dublikātus, ievēro slēdzi, nesūta
pabeigtiem ceļojumiem), `--dry-run` uz servera, un viens īsts tests ar savu ceļojumu uz
fiziska iOS un Android telefona.

## B. PDF čeki (un citi faili)

### Mērķis

Pie izdevuma var pievienot PDF čeku (piemēram, viesnīcas vai biļešu rēķinu), ne tikai
foto. Īpašnieks vēlas arī dokumentus, tāpēc sākumā izlemt apjomu (skat. jautājumus).

### Kas ir tagad

- Lietotne atver failu atlasi, bet `workspace_page_dialogs_helpers.dart` atļauj tikai
  `jpg, jpeg, png, webp, heic, heif, hif`.
- Serveris (`uploads_actions.php`, `upload_receipt_action`) pieņem failu, **pārveido to
  par WebP** (`store_uploaded_image_as_webp`) un izveido sīktēlu. PDF šo neiztur.
- Piegāde (`api/receipt-media.php`) atļauj tikai `image/webp`, `image/jpeg`, `image/png`.
- Limits: 8 MB failā, ikdienas augšupielādes limiti lietotājam un ceļojumam.
- App Store apraksts jau saka "photo or file of the receipt".

### Ieteicamais risinājums

**Serveris**

1. Pieņemt `application/pdf`: pārbaudīt gan galveni `%PDF-`, gan `finfo` MIME, atteikt
   šifrētus un pārāk lielus failus (joprojām 8 MB), neko nepārveidot.
2. Glabāt to pašu privāto mapi, bet ar paplašinājumu `.pdf`, izmantojot to pašu īpašnieka
   piesaisti (`bind_stored_receipt_to_owner`) un dzēšanu.
3. Sīktēls: vienkāršākais ir **vispārīga PDF ikona** (bez servera pusē renderēšanas).
   Pirmās lapas sīktēls prasa Imagick+Ghostscript vai `pdftoppm` uz VPS. Vispirms
   pārbaudīt, vai tie ir uzstādīti, pirms to solīt.
4. Piegāde: atļaut `application/pdf`, `Content-Disposition: attachment` vai stingrs CSP
   un `X-Content-Type-Options: nosniff`, lai PDF nevar izpildīt skriptus pārlūkā.
   Atjaunot `scripts/check_private_receipt_delivery.php`.
5. **API līgums.** Atbildē vajag zināt veidu, piemēram, `receipt_mime` vai `receipt_kind`
   (`image` vai `pdf`), lai lietotne zina, ko rādīt. Tā ir līguma izmaiņa: vajag tavu
   atļauju un `docs/api/` atjaunošanu pirms koda. Veci klienti, kas lauku nezina, rāda
   tikai saiti.

**Lietotne (iOS un Android)**

1. Pievienot `pdf` atļautajiem paplašinājumiem, nepieskaroties bilžu apstrādei un
   apgriešanai.
2. Čeka priekšskatījumā PDF rādīt kā karti (ikona, nosaukums, izmērs). Pieskāriens
   lejupielādē failu uz pagaidu mapi un atver to ar sistēmas PDF skatītāju (bez jaunas
   pakotnes, ja iespējams; jaunu pakotni pievienot tikai ar pamatojumu).
3. Bezsaistes rinda augšupielādei jāstrādā arī ar nebildes failiem.
4. Tulkojumi jauniem tekstiem visās 16 valodās.

**Dokumenti (Word, Excel utt.).** Ieteikums: sākumā **tikai PDF un bildes**. Pārējie
formāti nav drošāk glabājami un rādāmi, un tos nevar atvērt visās ierīcēs. Izlemt, vai
tie vispār ir vajadzīgi.

### Privātums un veikali

- **Google Play Data safety:** atzīmēt **Files and docs** (collected, optional, app
  functionality, ne koplietots ar trešajām pusēm).
- **App Store App Privacy:** čeki jau ir "Other User Content", izmaiņu nevajag.
- **`privacy.html`:** pārbaudīt, vai čeki tur pieminēti tikai kā foto. Ja jā, papildināt ar
  PDF un atjaunot datumu, jo mainās apstrādājamie dati.
- **App Store apraksts:** teksts jau runā par failu, tāpēc ir jāpārbauda tikai
  `docs/mobile/app-store-listing.md`.
- Uzglabāšanas termiņš un dzēšana jāsakrīt ar esošajiem čekiem.

### Jautājumi, kas jāizlemj

- Tikai PDF vai arī citi dokumenti?
- Vai vajag pirmās lapas sīktēlu, vai pietiek ar ikonu?
- Vai tas pats 8 MB limits ir pietiekams PDF?

### Pārbaude

PHPUnit (pieņem derīgu PDF, noraida viltotu PDF un pārāk lielu, noraida ļaunprātīgu
paplašinājumu), `check_private_receipt_delivery.php`, un lietotnes widget testi priekš
PDF kartes. Tad īsts tests ar PDF no Files uz iPhone un Android.

## C. Avāriju žurnāli (Sentry)

### Mērķis

Redzēt, kad un kur lietotne avarē vai met kļūdu īstiem lietotājiem, abās platformās.
Tagad release būvēs nekas netiek sūtīts, tāpēc avārijas nav redzamas.

### Kas jau ir

- `sentry_flutter` ir `pubspec.yaml`, un `lib/core/monitoring/app_monitoring.dart` ar
  konfigurācijas atslēgām `TRIPSPLIT_SENTRY_DSN`, `TRIPSPLIT_MONITORING_ENV`,
  `TRIPSPLIT_RELEASE_CHANNEL` un `TRIPSPLIT_MONITORING_TRACE_SAMPLE_RATE`
  (`config/env/*.example.json`).
- Release būvēs DSN nav, tāpēc Sentry neko nesūta. Tā ir apzināta izvēle 2026-11-12
  privātuma pārbaudē (`docs/mobile/app-privacy-answers.md`).

### Ieteicamais risinājums

1. Izveidot Sentry projektu (labāk ar datu glabāšanu ES) un ielikt DSN ignorētajos
   `config/env/android-internal.local.json` un `testflight.local.json`. Nekad ne repozitorijā.
2. Pārbaudīt `app_monitoring.dart`: nesūtīt personas datus (e-pastu, vārdu, atrašanās
   vietas koordinātes, izdevumu saturu, žetonus), izslēgt noklusējuma PII, ierobežot
   breadcrumbs, trace sample rate zems.
3. Pārbaudīt, ka Sentry nesūta datus, kad lietotājs nav piekritis (ja tāda izvēle ir
   vajadzīga), un ka dev būvēs tas ir izslēgts.
4. Pārbaudīt uz abām platformām ar mākslīgu kļūdu (testa būvē) un apskatīt ziņojumu.

### Dokumenti un veikali (pirms izlaišanas)

- **Google Play Data safety:** atzīmēt **Crash logs** (Diagnostics un Other app performance
  data jau ir atzīmēti).
- **App Store App Privacy:** pievienot Crash Data, Performance Data un Other Diagnostic
  Data (App Functionality), kā jau norādīts `app-privacy-answers.md`.
- **`privacy.html`:** pievienot, ka tiek sūtīti avāriju ziņojumi, kam, kādi dati un cik ilgi
  tie tiek glabāti, un atjaunot datumu. Sentry kā jauns apstrādātājs ir arī jāpiemin
  pakalpojumu sniedzēju sarakstā.
- Atjaunot `app-privacy-answers.md`, lai tas atbilst.

### Alternatīva bez SDK

Google Play Console (Android vitals) un App Store Connect jau rāda avāriju statistiku
lietotājiem, kas piekrituši dalīties ar diagnostiku. Tas neprasa kodu vai deklarāciju, bet
dod mazāk detalizētu informāciju nekā Sentry. Var sākt ar to un Sentry ieslēgt vēlāk.

### Jautājumi, kas jāizlemj

- Sentry vai tikai Play/App Store Connect statistika?
- Vai ES datu glabāšana ir pieejama izvēlētajā Sentry plānā?
- Cik ilgi glabāt ziņojumus (ieteikums: 30 līdz 90 dienas)?

## D. Komentāru atzīmes pēc pozīcijas, nevis vārda

### Mērķis

`@atzīme` darbojas neatkarīgi no tā, kā vārds uzrakstīts tekstā, kā Slack vai WhatsApp.

### Kas ir tagad

Lietotne sūta `mentioned_user_ids`. Serveris atzīmi saglabā tikai tad, ja tekstā aiz `@`
ir dalībnieka vārda forma (`docs/api/expense-comment-mentions.md`). 2026-11-14 atklājām:
lietotne ieliek īso ceļojuma vārdu (`@Marta`), serveris pazina tikai pilno vārdu vai
segvārdu, tāpēc reģistrētiem dalībniekiem atzīmes un paziņojumi pazuda. Steidzamais labojums:
serveris pieņem arī vārdu un "Vārds U.", tāpēc vecais build strādā.

### Ieteicamais risinājums (atpakaļsaderīgs)

- Pieprasījumā jauns neobligāts lauks, piemēram `mentions: [{user_id, start, end}]`.
  Ja tas ir, serveris pārbauda, ka lietotājs ir aktīvs dalībnieks un ka `start` vietā ir
  `@`; vārdu vairs nesalīdzina. Ja lauka nav, strādā vecā pārbaude.
- Atbildē `mentions` paliek `{user_id, name}`, klāt nāk `start` un `end`.
- Migrācija tikai pievieno kolonnas `start_offset`, `end_offset` (NULL veciem ierakstiem).
- Lietotne sūta pozīcijas un iekrāso pēc tām.

### Pārbaude

Testi gan vecajiem pieprasījumiem (tikai ID), gan jaunajiem; rediģēšana, kas maina pozīcijas;
280 zīmju robeža; dalībnieks, kas izstājies.

## E. Izdevuma tips (neobligāta apakškategorija)

### Mērķis

Precīzāka analītika ("restorāniem €320, kafijai €45"), nepalēninot izdevuma ievadi.
Kategoriju saraksts paliek kā tagad, bez zīmītēm un bez otra līmeņa sarakstā.

### Izvēlētais dizains (2026-11-15)

Uzmetums: `output/design/expense-subcategories/board3.png` (gitignored).

1. "Add expense" ekrānā kategorijas pogā labajā pusē ir maza poga ar raustītu malu
   **"+ Type"**, tikai kategorijām, kurām ir tipi. Ja to neaiztiek, saglabājas tikai
   kategorija (piemēram, "Food").
2. Uzspiežot "+ Type", tieši zem pogas atveras uznirstoša izvēlne tādā pašā stilā kā
   izdevumu filtra izvēlne: virsraksts "Type of food · optional", rindas ar ikonām,
   izvēlētais zaļš ar ķeksīti, pirmā rinda "Just food". Izvēle vai pieskāriens ārpus
   aizver izvēlni.
3. Rezultāts vienā pogā: **"Food · Restaurant"**. Pogas pamatdaļa atver kategoriju
   sarakstu kā tagad; mainot kategoriju, tips noņemas. Pogas labajā malā jāatstāj zona,
   kas atkal atver tipu izvēlni (uzmetumā vēl nav).

### Tipi (sākumam)

- **Food:** Restaurant, Café, Bar, Fast food, Snacks.
- **Transport:** Taxi / ride-share, Flight, Train, Bus, Car rental, Ferry, Public transport.
- Vēlāk, ja vajadzēs: Accommodation (Hotel, Hostel, Apartment, Camping), Activities,
  Shopping. Groceries, Fuel, Parking, Party un Other tipus nesaņem.
- Vērts reizē izlemt pārklāšanos: Tickets (Transport/Activities) un Party (Food → Bar).

### Savs tips (custom)

- Izvēlnes apakšā rinda **"Custom type…"**. Uzspiežot to, tā pati rinda turpat izvēlnē
  pārvēršas par ievades lauku (zaļa apmale, ✓ poga, atveras tastatūra ar "Save"); bez
  atsevišķa loga. Izvēlne paceļas virs tastatūras. Saglabājot tips uzreiz ir pogā
  ("Food · Street food"). Uzmetums: `output/design/expense-subcategories/board4.png`.
  Ierobežot garumu (ap 30 zīmēm) un noņemt liekas atstarpes.
- **Izlemts (2026-11-15), lai izvēlne nekļūst bezgalīga:**
  - Izvēlnē savi tipi pēc noklusējuma **neparādās**, un nav uzraksta "Saved for next time".
  - **Rakstot** "Custom type…" laukā, zem tā parādās ieteikumi no tipiem, kas šajā
    ceļojumā jau ir ierakstīti (sākot rakstīt "St…" → "Street food"), kā vienkāršas
    rindas, ko var uzspiest; bez paskaidrojošiem uzrakstiem.
  - Ja savu tipu ceļojumā **lieto regulāri** (priekšlikums: vismaz 3 izdevumos, jebkurš
    dalībnieks), tas kļūst par šī ceļojuma tipu un parādās "Type" izvēlnē **visiem
    dalībniekiem** pirms "Custom type…". Citos ceļojumos tas neparādās.
  - Atsevišķa savu tipu pārvaldības lapa (dzēšana, kārtošana) nav vajadzīga.
- Savus tipus netulko. Tipiem ar vienādu nosaukumu (bez reģistra un liekām atstarpēm)
  jāsakrīt, lai "street food" un "Street food" ir viens un tas pats, gan ieteikumos, gan
  skaitot lietojumus, gan analītikā. Grafikā rādīt lielākos 3–4 tipus, pārējos apvienot
  "Other <kategorija>".

### Izdevumu saraksta rinda (izlemts 2026-11-15)

Uzmetums: `output/design/expense-subcategories/board6.png` (pa kreisi tagad, pa labi jaunā).

- **Maksātāja avatars** mazā aplī ar baltu apmali kategorijas ikonas augšējā kreisajā
  stūrī (foto vai krāsains aplis ar burtu). Rinda **"… paid" vairs nav.**
- **Augšējā rinda:** galvenā kategorija un blakus pelēkāks tips: "Food · Restaurant",
  "Tickets · Cinema". Bez tipa tikai kategorija ("Groceries").
- **Apakšējā rinda:** piezīme ("Dinner by the sea") tur, kur bija "… paid". Bez piezīmes
  rinda ir vienā līnijā.
- Summa un oriģinālā valūta labajā pusē paliek kā tagad.
- Kategorija tagad redzama vienmēr (šodien piezīme to aizstāj nosaukumā).
- Dalīšanas veids ("Exact amounts") no rindas pazūd un paliek izdevuma detaļās.
- Vērts apsvērt: izcelt paša samaksātos (piemēram, zaļa apmale ap avataru) un dot
  atšķirīgas krāsas burtu aplīšiem ar vienādu burtu (Marta un Matiss).

### Atvērts izdevums (izlemts 2026-11-15)

Uzmetums: `output/design/expense-subcategories/board7.png` (pa kreisi tagad, pa labi jaunais).

- **Augša kā sarakstā:** ikona ar maksātāja avataru stūrī, virsraksts "Kategorija · tips"
  ("Transport · Taxi"), zem tā piezīme un tad datums ar laiku. Atkārtojums
  "Transport" / "Nov 13 · Transport" pazūd.
- **Summa** ar oriģinālo valūtu blakus ("€14.70 ALL 1,350"), ja maksāts citā valūtā.
- **Viena rinda ar zīmītēm:** "Paid by <vārds>" ar avataru, dalīšanas veids
  ("= Equal split", "Exact amounts" utt.) un "Receipt" (tikai, ja čeks pievienots; atver to).
- **Split breakdown** ar cilvēku skaitu; pie maksātāja zaļa zīme "paid €14.70".
- **Comments** ar skaitu, ziņas burbuļos ar avataru, vārdu un laiku, @atzīmes zaļā krāsā.
  Ievades lauks paliek kā tagad.

### Kas seko pēc tipiem: analītika un PDF atskaite

Tipi un maksātājs katrā izdevumā dod materiālu bagātākai analītikai un ceļojuma PDF
atskaitei (sk. arī sesiju par Premium PDF atskaiti). Būvē **pēc** tam, kad tipi ir API un
datubāzē. Pirmajos ceļojumos pēc atjauninājuma daudziem izdevumiem tipa nebūs, tāpēc visur
jārāda arī "bez tipa" bez tukšiem caurumiem.

- **Analītika:**
  - kategorija sadalīta pa tipiem ("Food €420: Restaurant €260 · Café €85 · Bar €45");
  - kas ko maksāja pa tipiem ("Marta samaksāja lielāko daļu restorānu");
  - reižu skaits un vidējā summa ("12 kafijas, vidēji €3,40");
  - dārgākās dienas un kas tās veidoja;
  - savi tipi kā atsevišķas rindas, sīkie apvienoti zem "Other <kategorija>".
- **PDF atskaite:**
  - lapa "Kur aizgāja nauda": kategorijas ar tipiem, procenti, lielākie izdevumi;
  - "fakti" ("9 kafejnīcas", "dārgākais taksometrs €42", "restorāni = 28%");
  - katra cilvēka lapa: ko maksāja un kam, pa tipiem, kopā ar viņa daļu;
  - izdevumu saraksts jaunajā formā ("Food · Restaurant", piezīme, maksātājs).

### Ko tas prasa

- Jauns neobligāts lauks (piemēram, `subcategory`) API līgumā, datubāzē un bezsaistes
  kešatmiņā. Vecām app versijām tas jāignorē bez kļūdām. API izmaiņai un migrācijai
  vajag atsevišķu atļauju, un vispirms jāatjauno līguma dokuments.
- Tipu nosaukumi visās 16 valodās (ARB, `flutter gen-l10n`).
- Analītika: dalījums pa tipiem kategorijas iekšienē; izdevumu filtrā, iespējams,
  filtrs pēc tipa.
- Vēlāk: "Recent" kombinācijas un Premium čeku nolasīšana var aizpildīt tipu automātiski.

### Ko nedarīt

Atsevišķu "Tip & tax" bloku nevajag: "By item" režīmā jau ir lauks "Tax or tip"
(`extra_amount`), ko sadala proporcionāli katra pozīcijām. Vienādai dalīšanai pietiek ar
samaksāto kopsummu.

## Secība un izlaišana

1. **Apstiprinājumi.** API izmaiņas (jauns paziņojuma veids, `receipt_kind`), datubāzes
   migrācija (dublikātu aizsardzība), servera izvietošana (cron, jauns skripts). Šie
   darbi neietilpst "uzrakstīt kodu" un prasa tavu atļauju atsevišķi.
2. **Dokumentācija** pirms koda: `push-notification-categories.md` un čeku līgums.
3. **A, B un D serveris**, tad lietotne, tad testi. D servera daļu var izvietot arī agrāk. **C** neprasa servera izmaiņas, tikai
   lietotnes konfigurāciju un dokumentus.
4. **Versija.** Paaugstināt `pubspec.yaml` build numuru. Android būvei vienmēr
   `--dart-define-from-file=config/env/android-internal.local.json`; iOS arhīvam vispirms
   atjaunot `Generated.xcconfig`. Atsevišķi iesniegt iOS un Google Play.
5. **Play Data safety** atjaunot ar "Files and docs" (B) un "Crash logs" (C) pirms
   iesniegšanas. App Store privātuma atbildes un `privacy.html` atjaunot vienā reizē.

## Ārpus šī plāna

- Kalendāra atļauja un kalendāra notikumi. Ja vajadzēs, labāk "Pievienot kalendāram" bez
  atļaujas (sistēmas logs vai `.ics` fails), un tad "Calendar events" Data safety nav
  jāatzīmē.
- Reklāmas, pirkumi un Premium. Katrs no tiem maina Data safety un privātuma politiku.
