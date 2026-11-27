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
- **Accommodation:** Hotel, Hostel, Apartment, Camping (izlemts 2026-11-17).
- **Activities un Shopping:** bez iebūvētiem tipiem, bet ar "+ Type" un "Custom type…",
  lai var ierakstīt savu (izlemts 2026-11-17).
- Groceries, Fuel, Parking, Party un Other tipus nesaņem.
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

### Dalībnieka bilance un vēsture (izlemts 2026-11-16)

Balances → pieskāriens dalībniekam atver lapu ar viņa bilanci un vēsturi. Uzmetums:
`output/design/expense-subcategories/board10.png` (pa kreisi tagad, pa labi jaunais).
Krāsas paliek tās, kas app jau ir; ņem ideju un izkārtojumu.

- **Augša paliek pēc būtības tāda pati**, tikai kompaktāka: avatars, vārds, statuss kā
  mazs marķieris ("Owes to the group" sarkans, "Gets back" zaļš), zem tā liela summa.
- **Trīs skaitļi vienā rindā** ar tievām atdalītājlīnijām, bez rāmjiem: Paid · Share ·
  Payments (nulle pelēka).
- **Virsraksts "Transaction history" un teksts "may not include the entire trip history"
  pazūd**; sadaļu iezīmē filtrs All · Expenses · Payments tādā stilā kā tripa cilnes.
- **Grupēts pa dienām**, katrai dienai sava kopsumma (ietekme uz šī cilvēka bilanci).
- **Rindas kā izdevumu sarakstā:** ikona ar maksātāja avataru, "Kategorija · tips", piezīme.
  "Share of expense" katrā rindā pazūd.
- **Pa labi ietekme uz šo cilvēku:** sarkans "−€10.62 / share", ja maksāja cits; zaļš
  "+€14.17 / paid €18.89", ja maksāja viņš pats (samaksātais mīnus viņa daļa).
- **Maksājumi atsevišķi:** zaļa ikona ar bultiņām, "Payment", divi avatari "Kas → kam ·
  confirmed", summa.
- Pieskāriens rindai atver izdevumu (atvērtā izdevuma lapa augstāk).
- Jāpārbauda, vai pašreizējie API dati dod maksātāju un tipu katrai rindai; ja ne, tas ir
  API līguma papildinājums un prasa atsevišķu atļauju.

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

**Izlemts (2026-11-16), uzmetumi `output/design/expense-subcategories/board8.png` un
`board9.png`:**

- **Analītika:** donuts paliek ar galvenajām kategorijām kā tagad. Atverot kategoriju (no
  saraksta), redzams sīkāk: tipi ar joslām, summām, procentiem, reižu skaitu un vidējo, kas
  maksāja, lielākie izdevumi. Sarakstā pie kategorijas pelēki redzami tās tipi.
- **PDF:** krāsains, bet atturīgs. Tās pašas kategoriju krāsas kā app (tipi ir tās krāsas
  toņi), krāsa tikai joslās un punktos, teksts tumšs uz balta, bez lieliem krāsainiem
  laukumiem, lai labi izdrukājas. Nekas nedrīkst būt saprotams tikai pēc krāsas.
  Struktūra:
  1. "Kur aizgāja nauda" (bezmaksas e-pasta atskaite): kopsummas, kategorijas ar tipu
     joslām un 3 īsi fakti;
  2. "Fakti un dienas" (Premium): ceļojums skaitļos, tēriņi pa dienām pa kategorijām,
     lielākie izdevumi;
  3. katra cilvēka lapa (Premium): ko samaksāja pa kategorijām un tipiem, norēķini, viņa
     izdevumi.
  PDF taisa serveris, tāpēc to var uzlabot arī starp app atjauninājumiem.
- **CSV (Premium eksports):** jaunas kolonnas **Category** un **Type** atsevišķi (tukšs
  Type = bez tipa, savi tipi tāpat kā standarta), nosaukumi lietotāja valodā, pārējais
  kā tagad (`;`, BOM, oriģinālā summa, kurss, katra cilvēka daļa). Mērķis: filtrs un pivot
  tabula pēc tipa.
- **CSV pārbaude pirms izlaišanas:** atvērt īstu failu Excel (Windows un Mac), Numbers un
  Google Sheets ar latviešu un angļu reģionālajiem iestatījumiem; pārbaudīt kolonnas, burtus
  (ā, ņ), decimāldaļas un tekstu, kas sākas ar mīnusu.

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

## F. Live map: "Share my location" lapa (izlemts 2026-11-16)

Tikai izskata labojums; uzvedība, laiki un API paliek tādi paši. Kods:
`mobile/lib/features/live_location/presentation/live_map_page.dart`. Uzmetums:
`output/design/expense-subcategories/board11.png` (pa kreisi tagad, pa labi jaunais).
Krāsas paliek tās, kas app jau ir.

- **Virsraksts ar ikonu:** zaļa atrašanās vietas ikona mīkstā zaļā kvadrātā + "Share my
  location".
- **Viena īsa rinda** garo divu teksta bloku vietā: "Your trip members see where you are.
  Stop anytime."
- **Kas redzēs:** pārklājoši apstiprināto dalībnieku avatari + "Visible to N members of
  <trip>".
- **Laika izvēle kā tripa cilnes:** pelēka josla ar zaļu aktīvo daļu (15 min · 1 h · 4 h ·
  8 h); atsevišķās apaļās pogas ar ķeksīti pazūd.
- **Zem tā beigu laiks:** "Sharing until 00:44, then it stops on its own." (mainās pēc
  izvēles, ierīces laika formātā).
- **Poga "Start sharing"** paliek.
- **Tehniskie paskaidrojumi pazūd** (pēdējā atrašanās vieta, maršruta vēsture, pauzes bez
  interneta) — tas viss ir privātuma politikā. Privātuma politikas teksts nemainās.
- Jaunie teksti visās 16 valodās (ARB, `flutter gen-l10n`); vecās atslēgas, kas vairs nav
  vajadzīgas, izņem.

## G. Settle lapa (izlemts 2026-11-16)

Mērķis: maksimāli vienkārša un pārskatāma norēķinu cilne. Mainās izkārtojums un teksti;
norēķinu loģika, statusi un API paliek tādi paši. Kods:
`mobile/lib/features/workspace/presentation/pages/workspace_page_tab_balances.dart`.
Uzmetums: `output/design/expense-subcategories/board13.png` (pa kreisi tagad, pa labi
jaunais; varianti A/B/C `board12.png`). Krāsas paliek tās, kas app jau ir.

No augšas uz leju:

1. **Soļu josla:** 1 · Ready → 2 · Trip ends → 3 · Pay; aktīvais solis zaļš. Aizstāj
   teikumus "Trip creator must finish the trip…" un "Waiting for everyone to mark ready".
2. **Ready to settle · 2 of 4:** visi dalībnieki vienā avataru rindā; gatavajiem zaļš ķeksītis
   stūrī, pārējiem pelēks pulkstenis. Bez lielās pelēkās kartītes un progresa joslas.
3. **Slēdzis "I added all my expenses"** (tavs gatavības slēdzis), viena rinda.
4. **Tava summa:** "You get back" / "You owe" ar mazu marķieri "estimate" un lielu summu.
   Garais "Estimate based on current expenses…" teksts pazūd (abās vietās).
5. **"To you" (vai "You pay"):** tikai maksājumi, kas skar tevi; katrā rindā avatars, vārds,
   "pays you" / "you pay", summa un maza poga "Request" uzreiz (bez atveramas kartītes).
   "Details" paliek pieejams, pieskaroties rindai.
6. **"Between others":** pārējie maksājumi pelēkāk, ar diviem avatariem "Kas → kam".

Vēl jāizlemj būvējot: kā izskatās 2. un 3. solis (pēc ceļojuma beigām: apstiprināšana,
"Mark as paid"), lai tas pats izkārtojums der visiem soļiem; teksti visās 16 valodās.

## H. "By item" dalīšana: saraksts un cilvēki (izlemts 2026-11-16)

Mērķis: pārskatāma dalīšana pēc pozīcijām (restorāns, čeks). Tagad katrai pozīcijai ir liela
kartīte ar visiem avatariem, visi atzīmēti, un nav redzams, vai summa sakrīt un cik katrs maksā.
Kods: `mobile/lib/features/workspace/presentation/pages/workspace_page_expense_editors.dart`
(un `workspace_page_dialogs.dart`). Uzmetumi `output/design/expense-subcategories/`:
`board19.png` (galīgais), `board18.png` (Items stāvokļi), `board17.png` (People avatari),
`board16.png` (daudzumi), `board14.png` (sākotnējie varianti). Tumšais un gaišais režīms; krāsas
paliek app esošās.

**Divas cilnes ar ikonām** (čeks un cilvēki, bez teksta), tāda paša stila kā tripa cilnes.

**Čeka cilne (saraksta veidošana):**
- Augšā progresa josla "Entered from the receipt €X of €Y".
- Zem tās uzraksts "Item list", tur sākas saraksts.
- Rinda: mazs numurs, nosaukums ar daudzuma zīmi "×2", zem tā "€12.50 each", pa labi kopā.
- Rediģējot: nosaukums un "Price each" bez rāmja, tikai līnija (zaļa, kad aktīva); "Qty" ar −/+;
  uzreiz "= €13.50". Virs tastatūras "Next item ›" saglabā un atver nākamo rindu.
- "Tax or tip" atsevišķa rinda ar "%" ikonu, dalās pēc tā, ko katrs ēda (kā tagad `extra_amount`).
- Apakšā pārbaude "Items €54.80 + tip €4.00 = €58.80 ✓"; ja nesakrīt, oranžs "€6.50 is missing
  from the receipt total" un poga uz cilvēkiem neaktīva.

**Cilvēku cilne (kurš ko ēda):**
- Bez virsraksta: augšā cilvēku avatari ar summu zem katra; zaļš rāmis ap to, kurš izvēlas.
- Avatari kā "Add expense": bez atzīmes, kamēr cilvēkam nekas nav; zaļš aplis ar ķeksi, kad ir.
- Saraksts kā ķekšu rindas: ķeksis, nosaukums, paskaidrojums ("1 of 2 · 1 left for others",
  "Shared with Marta"), summa pa labi. Pozīcijām ar daudzumu zem summas mazs −/+.
- Paņemtais pazūd nākamajam: ja alus ir 1 un to paņēma Jana, citiem tā vairs nav; ja picas ir 2 un
  viena paņemta, nākamajam rāda "1 left". Pilnībā paņemtās pozīcijas apakšā pelēkā rindā ar avataru
  ("Caesar salad · Valerija").
- Kopīga lieta (deserts, ūdens): "Share", cena dalās starp visiem, kas to atzīmē.
- Apakšā "Not assigned yet €X" un "Next person"; kad viss sadalīts: "✓ All items assigned · €Y"
  un "Done". Tad katram cilvēkam rāda tikai viņa sarakstu.

**"+ Add item" jebkurā brīdī:** čeka cilnes saraksta beigās vienmēr, un maza saite arī cilvēku
cilnes apakšā. Jauna pozīcija visiem parādās kā nepaņemta, "All items assigned" atkal kļūst par
"Not assigned yet", Done nestrādā, kamēr kāds to nepaņem. Jau sadalītais nemainās. Labojot vai
dzēšot pozīciju, ko kāds jau paņēma, viņa daļa pārrēķinās.

**API:** daudzumus var nosūtīt pa esošo `itemized` līgumu bez izmaiņām (`docs/api/expense-split-types.md`):
app izvērš "Pizza ×2, Marta 1, Matiss 1" par divām pozīcijām ar vienu cilvēku katrā, kopīgu lietu
par vienu pozīciju ar vairākiem `participant_ids`. Atverot izdevumu labošanai, vienāda nosaukuma
un cenas pozīcijas var atkal apvienot "×N". Jāpārbauda 100 pozīciju limits un noapaļošana. Ja
gribam glabāt daudzumu kā lauku, tā ir līguma izmaiņa un vajag atļauju.

**Arī pārējie dalīšanas veidi (Custom split):** "Exact amounts", "Percentages", "Shares" un
"Adjustments" (+/−) ievades laukiem tāpat nav rāmja, tikai līnija apakšā (zaļa, kad aktīva), lai
visi dalīšanas veidi izskatās vienādi ar "By item".

**Saistība ar Quick Split:** šī pati lapa būs Quick Split pamats; AI čeki vēlāk aizpildīs čeka cilni
(arī daudzumus), cilvēki tikai atzīmē savas pozīcijas (sk. `docs/mobile/quick-split-ai-plan.md`).

Teksti visās 16 valodās (ARB, `flutter gen-l10n`).

## I. Gada kopsavilkums Quick Start stilā (vēlāk; izvēlēts 2026-11-22)

**Statuss (2026-11-27):** jaunais ekrāns uzbūvēts (viens logs), vecais izdzēsts. Lietotnē tas **ir
paslēpts**: ieeju profilā rāda tikai, ja `yearSummaryOfferedInApp` ir ieslēgts
(`--dart-define=YEAR_SUMMARY_IN_APP=true`, noklusējumā izslēgts). 2026. gada sezonā
(janvāris–marts) to neatver. Kā un kad ieslēgt (lietotnes versija vai servera karogs
`docs/api/feature-flags.md`), jāizlemj pirms palaišanas; servera karogs būtu API izmaiņa.

Ekrānuzņēmumi ar demonstrācijas datiem: `flutter test test/features/trip_reports/trip_reports_test.dart
--dart-define=YEAR_SUMMARY_PREVIEWS=true` raksta `output/design/year-summary/` ekrānu (`app-*`), kopīgoto attēlu (`shared-*`) un to sarakstē (`chat-*`).

**Izmaiņa 2026-11-27: viens logs trīs slaidu vietā** (īpašnieka lēmums). Virsraksts
"Atskats uz aizvadīto gadu" bez gada; augšā zaļā kopīgojamā kartīte ar gadu (Inter, slīpraksts,
mintzaļš gradients) un SPLYTO logo; zem tās balts saraksts "Tikai tev, attēlā nenonāk"
(izdevumi, lielākais ceļojums, galvenā kategorija, visvairāk ceļojumu ar). **Summas attēlā
nekad nenonāk** (slēdža nav). Kopīgotais attēls ir kartīte uz mintzaļā–krēmkrāsas fona, lai
noapaļotie stūri sarakstē neizskatītos kā melni vai balti kvadrāti. Skaitļi, kas ir 0, kartītē
netiek rādīti, un saraksts rāda tikai rindas ar datiem. Valstu nosaukumi nāk no servera
angliski. Cits fonts gadam prasītu jaunu fonta failu (OFL) un īpašnieka atļauju to lejupielādēt.

**Jaungada izskats (2026-11-27):** decembrī un janvārī kartītei ir sniegs, kupena apakšā,
gads ar katru ciparu pagrieztu, 3D dziļumu un sniega cepurīti (`year_snow_cap.svg`),
uzraksts "Laimīgu Jauno gadu" un logo ar Ziemassvētku cepuri uz "O"
(`logo_full_holiday.svg` gaišam fonam, `logo_full_dark_holiday.svg` tumšam). No februāra
kartīte ir bez tā. Izvēlēts rādīt no 1. janvāra, nevis 31. decembra (pilns gads, bez servera
izmaiņām). Fonts gadam: Inter, līdz īpašnieks atļauj lejupielādēt citu OFL fontu.

**Kartīte ar karti (2026-11-27, koncepcija B):** kopīgotais attēls ir kartīte 4:5,
1080 × 1350 (zīmēta 360 × 450, kopīgota 3×). Īpašnieka izvēle: nevis pilnekrāna stāsts, bet
kartīte, ko stāstu lietotne parāda mazāku uz sava fona; tā arī netiek aizsegta ar vārdu un
atbildes lauku. Stūri noapaļoti pašā attēlā (caurspīdīgi PNG stūri); lietotnes, kas attēlu
pārvērš JPEG (WhatsApp), tos aizpilda melnus, kas sakrīt ar kartītes tumšo malu. Tumši zils fons, gads, karte ar izgaismotām apmeklētajām
valstīm (pēc valstu kodiem, automātiski pietuvināta), skaitļi bez nullēm, līdz 8 valstu
nosaukumiem un "+N", logo. Ja valstu nav, kartes vietā ir dekoratīvs globuss ar lidmašīnas
orbītu. Ekrānā redzama tieši tā pati kartīte samazinātā mērogā. Kartes kontūras:
`assets/maps/world.json` (Natural Earth), lasītājs `lib/core/maps/world_countries.dart`.
Lēmumi 2026-11-27: maršruta līnijas starp pilsētām **nevajag**. Valstu nosaukumi pirmajā
versijā paliek **angliski** (kā tos sūta serveris); pirms ieslēgšanas apsvērt nosaukumus
lietotāja valodā no Unicode CLDR (lietotnē, bez API izmaiņām; noderētu arī ceļojumu kartei).
Vēl nav: OFL fonts gadam (tagad Inter).

**Kā tas parādās lietotnē (2026-11-27):** nevis pa visu ekrānu kā Quick Start. Sezonā
(kad serveris atļauj `year_summary`) Home ekrānā zem kopsummas ir tumša kartīte "JAUNS ·
Tavs 2026 ceļojumos". Pieskaroties, kopsavilkums izlec virs aptumšota, izplūduša Home
ekrāna (`showYearSummary`): taisna kartīte, zem tās balts saraksts "Tikai tev" (izdevumi,
lielākais ceļojums, kategorija, ar ko visvairāk, pievienotie izdevumi, visas valstis un
pilsētas), poga "Dalīties ar savu gadu", ✕ un pieskāriens blakus aizver. Kopīgo tikai
kartīti. Profila ieeja atver to pašu logu. Lietotne pati logu neatver.

**Vietu dati (jāizlemj pirms ieslēgšanas):** valstis un pilsētas ir tikai no ceļojuma
galamērķiem un personīgās kartes; daudziem tās būs tukšas. Ieteikums: ceļojuma beigās
ieteikt vietu no ceļojuma nosaukuma (lietotājs apstiprina) un parādīt "Kur tu biji?", ja
galamērķa nav. Neminēt pēc valūtas un nevākt GPS pie izdevumiem.

**Izvēlētais makets:** [trīs slaidi Quick Start stilā](../../output/design/year-summary/d-quick-start-style.png).
Maketa skaitļi un valstis ir demonstrācijas dati. Iepriekšējie A/B/C varianti paliek
`output/design/year-summary/` salīdzināšanai; ieviešanas pamats ir **D / Quick Start**.

### Dizains un saturs

Pārņemt esošā Quick Start mintzaļo–krēmkrāsas fonu, krāsainās lentes, Inter
virsrakstus, slaidu punktiņus un navigācijas stilu. Centrā rādīt lietotāja gada
datus un kartītes. Kopā **trīs slaidi**:

1. **Tavs gads:** gads, ceļojumu, prom pavadīto dienu, valstu un pilsētu skaits.
2. **Gada pieturas:** apmeklētās valstis, lietotāja izdevumu daļa, dārgākais
   ceļojums pēc lietotāja izdevumu daļas un galvenā izdevumu kategorija.
3. **Dalies ar savu gadu:** kopīgojamās kartītes priekšskatījums, poga kopīgošanai
   un poga pabeigšanai. Izdevumu summas kopīgojamajā attēlā pēc noklusējuma
   paslēptas; lietotājs var tās ieslēgt ar slēdzi.

Pārvilkšana ar pirkstu, **Tālāk**, iespēja atgriezties un aizvērt jebkurā brīdī.
Bez automātiskas slaidu pārslēgšanās. Saglabāt atbalstu palielinātam tekstam,
maziem ekrāniem, drošajām ekrāna malām un samazinātām animācijām. Trūkstošus
datus neizdomāt; tukšam gadam saglabāt atbilstošu tukšo stāvokli.

### Ieviešanas atskaites punkti

- Stila paraugs: `mobile/lib/features/quick_start/presentation/quick_start_sheet.dart`
  un `quick_start_background.dart` tajā pašā mapē. Koplietojamu vizuālo kodu vajadzības
  gadījumā izdalīt kopīgā UI slānī, neveidojot atkarību starp funkciju prezentācijas slāņiem.
- Pašreizējais ekrāns: `mobile/lib/features/trip_reports/presentation/year_summary_page.dart`.
- Izmantot esošos `YearSummary` datus un kopīgošanu; pats dizains neprasa AI ieviešanu.
- Saglabāt iepriekš pieņemto pieejamību: **1. janvāris–31. marts (UTC), par iepriekšējo
  kalendāro gadu**. Līgums: [trip-reports.md](../api/trip-reports.md).
- Jaunie teksti visās lietotnes valodās, slaidu un kopīgošanas pārbaudes abām platformām.

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
- **Imports no Splitwise (vēlāk, ne nākamajā atjauninājumā).** Mērķis: "pārnes savu grupu
  1 minūtē". Splitwise grupas CSV satur katra cilvēka bilances izmaiņu, nevis maksātāju un
  daļas; no tā maksātāju un daļas var precīzi atjaunot tikai, ja maksāja viens cilvēks.
  Splitwise kategorijas labi kartējas uz mūsu kategorijām un tipiem (Dining out → Food ·
  Restaurant, Taxi → Transport · Taxi, Hotel → Accommodation · Hotel).
  - **B (vispirms):** tikai bilances: "Sāc ar atlikumiem no Splitwise", kurš kam parādā.
  - **A (vēlāk):** pilns imports: izdevumi ar kategorijām un tipiem, dalībnieki, maksājumi.
  - Atkarīgs no dalībniekiem bez konta (vēl nav uzbūvēts) un no tipiem. Pirms būvēšanas
    iegūt īstu Splitwise CSV, jo formāts nav pārbaudīts. Vēlāk var nākt arī citi avoti
    (Tricount, Settle Up), katram savs formāts.
