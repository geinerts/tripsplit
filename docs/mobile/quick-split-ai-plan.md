# SPLYTO — Quick Split & AI Receipt Scanner

**Funkcionalitātes ideja un tehniskās izstrādes plāns**  
**Statuss:** Ideja nākotnes izstrādei  
**Prioritāte:** Augsta  
**Mērķis:** Paplašināt SPLYTO lietošanu ārpus ceļojumu grupām, saglabājot lietotni bezmaksas un bez reklāmām.

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

**Stingru budžeta kontroli nodrošina pats PHP backend**, pirms ārējā API izsaukuma rezervējot paredzamo izmaksu kvotu. Pakalpojuma paneļa brīdinājumi vai projekta budžeta iestatījumi vieni paši nav jāuzskata par garantētu maksājumu apturēšanu. Pēc iekšējā limita sasniegšanas AI skenēšana apstājas, bet manuālais Quick Split darbojas.

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
| AI skenēšana bez konta | Nav pieejama vai stingri ierobežota |
| Reģistrēts lietotājs | Līdz 10 čekiem dienā |
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

Vēlāk apsvērt **Apple App Attest** un **Google Play Integrity API**. Tie ir papildu aizsardzības slāņi, nevis aizvietotājs autentifikācijai un servera kvotām.

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
