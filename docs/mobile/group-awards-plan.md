# Grupas apbalvojumi

Statuss: plāns, īpašnieks apstiprinājis virzienu 2026-11-07. Kods vēl nav mainīts. Ieviest kā
papildinājumu vēlāk, kad lietotne jau darbojas ar īstiem lietotājiem.

## Mērķis

Padarīt ceļojumu jautrāku un dot iemeslu dalīties, nepārslogojot lietotni ar ikonām.

## Apbalvojumi

| Apbalvojums | Kā aprēķina |
| --- | --- |
| Dārgākais pirkums | Lielākais atsevišķais izdevums |
| Grupas grāmatvedis | Visvairāk izdevumu līdz šim brīdim |
| Pirmais pie darba | Ceļojuma pirmais izdevums |
| Sīkumu meistars | Mazākais atsevišķais izdevums |
| Pēdējais vārds | Ceļojuma pēdējais izdevums |
| Sestais, tikai ceļojumos ar cilvēku bez lietotnes | Cilvēks bez lietotnes ar visvairāk izdevumiem |

Sestā nosaukums vēl jāizdomā. Ceļojumā bez šāda cilvēka ir tikai pieci.

Nosaukumi ir darba varianti. Tiem jāpaliek draudzīgiem, nevis pārmetošiem.

## Noteikumi

- **Valūta:** salīdzina ceļojuma valūtā. Katrs izdevums jau tiek konvertēts un glabāts
  ceļojuma valūtā (`trip_expenses.amount`), tāpēc 1000 EUR ir vairāk nekā 10 000 VND, un
  atsevišķs dolāra pārrēķins nav vajadzīgs.
- **Neizšķirts:** uzvar tas, kurš rezultātu sasniedza pirmais. Kārtība ir pēc izdevuma
  izveidošanas laika un `id`, nevis pēc izdevuma datuma, ko var ierakstīt atpakaļejoši.
- **Kam pieder izdevums:** tam, kurš samaksāja (`paid_by`). Serveris neglabā, kurš izdevumu
  ievadīja. Tāpēc izdevums, ko izveidotājs ievada par cilvēku bez lietotnes, skaitās šim
  cilvēkam.
- **Vairāki apbalvojumi:** viens cilvēks var saņemt vairākus.
- **Kad rāda:** tikai grupas ceļojumā, kad ir vismaz 2 cilvēki un 5 izdevumi. Solo ceļojumā
  nerāda.
- **Mainīgums:** ceļojuma laikā apbalvojumi var mainīties. Pēc pabeigšanas tie vairs nemainās,
  jo izdevumi ir slēgti.
- **Paziņojumi:** nekādu par katru jaunu līderi. Var pievienot vienu pašās beigās.

## Kā rāda

Ikonas uz cilvēku bildēm neliekam.

1. **Ceļojuma laikā:** viena kompakta rinda pārskatā, kas rāda vienu apbalvojumu un cik vēl ir.
   Nospiežot atveras saraksts.
2. **Ceļojuma beigās:** pilns saraksts, no kura var dalīties ar grupu.
3. **Dalībnieka profilā:** viņa apbalvojumi kā teksts.

## Īstenošana

1. **Aprēķins serverī:** viena funkcija pēc esošajiem izdevumiem, lai rezultāts nav atkarīgs no
   tā, cik izdevumu lietotne ir ielādējusi. Migrācija nav vajadzīga, jo `created_at`, `amount`
   un `paid_by` jau ir.
2. **API:** jauns lauks `awards` ceļojuma datos. Vispirms apraksts `docs/api/`, un tas prasa
   īpašnieka apstiprinājumu pirms koda.
3. **Lietotne:** pārskata rinda, saraksta logs, profila teksts, kešs bez interneta.
4. **Tulkojumi:** nosaukumi un apraksti visās atbalstītajās valodās caur ARB.
5. **Testi:** neizšķirts, dažādas valūtas, slieksnis, solo ceļojums, cilvēks bez lietotnes,
   dzēsts izdevums maina rezultātu.

## Vēlāk

Apbalvojumus var iekļaut ceļojuma stāstā (Trip Wrapped), ko var dalīt ārpus lietotnes.
