# Quick Start pirms reģistrācijas un ielūguma starplapa

Statuss: ieviests 2026-11-06 ar pagaidu ekrāniem. Vēl atliek:

- ielikt reālos ekrānuzņēmumus `quick_start_phone_screens.dart` vietā;
- pēc publicēšanas nomainīt TestFlight saiti uz App Store saiti (`SPLYTO_IOS_INSTALL_URL`
  failā `api/lib/web/splyto_share_page_text.php`);
- pārbaudīt ar reālu WhatsApp saiti telefonā;
- izdzēst neizmantotos karuseļa tekstus no ARB (`authIntroSplitSmarter` un līdzīgos).

Ielūdzēja vārds starplapā netiek rādīts, jo publiskā lapa nav vieta personas datiem.
`invite.html` un `friend.html` nginx vairs neizmanto, tie nav mainīti.

## Mērķis

1. Pirmajā atvēršanā cilvēks redz Quick Start, nevis pieteikšanās ekrānu.
2. Ielūguma saite bez instalētas lietotnes atver skaidru starplapu ar instalēšanas pogu.
3. Quick Start, pieteikšanās lapa un starplapa izskatās kā viens vesels.

## Galīgā plūsma

| Situācija | Ko cilvēks redz |
| --- | --- |
| Pirmā atvēršana | Quick Start, slaids uz abām pusēm vai Next, pēdējā pogā Sign up |
| Sign up | Galvenā pieteikšanās lapa |
| Izlaist augšā | Galvenā pieteikšanās lapa |
| Pēc reģistrācijas | Sākuma ekrāns, Quick Start otrreiz neatveras |
| Izlogojas | Galvenā pieteikšanās lapa, bez Quick Start |
| Atver, jau pieteicies | Sākuma ekrāns |
| Pārinstalē vai jauns telefons | Quick Start vienu reizi, tad pieteikšanās |
| Ielūguma saite atver lietotni | Bez Quick Start, pieteikšanās, tad ielūgums |
| Pārskatīt vēlāk | Profilā, kā tagad |

Ielūgums no WhatsApp bez lietotnes:

1. Saite atver starplapu.
2. Poga Instalēt ved uz veikalu. Pāreja nav automātiska, lai cilvēks izlasa norādi.
3. Cilvēks instalē, atgriežas WhatsApp un pieskaras saitei vēlreiz.
4. Atveras lietotne, viņš piesakās vai reģistrējas un nonāk pie ielūguma.

## Nepieciešams pirms sākšanas

- **Ekrānuzņēmumi 6 slaidiem:** izveidot ceļojumu, izdevums, norēķini, analītika, karte,
  atrašanās vieta reāllaikā.
  - Uzņemt ar izdomātu demo kontu, bez īstiem vārdiem, e-pastiem un fotoattēliem.
  - Bez Mapbox kartes attēliem: Mapbox noteikumi aizliedz tos izplatīt kā statiskus attēlus.
    Kartes slaidiem paliek pašu zīmējums (`mobile/tool/generate_quick_start_maps.py`) vai
    dzīva karte.
- **Instalēšanas saite:** App Store saite pēc publicēšanas, līdz tam publiskā TestFlight saite.

## Lēmumi, kas jāpieņem sākumā

1. **Ekrānuzņēmumu valodas:** izlemts, attēli ir angļu valodā. Virsraksti slaidā paliek
   tulkoti, kā tagad, pēc telefona valodas.
2. **Attēlu formāts:** WebP, ja izmērs ir būtiski mazāks, un jāizmēra lietotnes pieaugums.
3. **Pieteikšanās lapas valoda:** izlemts, tulkot visās 15 valodās, lai valoda nemainās pēc
   Quick Start. Sk. 4. posmu.
4. **Teikums pieteikšanās lapā:** karuselis tiek noņemts, viens īss teksts paliek zem logo.
5. **Ielūdzēja vārds starplapā:** jāpārbauda pret `docs/api/trip-invitations.md` un
   privātuma prasībām. Ja nedrīkst, teksts ir "Tevi ielūdza ceļojumā".
6. **Starplapas valoda:** tā tagad ir angļu. Ieteikums: pēc pārlūka valodas, ar angļu kā rezervi.

## Darba posmi

### 1. Dizains

Vienots izskats Quick Start, pieteikšanās lapai un starplapai, ieskaitot pāreju starp
gaišo Quick Start un tumšo pieteikšanās lapu. Skices īpašniekam apstiprināšanai pirms koda.

### 2. Starplapa (var izlaist atsevišķi)

- `invite.php`: ceļojuma attēls un nosaukums, poga Instalēt pēc platformas, norāde
  pieskarties saitei vēlreiz un "Jau ir SPLYTO? Atvērt lietotni".
- Noņemt "Opening Splyto..." un "Trip invite links work when you are logged in".
- Noņemt automātiskos `splyto://` mēģinājumus iOS, jo bez lietotnes tie var parādīt pārlūka
  kļūdu. Lietotni atver Universal Link vai poga.
- Noskaidrot, vai `invite.html` vēl tiek lietots. Ja nē, izņemt, ja jā, atjaunināt arī to.
- Saskaņot `friend.php` un `friend.html`, kam ir tāda pati problēma.

### 3. Quick Start pirms pieteikšanās

- Reālie ekrāni `quick_start_phone_screens.dart` vietā, apstrādājot visu 6 slaidu izmēru.
- `QuickStartSheet` kļūst izmantojams divos režīmos: pirms pieteikšanās (pēdējā poga Sign up)
  un no profila (pēdējā poga kā tagad).
- Telefonā glabāta atzīme par redzētu pamācību ar esošo `shared_preferences`, nevis kontam
  piesaistīta. To uzliek jau atverot, lai aizvēršana pusceļā to neparādītu atkal.
- Sākuma maršruts `app_dependencies.dart` un `app_router.dart`: nav sesijas un nav atzīmes →
  Quick Start, citādi kā tagad.
- Bez reģistrācijas Quick Start nedrīkst saukt API. Pārbaudīt, ka tukšie un kļūdu stāvokļi
  nestrādā ar kontu.
- Ja pirmā atvēršana notika ar ielūguma saiti, Quick Start izlaiž. Ielūgumu glabā
  `InviteDeepLinkController`.

### 4. Pieteikšanās lapa

- `auth_intro_page.dart`: noņemt karuseli un `AuthIntroStage.intro`, sākt ar galveno lapu.
- Atjaunināt `test/features/auth/auth_intro_test.dart`.
- Izlogošanās ved uz šo pašu lapu.
- Pieteikšanās ekrāni tagad lieto `context.l10nEn` (62 vietas `auth_intro_page.dart` un
  `login_page_*.dart`). Pāriet uz `context.l10n`. Tulkojumi ARB jau ir visās 15 valodās
  (2026-11-06 pārbaudītas 36 atslēgas).
- Pirms maiņas noskaidrot, kāpēc tika izvēlēta angļu valoda, un pārbaudīt garākos tekstus
  uz maza ekrāna, kā arī kļūdu ziņojumus un validāciju.

### 5. Pēc reģistrācijas

Serveris paliek nemainīts, `claim_quick_start` turpina strādāt.

- Ja atzīme telefonā ir: `main_shell_page_quick_start.dart` izsauc claim klusi, tikai lai
  serverī atzīmētu, un neko nerāda.
- Ja atzīmes nav, piemēram, cilvēks atnāca caur ielūgumu un ceļojumam nepievienojās: paliek
  pašreizējais ceļš, kas pamācību parāda pēc reģistrācijas. Tādējādi tā nevienam nepazūd.

Tas atrisina arī pašreizējo pazibēšanu, kur jaunam profilam uz mirkli redzams tukšais
sākuma ekrāns.

### 6. Tulkojumi

Jauni teksti visās 15 valodās caur ARB un `flutter gen-l10n`, ieskaitot Sign up pogu un
īso teikumu pieteikšanās lapā. Ierakstīt `docs/mobile/localization-review/reviews.json`.

## Pārbaudes

- Testi: atjaunināt `test/features/quick_start/` un `test/features/auth/auth_intro_test.dart`.
  Pievienot pirmo atvēršanu, Izlaist, Sign up, izlogošanos, sesiju, ielūgumu un kluso claim.
- `flutter analyze --no-pub`, `flutter test --no-pub`, `php vendor/bin/phpunit`.
- Simulators: mazs un liels iPhone, tumšais un gaišais režīms, liels teksts.
- Reāls telefons (simulatorā nevar):
  - saite no WhatsApp, kad lietotnes nav, instalēšana un otrais pieskāriens;
  - saite, kad lietotne ir instalēta, gan pieteicies, gan izlogojies;
  - TestFlight atjauninājums no vecās versijas, gan pieteicies, gan izlogojies.

## Izlaišana

API nemainās, migrāciju nav.

1. Starplapu var izvietot uz servera neatkarīgi, ar `git pull --ff-only`.
2. Lietotnes izmaiņas nonāk TestFlight jaunā būvējumā.
3. Pēc iOS simulatora būvējuma atjaunot ierīces būvējumu pirms arhivēšanas.
4. Android: pārbaudīt to pašu, kad atgriežamies pie Android. Tad var pievienot arī Play
   Install Referrer, kas ielūgumu nodod automātiski.

## Vēlāk, ja vajadzēs

Ja dati rāda, ka daudzi instalē un nenonāk līdz ceļojumam, apsvērt kopēšanu starplapā vai
ārēju servisu. iOS tādi servisi nav pilnīgi precīzi, un to pašu Wi-Fi lietojoši draugi var
nonākt nepareizajā ceļojumā.
