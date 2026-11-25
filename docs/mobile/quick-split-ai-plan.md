# SPLYTO — Quick Split & AI Receipt Scanner

**Funkcionalitātes ideja un tehniskās izstrādes plāns**  
**Statuss:** Ideja nākotnes izstrādei  
**Prioritāte:** Augsta  
**Mērķis:** Paplašināt SPLYTO lietošanu ārpus ceļojumu grupām, saglabājot lietotni bezmaksas un bez reklāmām.

Jaunākie AI drošības lēmumi ir 12. sadaļā (2026-11-17); pretrunu gadījumā tie aizstāj
agrākos kvotu, atkārtojumu un ieviešanas secības priekšlikumus. Šis ir ieviešanas plāns,
nevis apliecinājums par jau ieviestu aizsardzību vai atļauja izvietošanai produkcijā.

Saistītais [SPLYTO drošības darbu saraksts (2026-11-17)](../security/security-follow-up-2026-11-17.md)
aptver rezerves kopijas, limitu kļūmes, admina/infrastruktūras piekļuvi, agrāko noslēpumu
noplūdi, lietotāju datu izolāciju, failu drošību un rīcību incidenta gadījumā.

---

## 1. Galvenā ideja

Ieviest SPLYTO funkciju **Quick Split**, kas ļauj ātri sadalīt restorāna vai citu rēķinu starp vairākiem cilvēkiem, neveidojot ceļojumu vai pastāvīgu grupu.

**Atver Quick Split → Nofotografē čeku → AI atpazīst pozīcijas → Sadali starp cilvēkiem → Gatavs.**

Lietotājam nav manuāli jāpārraksta čeka saturs. Quick Split darbojas arī bez AI, ļaujot ievadīt summu manuāli.

## 2. Quick Split funkcionalitāte

### 2.1. Vienkārša rēķina sadalīšana

1. Atvērt Quick Split.
2. Ievadīt kopējo summu un valūtu.
3. Izvēlēties dalībnieku skaitu.
4. Izvēlēties vienādu vai individuālu summu sadalījumu.
5. Pēc izvēles pievienot dzeramnaudu.
6. Apskatīt aprēķinu, cik katram jāmaksā.

Vienkāršajam kalkulatoram nav obligāti nepieciešams konts vai grupa.

### 2.2. AI Receipt Scanner

Lietotājs nofotografē čeku vai izvēlas foto no galerijas. AI mēģina noteikt:

- Tirgotāja nosaukumu un čeka datumu.
- Valūtu un kopējo summu.
- Visus produktus, ēdienus un dzērienus.
- Daudzumu, vienības cenu un pozīcijas summu.
- Atlaides, nodokļus un dzeramnaudu.

Rezultāts tiek ievietots rediģējamā **Itemized Split** sarakstā. Jātestē čeki dažādās valodās, tostarp latviešu, angļu, vācu, poļu, spāņu un franču.

### 2.3. Itemized Split

1. Pievienot dalībniekus (vārdus vai esošus kontaktus).
2. Piešķirt katru ēdienu vienam vai vairākiem dalībniekiem.
3. Kopīgas pozīcijas sadalīt vienādās vai individuālās daļās.
4. Sadalīt atlaides, nodokļus un dzeramnaudu pēc skaidriem noteikumiem.
5. Parādīt katra cilvēka galīgo summu.

**Finanšu aprēķinus veic SPLYTO kods, nevis AI.** Naudas summām izmantot precīzu decimālo aritmētiku vai mazākās valūtas vienības; korekti sadalīt noapaļošanas atlikumus.

### 2.4. Pabeigšana

- **Done** — pabeigt bez saglabāšanas.
- **Save to Archive** — saglabāt rēķinu.
- **Share Result** — kopīgot sadalījumu.
- **Add to Trip** — pēc izvēles pievienot esošai grupai.

Nākotnē: QR saite, lai dalībnieki paši atzīmē savas pozīcijas.

## 3. Vienotais Archive

> **Aizstāts 2026-11-16:** Quick splits būs sava cilne sākumlapā, nevis arhīvā (sk. 11. sadaļas beigas).

Esošajā **Archive** sadaļā rādīt gan arhivētos ceļojumus, gan saglabātos Quick Split rēķinus.

**Filtri:** All / Trips / Quick Splits.

Quick Split ierakstā saglabāt:

- Nosaukumu, datumu, valūtu, kopējo summu.
- Dalībniekus un katram aprēķināto summu.
- Itemizētās pozīcijas un to piešķīrumu.
- Atlaides, nodokļus, dzeramnaudu un piezīmes.

Rēķinam jābūt apskatāmam, kopīgojamam un dzēšamam. Nākotnē: PDF/CSV eksports. **Nesaglabāt automātiski** — izvēle pieder lietotājam. Konts nepieciešams mākoņa arhīvam, bet vienkāršajam kalkulatoram var nebūt vajadzīgs.

## 4. AI tehnoloģija un arhitektūra

Sākumā izmantot OpenAI **mini multimodālu API modeli**, piemēram, GPT-5.4 mini, ja izvēlētajā ieviešanas brīdī tas ir pieejams un piemērots. Pirms ieviešanas pārbaudīt aktuālo API cenu un iespējas.

```text
Flutter kamera / galerija
        ↓
PHP Backend — autentifikācija, kvotas, faila pārbaude
        ↓
ReceiptScanner → OpenAIProvider (nākotnē MindeeProvider)
        ↓
ReceiptNormalizer → vienots JSON formāts
        ↓
ReceiptValidator → kopsummu un pozīciju pārbaudes
        ↓
Flutter Itemized Split → lietotāja apstiprinājums
        ↓
MySQL, tikai ja lietotājs izvēlas saglabāt
```

**Nekad neiekļaut OpenAI API atslēgu Flutter klientā.**

Ieteicamie servisi:

- `ReceiptScanner` — orķestrē pieprasījumu.
- `OpenAIProvider` — OpenAI integrācija.
- `MindeeProvider` — iespējamā alternatīva nākotnē.
- `ReceiptNormalizer` — vienots čeka datu formāts.
- `ReceiptValidator` — pārbauda pozīcijas, summas un neatbilstības.

Tā var pāriet uz citu atpazīšanas pakalpojumu, nepārrakstot Flutter UI.

### Precizitātes noteikumi

- AI nedrīkst minēt nezināmas cenas kā drošus faktus.
- Neskaidrās pozīcijas jāatzīmē pārbaudei.
- Salīdzināt pozīciju summas, atlaides, nodokļus un čeka kopējo summu.
- Neieskaitīt nodokļus/atlaides divreiz.
- Neatbilstības skaidri parādīt lietotājam.
- Visus laukus var labot manuāli.
- Pirms saglabāšanas jāapstiprina rezultāts.

## 5. AI izmaksu kontrole

**Sākotnējais plānošanas budžets: 10–20 USD mēnesī.** Ilustratīvs viena čeka apstrādes izmaksu diapazons: aptuveni 0,005–0,02 USD; reālo cenu noteikt ar testiem un aktuālajiem API tarifiem.

Uzskaitīt katra pieprasījuma modeli, tokenus, izmaksas, kļūdas, atkārtotos mēģinājumus, dienas un mēneša patēriņu.

**Stingru budžeta kontroli nodrošina pats PHP backend**, pirms ārējā API izsaukuma atomiski rezervējot tā maksimālo izmaksu augšējo robežu (sk. 12. sadaļu). Pakalpojuma paneļa brīdinājumi vai projekta budžeta iestatījumi vieni paši nav jāuzskata par garantētu maksājumu apturēšanu. Pēc iekšējā limita sasniegšanas AI skenēšana apstājas, bet manuālais Quick Split darbojas.

## 6. Drošība pret botiem un API ļaunprātīgu izmantošanu

**Obligāta pirms publiskas AI funkcijas palaišanas.**

### 6.1. Atslēgas un autentifikācija

- OpenAI API atslēga tikai serverī, drošā konfigurācijā.
- Neiekļaut atslēgas Flutter un Git repozitorijā.
- Atsevišķs API projekts, minimālas tiesības, atslēgu rotācija.
- Serverī pārbaudīt katra skenēšanas pieprasījuma autentifikāciju.

### 6.2. Sākotnējie kvotu orientieri

| Ierobežojums | Sākuma variants |
|---|---|
| AI skenēšana bez konta | Nav pieejama |
| Jauns publiskais lietotājs | Sākuma priekšlikums: 3 čeki dienā, 20 mēnesī; sk. 12. sadaļu |
| Biežums | Līdz 2 pieprasījumiem minūtē |
| Paralēlie pieprasījumi | 1 uz lietotāju |
| Maksimālais attēls | 5 MB, plus pikseļu limits |
| AI izvade | Noteikts maksimālais tokenu skaits |

Kvotas uzturēt backend un rezervēt atomiski, lai paralēli pieprasījumi nevarētu apiet limitu.

### 6.3. Cloudflare

- WAF un rate limiting noteikumi AI endpointam.
- Aizdomīgas automatizētas plūsmas bloķēšana.
- Pieprasījumu izmēra kontrole.
- Neizmantot tikai IP adresi kā vienīgo lietotāja identifikatoru.

### 6.4. Lietotnes autentiskums

Pirms AI atvēršanas visiem ieviest **Apple App Attest** un **Google Play Integrity API**
ar konkrētajai skenēšanai piesaistītu servera pārbaudi (sk. 12. sadaļu). Tie papildina
autentifikāciju un servera kvotas; īsta lietotne pati par sevi nepierāda godīgu lietošanu.

### 6.5. Failu un AI drošība

- Atļaut tikai paredzētos attēlu formātus.
- Validēt reālo faila saturu, nevis tikai paplašinājumu.
- Ierobežot faila izmēru un pikseļu skaitu.
- Noņemt nevajadzīgus EXIF metadatus.
- Čekā redzamu tekstu apstrādāt kā datus, nevis instrukcijas AI sistēmai.
- Noildzes, atkārtotu mēģinājumu un izmaksu limiti.

### 6.6. Privātums

- HTTPS un ierobežota piekļuve saglabātajiem rēķiniem.
- Minimāla datu glabāšana, pagaidu attēlu automātiska dzēšana.
- Lietotāja iespēja dzēst saglabātos ierakstus.
- Pārskatāms paziņojums par AI apstrādi un pakalpojuma sniedzēju.
- GDPR un ārējo datu apstrādātāju noteikumu izvērtēšana.

## 7. Datu modelis

Quick Split neveidot kā parastu ceļojumu.

```text
Trips
  ├── Active Trips
  └── Archived Trips
Quick Splits
  ├── Bill Details
  ├── Items
  ├── Participants
  ├── Item Assignments
  └── Settlement Results
Archive (vienots UI)
  ├── Archived Trips
  └── Saved Quick Splits
```

Arhīvā piekļuves kontrole: lietotājs var piekļūt tikai saviem vai viņam tiesiski kopīgotajiem datiem.

## 8. Izstrādes posmi

### Phase 1 — Quick Split MVP

- [ ] Poga sākuma ekrānā.
- [ ] Manuāla summa, valūta un dalībnieki.
- [ ] Equal / Custom Split, dzeramnauda.
- [ ] Rezultāta kopīgošana.
- [ ] Save to Archive.
- [ ] Archive: All / Trips / Quick Splits.

### Phase 2 — AI Receipt Scanner

- [ ] Kamera, galerija, foto apgriešana.
- [ ] Attēla optimizācija un validācija.
- [ ] OpenAI integrācija caur PHP.
- [ ] Vienots Receipt JSON formāts.
- [ ] Pozīciju nolasīšana un rediģēšana.
- [ ] Summu validācija, kļūdu apstrāde.

### Phase 3 — Drošība (jāpabeidz pirms AI publiskās palaišanas)

- [ ] Autentifikācija un atomiskas kvotas.
- [ ] Cloudflare WAF/rate limiting.
- [ ] API atslēgu aizsardzība.
- [ ] Iekšējais budžeta limits un izmaksu žurnāls.
- [ ] Attēlu dzēšana un privātuma politika.
- [ ] Slodzes un ļaunprātīgas izmantošanas testi.

### Phase 4 — Paplašinājumi

- [ ] QR saite dalībnieku pozīciju izvēlei.
- [ ] PDF/CSV eksports.
- [ ] Add to Trip.
- [ ] Revolut / Wise maksājumu saites.
- [ ] Mindee vai cita AI pakalpojuma adapters.
- [ ] Precizitātes un izmaksu automātisks salīdzinājums.

## 9. Testēšana

Pirms publiskas palaišanas testēt **100–200 reālus čekus** no Latvijas, Vācijas, Polijas, Lietuvas, Spānijas, Francijas un Lielbritānijas.

Iekļaut īsus, garus, izbalējušus čekus, dažādas valodas, atlaides, nodokļus un dzeramnaudu.

Mērīt:

- Pareizi atpazīto pozīciju īpatsvaru.
- Cenu/daudzumu precizitāti.
- Kopsummas sakritību.
- Lietotāju labojumu biežumu.
- Apstrādes ilgumu un cenu.

Pirms izlaides vajadzības gadījumā izvērtēt intelektuālā īpašuma/patentu riskus. SPLYTO interfeiss un funkciju realizācija jāizstrādā neatkarīgi.

## 10. Produkta princips

**SPLYTO Quick Split — ātrs, vienkāršs un bezmaksas.**

Parastu rēķinu var sadalīt dažu sekunžu laikā bez grupas veidošanas. Sarežģītākiem čekiem AI izveido itemizētu sarakstu; cilvēki norāda, kurš par ko maksā. Visi aprēķini ir pārbaudāmi, labojami un pēc izvēles saglabājami vienotajā arhīvā.

**Ilgtermiņa mērķis:** SPLYTO kā universāla lietotne ceļojumu un ikdienas kopīgo izdevumu sadalīšanai — bez abonementiem, reklāmām un nevajadzīgas sarežģītības.

---

## 11. Saistība ar esošajiem lēmumiem (piezīmes 2026-11-16)

Jāizlemj pirms būvēšanas:

- **Bezmaksas ar limitiem (izlemts 2026-11-16).** Pirmos 1–2 gadus Premium nebūs; visas funkcijas,
  arī AI čeku skenēšana, pieejamas visiem, lai iegūtu lietotājus. AI čekiem būs limiti, un lietotnē
  tie jāpaskaidro saprotami (cik palicis, kad atjaunojas, ka manuālā dalīšana strādā vienmēr).
  Precīzus limitus un tekstu izlemt vēlāk.
- **AI pakalpojuma sniedzējs.** Agrāk paredzēts salīdzināt Anthropic modeļus (Haiku/Sonnet) uz 30–50
  reāliem čekiem; šis plāns min OpenAI. Atstāt `ReceiptScanner` ar adapteriem un izvēlēties pēc
  precizitātes un cenas testa uz vieniem un tiem pašiem čekiem.
- **Privātuma politika un veikali.** Pirms AI palaišanas politikā jānorāda, kurš pakalpojuma sniedzējs
  apstrādā čeku foto (un datu pārsūtīšana ārpus ES), jāatjauno App Store privacy un Play Data safety.

Ko izmantot no esošā:

- **"By item" dalīšana ar "Tax or tip"** (`extra_amount`) jau ir app; Itemized Split jābūvē uz tās pašas
  loģikas un UI, nevis no jauna.
- **Dalībnieki bez konta** (plānots atsevišķi) ir tas pats, kas Quick Split dalībnieki pēc vārda;
  vienots modelis atvieglos "Add to Trip".
- **Expense types** (Food · Restaurant) — AI var ieteikt kategoriju un tipu no tirgotāja nosaukuma.

Ieteiktā secība:

1. Phase 1 kā **lokāls kalkulators bez servera** (nav API izmaiņu, var iznākt ātri, strādā bezsaistē).
2. Save to Archive / Add to Trip — prasa API un DB izmaiņas, līgumu un atļauju.
3. AI tikai pēc drošības posma (kvotas, budžets, attēlu dzēšana, politika).

### Izlemts 2026-11-16: AI čeki sākumā tikai Quick Split

Plūsma: **Quick Split → nofotografē čeku → AI sadala pozīcijas → piešķir cilvēkiem → beigās izvēle:**

- **Add to Trip** — pievieno esošam ceļojumam kā izdevumu;
- **Save to Archive** — saglabā kā vienkāršu rēķinu arhīvā;
- **Done** — nesaglabā neko.

AI pie parastā ceļojuma izdevuma ("Add expense") sākumā nebūs; ceļojumi AI dabū caur "Add to Trip".
Serverī čeku nolasīšanu būvēt kā vienu kopīgu servisu, lai vēlāk to var pieslēgt arī "Add expense",
ja lietotāji to prasīs.

Secība: 1) Quick Split manuāli → 2) AI čeki Quick Split → 3) Add to Trip / Archive → 4) AI pie ceļojuma
izdevumiem pēc pieprasījuma.

### Izlemts 2026-11-16: Quick splits cilne un sākšana

Mockup: `output/design/expense-subcategories/board21.png` (iepriekšējais variants board20.png).

**Sava cilne sākumlapā, nevis arhīvā.**

- Sākumlapas pārslēdzējā ir trīs ikonas: tripi · ⚡ Quick splits · arhīvs. Virsraksts mainās līdzi,
  piemēram, "Your quick splits".
- Augšā ir "Open" (kur vēl kāds kādam ir parādā): +€ zaļā krāsā, ja tev jāsaņem, −€, ja tu esi parādā.
  Apakšā pelēcīgi "Settled". Atsevišķa arhīva nokārtotiem nav.
- Pārnests uz tripu → no šīs cilnes pazūd, jo izdevums tagad dzīvo tripā.
- Cilne redzama vienmēr. Tukšā cilnē ir viena īsa rinda, bez gariem skaidrojumiem.

**Sākšana.**

- Augšējais "+" paliek "New trip".
- Vidējā Expenses poga pēc noklusējuma atver Add expense **aktīvajam tripam**, kā līdz šim. Quick split
  izvēlas, uzspiežot "▾" zem virsraksta. Ja aktīva tripa nav, forma atveras uzreiz kā Quick split.
- **Forma ir tā pati Add expense**: summa, valūta, Note, Category, datums, Paid by, Split between,
  Equal / Custom split. Zem virsraksta trip nosaukuma vietā ir "⚡ Quick split ▾", un to var pārslēgt
  uz kādu tripu (tad tas ir parasts trip izdevums).
- Cilvēki tiek pievienoti tāpat kā Add expense: draugi ar avatāriem, un "+" pievieno arī vārdu bez konta.
- **Kameras poga pa kreisi no summas.** Tā atver sistēmas izvēlni: Scan receipt / Choose from Photos /
  Choose file / Cancel. Ja to neaiztiek, summu ievada kā parasti.
- Pēc skenēšanas summa, nosaukums un pozīcijas ir aizpildītas. Ieslēgts "Custom split → By item", un
  "Add receipt" vietā ir nolasītais čeks ("7 items read · tap to check").
- Kameras poga sākumā ir tikai Quick split režīmā (sk. iepriekšējo lēmumu). Vēlāk to pašu pogu var likt
  arī trip Add expense.

**Beigas.** Pēc pogas "Split" no apakšas izbīdās logs pāri formai. Tajā ir kopsumma un kurš maksāja,
cik katram jāmaksā, poga "Share result" un trīs izvēles:

- **Keep in Quick splits** (galvenā) — paliek cilnē, lai var sekot, kurš atdevis;
- **Add to a trip** — kļūst par trip izdevumu un no cilnes pazūd;
- **Don't save** — aizver.

### Izlemts 2026-11-17: Quick split ir kopīgs ar iesaistītajiem

Aizstāj 2.4 "Save to Archive" un 3. sadaļas vienoto arhīvu.

- **Glabājas serverī**, nevis tikai telefonā. Katrs dalībnieks ar Splyto kontu to redz savā
  Quick splits cilnē un saņem paziņojumu (piemēram, "Matiss added you to a quick split").
  Tikai lokāla glabāšana nederēja: "Share" aizsūta tekstu, ko otrs nevar pievienot savai cilnei.
- **Cilvēki bez app:** tāpat kā tripā (dalībnieki bez konta), izveido cilvēku tikai šim
  quick split; viņš rezultātu redz caur "Share result".
- **Bez naudas izsekošanas:** nav "Request", "I paid" vai "Confirm". Quick split ir ieraksts
  "kurš maksāja, kas ko ēda, cik katram sanāca", un tiek pieņemts, ka uz vietas viss nokārtots.
  Tāpēc cilnē nav "Open / Settled" dalījuma, tikai saraksts pēc datuma (jaunākais augšā).
- **Add to a trip** paliek: quick split kļūst par parastu tripa izdevumu (esošais `add_expense`,
  ieskaitot "By item"), un no Quick splits cilnes pazūd. Tad bilances un norēķini strādā kā tripā.
- **Forma** ir tā pati Add expense (board21): "⚡ Quick split ▾" trip nosaukuma vietā, kameras
  poga blakus summai AI čekiem vēlāk. Vidējā Expenses poga pēc noklusējuma pievieno aktīvajam
  tripam; Quick split izvēlas ar "▾"; ja aktīva tripa nav, atveras kā Quick split.
- **Kurš var labot/dzēst:** tas, kurš izveidoja (tāpat kā izdevumu tripā).
- **Serveris:** jaunas tabulas, API darbības (izveidot, sarakstīt, atvērt, labot, dzēst, pārnest
  uz tripu) un paziņojuma veids. Pirms koda: līguma dokuments `docs/api/quick-splits.md` un
  īpašnieka atļauja; deploy un migrācija tikai pēc iOS 1.0.20 review
  (`docs/operations/release-1.1.0-server-steps.md` papildināt).

### Izlemts 2026-11-17: čeka foto tikai caur kameras pogu

- Atsevišķās rindas "Add receipt" formas apakšā vairs nav. Čeku pievieno ar kameras pogu
  pa kreisi no summas, gan tripa izdevumam, gan Quick split.
- Kameras poga atver izvēlni: Scan receipt / Choose from Photos / Choose file / Cancel.
  Kamēr AI nav, tā tikai piesaista čeka foto; vēlāk tā pati poga palaiž arī AI nolasīšanu.
- Kad čeks pievienots, formas apakšā "Add receipt" vietā rāda čeka bildi (pieskaroties var
  apskatīt, nomainīt vai noņemt).
- Quick split arī glabā čeka foto (`receipt_path`, sk. `docs/api/quick-splits.md`).

### Ieviests kodā 2026-11-22: pašu čeka apgriešanas ekrāns

- Čeku kamera un apgriešana ir vienā Flutter maršrutā: fotografēšana → apgriešana →
  **Save** augšā pa labi. **Retake** apakšā atgriež kameru tajā pašā plūsmā. iPhone sistēmas
  “Retake / Use Photo” starplogs un atgriešanās izdevuma formā pirms crop vairs nav.
  Galerija un attēla faili turpina izmantot sistēmas izvēlētāju un mūsu crop ekrānu.
- Sākumā atlasīta visa bilde. Čekam ir brīvas proporcijas: var vilkt četras malas un
  stūrus, pārvietot rāmi, pagriezt par 90° un atiestatīt. Izskats atbilst ceļojuma
  bildes editoram: melns fons, balts rāmis/režģis, krustiņš pa kreisi un **Save** pa labi;
  aizvēršana atceļ pievienošanu un saglabā izdevuma melnrakstu.
- Izdevumam/Quick Split augšupielādē apgriezto kopiju; AI saņem šo pašu čeku.
  Galerijas/faila oriģināls netiek pārrakstīts. Mūsu kameras pagaidu fails pēc nolasīšanas
  tiek dzēsts; neapstiprināts foto paliek tikai atvērtās plūsmas atmiņā.
  Saglabāti augšupielādes izmēra un
  pikseļu limiti, kā arī pārbaudes, vai nav mainījies konts.
- Kamerai pievienota Flutter `camera` pakotne (SDK saderīgā `0.12.0+2` versija),
  bez audio ieraksta. Android manifestā izņemta pakotnes mikrofona atļauja.
  Kameras darbības tiek izpildītas secīgi; aizvēršana/fons atbrīvo kameru,
  atgriešanās to atjauno, un novēloti rezultāti netiek pielietoti pēc konta maiņas.
- Kods: `mobile/lib/core/media/receipt_camera_page.dart`, `receipt_crop*.dart`; kopīgā izvēles plūsma:
  `mobile/lib/features/workspace/presentation/pages/workspace_expense_form_setup.dart`.
- Jauna lietotnes versija vēl jāuzliek telefonā. Reālā kameras → crop pāreja un HEIC
  attēli jāpārbauda iOS/Android ierīcēs; izmaiņa neprasa servera API maiņu.

### Izlemts 2026-11-17: AI vispirms tikai testa kontiem, ar karogu

Nākamais lielais darbs pēc Quick split. AI čeku nolasīšana nonāk produkcijas app, bet strādā tikai
kontiem, kam tā ieslēgta admin panelī (sākumā īpašnieks un daži testētāji). Pārējie redz to pašu
kameras pogu, kas tikai pievieno čeka foto. **Visi limiti un aizsardzība jābūt gataviem jau pirms
pirmā testa konta**, jo AI darbība būs produkcijas serverī un to var mēģināt izsaukt arī citi.

**Funkciju karogi (feature flags)**

- Serverī karogi pa kontiem, piemēram `receipt_ai`. Konta datos (`me`) app saņem
  `features: { receipt_ai: true }` un tikai tad rāda AI izvēli.
- **Serveris pārbauda karogu katrā AI pieprasījumā, pirms jebkādām izmaksām.** Paslēpta poga
  nav aizsardzība.
- Admin panelī: kontu meklēšana, karoga ieslēgšana/izslēgšana, kas un kad ieslēdza (ieraksts
  žurnālā), un globāls slēdzis "AI izslēgts visiem" avārijas gadījumam.
- Vēlāk to pašu mehānismu var izmantot citām funkcijām; publiskai palaišanai karogu ieslēdz
  visiem bez jaunas app versijas.

**Limiti un aizsardzība pret botiem** (papildina 5. un 6. sadaļu)

Pārbaudes secība katram pieprasījumam, lētākās vispirms; neviena ārēja AI izsaukuma, ja kāda
neiziet:

1. Pieslēdzies konts ar apstiprinātu e-pastu, aktīvs, nav viesis; globālais slēdzis ieslēgts.
2. Karogs `receipt_ai` šim kontam.
3. Biežums: līdz 2 pieprasījumiem minūtē uz kontu, 1 vienlaicīgs; arī uz IP (esošais
   `enforce_rate_limit`).
4. Kvota uz kontu: testa posmā 20 čeki dienā un 200 mēnesī (publiski: 6.2 sadaļas skaitļi).
   Rezervē atomiski kopā ar budžetu. Noildze nav pamats automātiskai izmaksu rezervācijas
   atbrīvošanai: pakalpojums var būt jau izpildījis maksas darbu (sk. 12. sadaļu).
5. **Globālais budžets ar cieto apstāšanos**: piemēram 2 USD dienā un 20 USD mēnesī testa
   posmā, papildus konfigurējams stundas limits. Maksimālās izmaksas rezervē pirms izsaukuma;
   sasniedzot jebkuru limitu, AI apstājas visiem, bet manuālā dalīšana un čeka foto strādā.
6. Attēls: tikai JPG/PNG/WebP/HEIC, pārbaudīts saturs, līdz 5 MB un pikseļu limitam, bez EXIF.
7. Tas pats attēls (hash) tajā pašā kontā nedēļas laikā atgriež iepriekšējo rezultātu bez
   jauna izsaukuma.
8. Izsaukumam: maksimālais tokenu skaits, noildze, bez automātiskiem atkārtojumiem pēc
   maksas kļūdām.

Ārpus app:

- Cloudflare: atsevišķs rate limiting noteikums AI adresei un bot aizsardzība tai.
- AI pakalpojumā: atsevišķs projekts ar savu atslēgu (tikai serverī) un pakalpojuma
  budžeta brīdinājumi kā otrā līnija (ne vienīgā).
- Uzraudzība: katra izsaukuma modelis, tokeni, izmaksas, ilgums, kļūda; dienas kopsumma
  ops digestā; brīdinājums, ja izmaksas vai kļūdas pēkšņi aug vai kāds konts sit limitus.
- Vēlāk, pirms publiskas palaišanas: Apple App Attest un Google Play Integrity.

**Pirms pirmā testa konta (obligāti)**

- Privātuma politikā nosaukts AI pakalpojuma sniedzējs un datu pārsūtīšana ārpus ES (ja tāda
  ir); App Store privacy un Play Data safety atjaunoti.
- API līgums (`docs/api/feature-flags.md`, `docs/api/receipt-scan.md`) un migrācijas,
  īpašnieka apstiprināti.
- App Review piezīmēs uzrakstīt, ka AI čeku nolasīšana ieslēgta tikai testa kontiem, un dot
  recenzentiem kontu, kam tā ir ieslēgta.

**Secība**

1. Karogi + admin panelis + globālais slēdzis (bez AI).
2. Limiti, budžeta rezervācija, žurnāls, uzraudzība un Cloudflare noteikums.
3. AI pakalpojuma izvēle (30–50 īstu čeku tests, sk. 11. sadaļu) un `ReceiptScanner`.
4. App: AI izvēle kameras izvēlnē tikai ar karogu, rezultāts "By item" redaktorā.
5. Ieslēgt īpašniekam → dažiem manuāli atļautiem testētājiem.
6. Pirms publiskas palaišanas: App Attest / Play Integrity, mazas sākuma kvotas un
   12. sadaļas pārbaužu izpilde; tikai pēc tam lemt par atvēršanu visiem.

### Plāns 2026-11-17: pats AI — kas tas būs

**Pakalpojums.** Sākt ar Anthropic Claude (attēli + strukturēta JSON atbilde vienā izsaukumā),
bet serverī paturēt `ReceiptScanner` ar adapteriem, lai var pārslēgties uz citu pakalpojumu.
Galīgo modeli izvēlas pēc testa uz vieniem un tiem pašiem 30–50 īstiem čekiem:

| Modelis | Loma testā | Aptuvenās izmaksas par čeku* |
|---|---|---|
| Claude Haiku 5.5 | galvenais kandidāts (lēts, ātrs) | ~0,001 USD |
| Claude Sonnet 5.5 | ja Haiku kļūdās sarežģītos čekos | ~0,01–0,015 USD |
| Claude Opus 5.5 | tikai kā kvalitātes etalons testā | ~0,02–0,03 USD |

\*Pēc 2026-11 cenrāža (Haiku 5.5: 0,10/0,50 USD, Sonnet 5.5: 2/10 USD, Opus 5.5: 4/20 USD par
miljonu ievades/izvades tokenu) un pieņēmuma: viens čeka attēls ~1 500 tokenu, instrukcijas ~800,
atbilde ~500 plus domāšana. Īstos skaitļus izmērīt testā (`usage` katrā atbildē) un pirms
ieviešanas pārbaudīt aktuālo cenrādi. Ar 20 USD mēnesī Haiku pietiek ~20 000 čekiem.

Izvēles noteikums: lētākais modelis, kam testā **kopsumma sakrīt ≥95% čeku** un **pozīcijas
pareizas ≥90%**; ja Haiku to nesasniedz, Sonnet.

**Plūsma**

1. App augšupielādē čeka foto kā tagad (`upload_receipt`), tad piesaka vienu skenēšanas
   uzdevumu (`scan_receipt`, plānotajā līgumā: `receipt_path` un stabils pieprasījuma ID).
   Serveris pārbauda `receipt_ai`, čeka īpašumtiesības un atkārtota pieprasījuma identitāti.
2. Serveris izpilda karoga, limitu un budžeta pārbaudes (sadaļa "AI vispirms tikai testa
   kontiem"), samazina attēlu (garākā mala ~1 568 px), noņem EXIF.
3. Viens Claude Messages API izsaukums no PHP ar oficiālo `anthropic-ai/sdk` (composer):
   attēls + fiksētas instrukcijas + JSON shēma (`output_config.format`, strukturētā atbilde).
   Iestatījumi ir pirms ieviešanas pārbaudāmi orientieri: zema `effort`, `max_tokens` ~2 000,
   noildze ~30 s. Sākumā izslēgt automātiskos atkārtojumus arī SDK līmenī; noildzi un 5xx
   neuzskatīt par pierādījumu, ka maksas apstrāde nav notikusi. Pārbaudīt `stop_reason`
   (arī `refusal`); iespējamajiem atkārtojumiem piemērot 12. sadaļas budžeta noteikumus.
4. PHP `ReceiptValidator` pārbauda rezultātu un atgriež to app.
5. App aizpilda summu, nosaukumu, datumu un "By item" pozīcijas; ieslēgts "Custom split → By
   item"; lietotājs pārbauda un saglabā. Nekas netiek saglabāts automātiski.

**JSON shēma (ko AI atgriež)**

- `is_receipt` (vai attēlā vispār ir čeks), `merchant`, `date`, `currency`;
- `items[]`: `name`, `quantity`, `unit_price`, `total`, `uncertain` (vai nolasīts droši);
- `discounts`, `tax`, `tip`, `service_charge`, `total`;
- `notes`: īsi par to, kas nebija salasāms.

**Pārbaudes serverī (nevis AI)**

- Pozīcijas + nodoklis + dzeramnauda − atlaides = kopsumma (±0,01); ja nē, app parāda
  brīdinājumu "Summas nesakrīt, pārbaudi pozīcijas".
- Valūta no atbalstīto saraksta, datums saprātīgā robežā, summas pozitīvas, līdz 100 pozīcijām,
  nosaukumi līdz 80 zīmēm (tie paši noteikumi kā "By item").
- Visu naudas aritmētiku dara Splyto kods centos, ne AI.
- Čekā redzamais teksts ir dati: instrukcijas to skaidri pasaka, un atbilde ir tikai shēmā.

**Privātums un dati**

- Uz AI tiek sūtīts tikai čeka attēls, bez vārdiem, e-pastiem vai tripa datiem.
- Pirms pirmā testa konta: politikā nosaukt Anthropic kā apstrādātāju, pārbaudīt datu
  glabāšanas nosacījumus un datu pārsūtīšanu ārpus ES; atjaunot App Store / Play atbildes.
- Atsevišķs Anthropic API projekts un atslēga tikai servera konfigurācijā.

**Tests pirms izvēles**

- 30–50 īsti čeki: LV, EN, DE, PL, ES, FR; īsi, gari, izbalējuši, ar atlaidēm, nodokļiem,
  dzeramnaudu, saliekti un tumši foto.
- Katram modelim mēra: kopsummas sakritību, pozīciju precizitāti, cenas/daudzumus, laiku,
  izmaksas (`usage`). Rezultātu tabula `docs/mobile/receipt-ai-test.md`.
- Tests maksā naudu (daži dolāri); to palaiž tikai ar īpašnieka piekrišanu.

## 12. AI aizsardzības papildinājumi (izlemts 2026-11-17)

Mērķis: apgrūtināt automatizētu piekļuvi un ierobežot izdevumus arī tad, ja uzbrucējs
iztur piekļuves pārbaudes. Ne CAPTCHA, ne īsta ierīce, ne apstiprināts e-pasts atsevišķi
negarantē godīgu lietošanu. Šeit minētie jaunie publisko kvotu skaitļi ir sākuma priekšlikums;
galīgās vērtības jānosaka pirms palaišanas. API līgumi un migrācijas vēl jāapstiprina atsevišķi.

### Lietotnes autentiskums pirms publiskas palaišanas

- iOS: App Attest atslēgas apliecinājumu pārbaudīt serverī; skenēšanas pieprasījumam izmantot
  assertion ar servera izdotu īslaicīgu, vienreizēju challenge un pārbaudīt tā skaitītāju.
- Android: Play Integrity standard pārbaude serverī, pārbaudot paredzēto lietotni,
  parakstīšanas sertifikātu, vidi un atbilstošos integritātes verdictus. Ar `requestHash`
  piesaistīt pārbaudi konkrētajam saturam; pārbaudīt arī pieprasījuma svaigumu.
- Abās platformās pārbaude aptver darbību, kontu, serverī aprēķināto čeka satura nospiedumu
  un skenēšanas pieprasījuma ID. Klienta nosūtīts `verified: true` vai `device_id` nav pierādījums.
- Vispirms pārbaudīt darbību reālajās App Store / TestFlight un Google Play testa/izlaides
  vidēs. Pirms obligātas piemērošanas apkopot kļūdu īpatsvaru, neglabājot pilnus tokenus.
  Debug apiešana atļauta tikai izolētā izstrādes vidē, ne publiskajā serverī.
- Ja apliecinājumu nevar pārbaudīt vai ierīce nav atbalstīta, publiskais AI maksas izsaukums
  nenotiek; parādīt saprotamu kļūdu un iespēju mēģināt vēlāk. Manuālā dalīšana paliek pieejama.
- Šīm pamata pārbaudēm nav plānota atsevišķa maksa par izsaukumu; jāparedz ieviešanas darbs,
  servera slodze un platformu kvotas. Google sākotnēji dokumentē 10 000 dienas tokenu
  pieprasījumu/sagatavošanas un atsevišķi 10 000 tokenu atšifrēšanas kvotas uz Cloud projektu.
  Kvotu palielinājums jāpieprasa; pirms ieviešanas vēlreiz pārbaudīt noteikumus. Tas nav
  solījums par neierobežotu lietošanu vai visu papildu funkciju bezmaksas pieejamību.

### Daudzu kontu un automatizācijas ierobežošana

- Slēgtajā testā AI tikai admina manuāli atļautiem kontiem. Publiski jaunam verificētam
  kontam sākuma priekšlikums ir 3 skenējumi dienā un 20 mēnesī; palielinājumi tikai pēc
  serverī noteiktiem uzticamības kritērijiem vai admina lēmuma. Konta vecums viens pats neder.
- Papildus konta kvotai vērtēt kontu maiņas un pārmērīgu aktivitāti pārbaudītā lietotnes
  instalācijā, kā arī IP līmeņa plūsmu. Instalācijas atslēga nav pastāvīgs fiziskas ierīces ID;
  pārinstalēšana var mainīt identitāti. Nekādu neierobežotu kvotu par jaunu klienta ID.
- IP ir papildu signāls, ne vienīgā identitāte: viesnīcas Wi-Fi vai mobilais operators var
  apvienot daudz godīgu lietotāju. Riskus vērtēt kombinācijā; neieviest vispārēju VPN aizliegumu.
- Turnstile izmantot vajadzības gadījumā aizdomīgai reģistrācijai vai AI aktivizēšanai,
  ne katram čekam. Mobilajā app tam vajadzīga WebView plūsma un tokena pārbaude serverī.
  Pārbaude nav bezgalīga atļauja AI izsaukumiem. Signālu glabāšanai noteikt minimālu termiņu.

### Budžets, noildzes un viens uzdevums vienai skenēšanai

- Pirms nosūtīšanas vienā MySQL transakcijā rezervēt konta kvotu, vietu vienlaicīgā darba
  limitā un globālā stundas/dienas/mēneša budžeta daļu. Izmantot unikālus ierobežojumus un
  rindu bloķēšanu; tikai `SELECT` pirms `INSERT` nenodrošina aizsardzību pret sacensību.
  Ārējā AI izsaukuma laikā datubāzes transakciju neturēt atvērtu.
- Rezervēt konservatīvu maksimālo maksu par izvēlēto modeli, ierobežoto attēla/ievades apjomu,
  izvadi un domāšanas tokeniem, ja tādi ir. Nepietiek ar vidējo cenu par čeku. Modeļus,
  parametrus un tarifu versiju nosaka serveris; cenrādis jāpārbauda pirms modeļa ieslēgšanas.
- `iztērēts + rezervēts + jaunā rezervācija` nedrīkst pārsniegt nevienu attiecīgo limitu.
  Ja kvotu datubāze vai izmaksu aprēķins nav pieejams, AI izsaukumu neveikt. Uzskaiti veikt
  precīzās mazās USD vienībās, ne peldošā komata skaitļos; periodus definēt servera UTC laikā.
- Lietotāja čeku kvotu nodalīt no izmaksu žurnāla. Noildze, pārtraukts savienojums vai
  procesa avārija pēc nosūtīšanas atstāj izmaksas kā neskaidras un rezervētas. Rezervācijas
  vecums pats par sevi nav pierādījums, ka izsaukums neko nemaksāja. Pirms nosūtīšanas
  droši atceltiem uzdevumiem rezervāciju var atbrīvot; pabeigtiem salīdzināt ar faktisko usage.
- Katram kontam un pieprasījuma ID viens uzdevums. Tā paša ID atkārtojums ar to pašu saturu
  atgriež statusu/rezultātu; ar citu saturu tiek noraidīts. Pogas atkārtota nospiešana un app
  restartēšana nedrīkst atkārtot ārējo maksas izsaukumu. Statusa lasīšana ir autentificēta,
  pieder tikai uzdevuma kontam un ir ierobežota pēc biežuma.
- Vienlaikus saņemtus vienāda čeka uzdevumus vienā kontā atomiski apvienot arī ar dažādiem ID.
  Gatavo rezultātu kešot līdz nedēļai, ievērojot dzēšanu un skenera versiju. Satura hash
  aprēķina serveris; nedaudz mainīts attēls var to apiet, tāpēc kešs neaizstāj kvotas.
- Sākumā nekādu automātisku provider/SDK atkārtojumu. Vēlāk jebkuram atļautam atkārtojumam
  jābūt atsevišķi uzskaitītam un segtam ar rezervāciju, arī ja iepriekšējais mēģinājums
  varēja izmaksāt naudu. Negarantēt tieši vienu ārējo izsaukumu pēc neskaidras procesa avārijas;
  šādu darbu automātiski nesūtīt vēlreiz.
- AI jau apstrādāts nederīgs attēls, atteikums vai nekorekts JSON joprojām tiek uzskaitīts
  izmaksās un ļaunprātīgu mēģinājumu limitos. Lietotājam piešķirta kvotas kompensācija
  neatceļ reāli iztērēto vai neskaidro summu.

### Piekļuve čekam un serverim

- `scan_receipt` serverī pārbauda, ka fails pieder pieprasītāja kontam, izmantojot esošo
  čeku īpašumtiesību loģiku. Nepietiek ar zināmu `receipt_path` vai piekļuvi kopīgam tripam.
  Neatļaut klienta norādītas ārējas adreses vai patvaļīgus servera failu ceļus.
- Serveris fiksē validētā attēla saturu uzdevumam, lai pēc rezervācijas nevar samainīt failu.
  Faila izmēra/pikseļu pārbaudes un augšupielāžu limiti darbojas arī pirms AI izsaukuma.
- Cloudflare noteikumiem jāaptver faktiskā AI darbība arī esošajā `api.php?action=...`
  maršrutēšanā. Pārbaudīt, ka tiešo servera IP vai alternatīvu domēnu nevar izmantot apiešanai.
  Izvēlēties atbilstošu ugunsmūra un origin autentifikācijas konfigurāciju; kopīgais Cloudflare
  sertifikāts viens pats apliecina Cloudflare tīklu, ne konkrēti mūsu kontu.
- Klienta IP galvenes uzticamas tikai no konfigurēta uzticama starpniekservera. Cloudflare
  biežuma ierobežojumi ir ārējais filtrs; precīzas kontu kvotas un naudas limiti paliek MySQL.
- Brīdinājumi par patēriņa kāpumu, daudzām atteiktām pārbaudēm un neskaidrām izmaksām;
  automātiska AI apturēšana pie konfigurētiem sliekšņiem un manuālais globālais slēdzis.
  Atkārtoti pārbaudīt slēdzi pirms nosūtīšanas. Jau nosūtītam darbam izmaksas var palikt.
  Žurnālos neglabāt čeku tekstus/attēlus, sesiju vai integritātes tokenus un API atslēgas.

### Obligātā pārbaude pirms attiecīgā posma ieslēgšanas

Pirms pirmā maksas testa pārbaudīt paralēlus pieprasījumus pie kvotas robežas, viena ID
atkārtošanu/mainītu saturu, vienāda attēla paralēlus uzdevumus, sveša čeka ceļu, izslēgtu
karogu, datubāzes kļūmi, izsmeltu budžetu, noildzi un procesa avāriju pēc nosūtīšanas.
Simulētais AI skaitītājs apliecina, ka noraidītie pieprasījumi nerada maksas izsaukumu un
neskaidrs darbs netiek automātiski nosūtīts atkārtoti. Budžeta sacensības testēt reālā
izolētā MySQL; testi neveic īstus maksas AI izsaukumus.

Pirms publiskas palaišanas papildus pārbaudīt App Attest / Play Integrity apliecinājumu
atkārtošanu, cita konta/attēla sasaisti, nederīgu vai novecojušu apliecinājumu, platformas
atteici, neatbalstītu ierīci, konta maiņu un mēģinājumu apiet Cloudflare. Pārbaudīt arī
godīga lietotāja atkārtotu mēģinājumu ar svaigu apliecinājumu un esošo uzdevuma ID.
Manuālie izdevumi un čeku pievienošana turpina strādāt, ja AI ir bloķēts.

Oficiālie ieviešanas avoti (pārskatīti 2026-11-17):

- [Apple App Attest servera validācija](https://developer.apple.com/documentation/devicecheck/validating-apps-that-connect-to-your-server)
- [Play Integrity standard pieprasījumi](https://developer.android.com/google/play/integrity/standard)
- [Play Integrity konfigurācija un kvotas](https://developer.android.com/google/play/integrity/setup)
- [Cloudflare origin aizsardzība](https://developers.cloudflare.com/fundamentals/security/protect-your-origin-server/)
- [Cloudflare rate limiting precizitātes ierobežojumi](https://developers.cloudflare.com/waf/rate-limiting-rules/)
- [Turnstile mobilajā app](https://developers.cloudflare.com/turnstile/get-started/mobile-implementation/)
- [Turnstile tokena validācija serverī](https://developers.cloudflare.com/turnstile/get-started/server-side-validation/)
