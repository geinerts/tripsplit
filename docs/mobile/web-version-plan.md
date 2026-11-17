# SPLYTO — Web versija

**Statuss:** Ideja nākotnei, nav ieplānota. Piezīmes 2026-11-17.
**Mērķis:** Ļaut ātri ievadīt un pārskatīt izdevumus no datora, galvenokārt biznesa tripiem.

---

## 1. Kāpēc

- Biznesa tripos daudzi strādā ar MacBook, un izdevumu ievade ar tastatūru ir ātrāka nekā telefonā.
- Splitwise web tiek lietots galvenokārt ātrai ievadei un pārskatam lielā ekrānā; tas ir tas pats lietojums.
- Serverī visas darbības jau ir API darbības, tāpēc web klients nav jāgaida uz servera pārbūvi.

Šobrīd web nav produkta mērķis (`AGENTS.md`, `mobile/docs/APP_ARCHITECTURE.md`); šis ir lēmums nākotnei, nevis izmaiņa.

## 2. Ko iekļaut (secībā)

1. **Pieteikšanās un tripu saraksts.**
2. **Izdevuma pievienošana un labošana** ar dalījumu (vienādi, summas, procenti, daļas, pozīcijas) un čeka augšupielādi no faila.
3. **Trip lapa** ar izdevumiem un bilanci (kurš kam parādā).
4. **Eksports (PDF/CSV).** Serverī jau ir.
5. **Quick split** ievade un saraksts, kad 1.–4. strādā.

## 3. Ko pirmajā reizē neiekļaut

Norēķini un maksājumu detaļas, tiešā atrašanās vieta, karte un profila iestatījumi. Tie ir sarežģītāki un jutīgāki, un telefonā drošāki.

## 4. Izkārtojums darbvirsmai

Trīs kolonnas, kā Splitwise: kreisajā tripu un draugu saraksts, vidū izvēlētā trip izdevumi ar pogu "Add expense", labajā bilance. Izdevuma forma ir uznirstošs logs ar tastatūras ātrumtaustiņiem (Tab starp laukiem, Enter saglabā).

## 5. Atvērti jautājumi

- **Flutter web vai atsevišķa vienkārša web lapa.** Flutter web atkārtoti izmantotu daudz koda (formas, dalījuma matemātika, tulkojumi), bet esošā UI ir veidota telefonam. Jānovērtē ar nelielu izmēģinājumu pirms izvēles.
- **Pieteikšanās un sesija pārlūkā.** Šobrīd žetoni ir paredzēti telefonam. Web vajag drošu sesijas glabāšanu (piemēram, `HttpOnly` sīkdatne), aizsardzību pret CSRF un CORS noteikumus. Tas ir API līguma jautājums, un bez īpašnieka atļaujas to nemaina.
- **Apple/Google pieteikšanās web.** Jāpārbauda, vai esošie pakalpojumu iestatījumi to atbalsta.
- **Čeku augšupielāde** no faila: tie paši ierobežojumi kā telefonā (JPG, PNG, WebP, līdz 8 MB).
- **Domēns un drošības galvenes.** Admin panelis jau ir atsevišķā hostā; web lietotājiem vajag atsevišķu un neatkarīgu hostu.
- **Uzturēšana.** Katra jauna funkcija būs jāveido divreiz; jāizlemj, vai web seko visam vai tikai iepriekšminētajam apjomam.

## 6. Kad

Sākt tikai pēc 1.1.0 un Quick split izlaišanas. Pirmais solis: īss tehniskais pētījums (Flutter web pret atsevišķu lapu, sesijas modelis) un API līguma projekts, ko apstiprina īpašnieks, pirms rakstīt kodu.
