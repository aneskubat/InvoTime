# INV-3: UML dijagram klasa – InvoTime

**Izvor:** ER dijagram baze podataka iz INV-2 (`docs/ER_InvoTime.jpg`)  
**Dijagram:** `docs/UML-KLASE_InvoTime.vpp` (Visual Paradigm projekat) i `docs/UML-KLASE_InvoTime.jpg` (izvoz)  
**Paket:** `ba.unze.ptf.invotime.model`

---

## 1. Pravila mapiranja ER → Java

* Svaka tabela iz ER modela postaje jedna klasa modela (naziv u jednini, `PascalCase`).
* Svaka kolona postaje privatni atribut; `snake_case` → `camelCase` (npr. `datum_zaposlenja` → `datumZaposlenja`).
* Strani ključevi se čuvaju kao ID atributi (npr. `Zaposlenik.odjelId`), a veza je na dijagramu prikazana asocijacijom sa kardinalnostima.
* Getteri, setteri i konstruktori nisu prikazani na dijagramu radi preglednosti.

| SQL tip | Java tip | Napomena |
|---|---|---|
| `int(10)` | `int` | `Integer` ako je kolona `NULL` |
| `bigint(19)` | `long` | `Long` ako je kolona `NULL` |
| `varchar`, `char`, `text` | `String` | |
| `decimal(p, s)` | `BigDecimal` | novac, količine i PDV stope – nikad `double` |
| `date` | `LocalDate` | |
| `datetime` | `LocalDateTime` | |
| `tinyint(1)` | `boolean` | |

## 2. Tabele i klase

| Tabela (ER) | Klasa | Grupa |
|---|---|---|
| `uloge` | `Uloga` | Korisnici i sigurnost |
| `korisnici` | `Korisnik` | Korisnici i sigurnost |
| `korisnicke_postavke` | `KorisnickePostavke` | Korisnici i sigurnost |
| `audit_log` | `AuditLog` | Korisnici i sigurnost |
| `backup_evidencija` | `BackupEvidencija` | Korisnici i sigurnost |
| `odjeli` | `Odjel` | Zaposlenici i NFC |
| `zaposlenici` | `Zaposlenik` | Zaposlenici i NFC |
| `nfc_kartice` | `NfcKartica` | Zaposlenici i NFC |
| `radne_smjene` | `RadnaSmjena` | Zaposlenici i NFC |
| `nfc_ocitanja` | `NfcOcitanje` | Zaposlenici i NFC |
| `korekcije_smjena` | `KorekcijaSmjene` | Zaposlenici i NFC |
| `podaci_firme` | `PodaciFirme` | Fakturisanje |
| `klijenti` | `Klijent` | Fakturisanje |
| `artikli` | `Artikal` | Fakturisanje |
| `fakture` | `Faktura` | Fakturisanje |
| `stavke_fakture` | `StavkaFakture` | Fakturisanje |
| `uplate` | `Uplata` | Fakturisanje |
| `obavijesti` | `Obavijest` | Fakturisanje / obavijesti |

## 3. Enumeracije

| Enum | Vrijednosti | Kolona | Izvor |
|---|---|---|---|
| `StatusFakture` | `NACRT`, `IZDATA`, `PLACENA`, `STORNIRANA` | `fakture.status` | INV-1, FR-06 |
| `NacinOcitanja` | `NFC`, `RUCNO` | `radne_smjene.nacin_dolaska/odlaska`, `nfc_ocitanja.nacin_ocitanja` | INV-1, FR-02 (ručni unos UID-a) |
| `Tema` | `LIGHT`, `DARK` | `korisnicke_postavke.tema` | INV-1, NFR-02 / UC2 |

Ostale tekstualne kolone sa fiksnim vrijednostima (`radne_smjene.status`, `nfc_ocitanja.rezultat`, `korekcije_smjena.tip_korekcije`, `artikli.tip`, `obavijesti.tip`, `backup_evidencija.tip_operacije/status`) ostaju `String` dok se njihove dozvoljene vrijednosti ne definišu u `schema.sql` (INV-6).

## 4. Ključne veze

* **Kompozicija `Faktura ◆— StavkaFakture` (1 : 0..\*)** – stavka ne postoji bez fakture; brisanjem fakture brišu se i njene stavke. Faktura drži listu `stavke` jer se iz nje računaju `osnovica`, `pdvIznos` i `ukupanIznos`.
* **Kompozicija `Korisnik ◆— KorisnickePostavke` (1 : 1)** – `korisnik_id` je istovremeno primarni i strani ključ postavki (identifikujuća veza u ER modelu).
* **`Zaposlenik — Korisnik` (1 : 1)** – svaki zaposlenik ima tačno jedan korisnički nalog (i Radnik se prijavljuje na sistem – UC1), a svaki nalog pripada jednom zaposleniku.
* **`NfcKartica — RadnaSmjena`** – dvije odvojene veze: kartica kojom je evidentiran dolazak i kartica kojom je evidentiran odlazak (obje mogu biti `NULL` kod ručnog unosa).
* **`RadnaSmjena — KorekcijaSmjene`** – svaka administratorska korekcija zaboravljene odjave čuva staro i novo vrijeme i razlog (FR-04).
* **Snimak podataka na fakturi** – `fakture` kopira podatke izdavaoca (`izdavalac_*`) i klijenta (`klijent_*`) u trenutku izdavanja, tako da kasnija izmjena podataka klijenta ili firme ne mijenja već izdate fakture.

## 5. Izmjena dijagrama

Dijagram se mijenja u Visual Paradigmu otvaranjem `docs/UML-KLASE_InvoTime.vpp`, nakon čega se slika ponovo izvozi u `docs/UML-KLASE_InvoTime.jpg` (Export → Active Diagram as Image).
