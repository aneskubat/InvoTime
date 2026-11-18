# INV-1: Specifikacija zahtjeva i korisničkih uloga – InvoTime

**Klijent:** M. S. COMPANY d.o.o. Zenica (odjeli: *Metalne konstrukcije* i *Fitness*)  
**Sistem:** Desktop ERP aplikacija i sistem za NFC evidenciju radnog vremena

---

## 1. Korisničke uloge (Akteri)

* **Radnik (Primarni akter):** Zaposlenik u jednom od odjela firme. Koristi aplikaciju za prijavu dolaska (`Check-in`) i odlaska (`Check-out`) putem NFC kartice te ima uvid isključivo u vlastitu evidenciju radnih sati.
* **Računovođa (Primarni akter):** Zaposlenik zadužen za finansije i komercijalu. Upravlja klijentima i artiklima/uslugama, kreira i izdaje fakture, mijenja statuse naplate, izvozi fakture u PDF, prati preglede prihoda i generiše mjesečne PDF izvještaje radnih sati.
* **Administrator / Admin (Primarni akter):** Voditelj sistema sa najvišim nivoom ovlasti. Posjeduje sve ovlasti Računovođe, a dodatno upravlja zaposlenicima, dodjeljuje im NFC kartice, vrši korekcije zaboravljenih NFC odjava i upravlja sigurnosnim Backup/Restore operacijama baze podataka.
* **USB NFC čitač (Sekundarni akter / eksterni sistem):** Hardverski uređaj povezan putem `javax.smartcardio` API-ja koji šalje jedinstveni UID beskontaktne kartice sistemu.

---

## 2. Funkcionalni zahtjevi

* **FR-01 Autentifikacija i autorizacija (RBAC):** Prijava korisnika uz provjeru hashirane lozinke (`jBCrypt`) i strogo razdvajanje prava pristupa po ulogama (*Admin*, *Računovođa*, *Radnik*).
* **FR-02 NFC evidencija radnog vremena:** Očitavanje UID-a NFC kartice pri dolasku i odlasku radnika, automatsko računanje trajanja smjene, zaštita od duplih prijava/neispravnih odjava te podrška za ručni unos UID-a ukoliko čitač nije priključen.
* **FR-03 Upravljanje zaposlenicima:** Dodavanje, izmjena, pregled i deaktivacija zaposlenika po odjelima (*Metalne konstrukcije*, *Fitness*) uz dodjelu jedinstvenog NFC UID-a.
* **FR-04 Korekcija radnog vremena:** Administrativni pregled prisutnosti radnika i naknadni unos zaboravljene odjave uz obavezan komentar.
* **FR-05 Upravljanje klijentima i artiklima/uslugama:** Evidencija domaćih i stranih klijenata (uz validaciju 13-cifrenog JIB-a i 12-cifrenog PDV broja) te kataloga proizvoda i usluga.
* **FR-06 Fakturisanje i PDV obračun:** Automatska numeracija faktura (`GGGG-BBBB`), obračun osnovice, 17% PDV-a i ukupnog iznosa, te upravljanje statusima (`NACRT`, `IZDATA`, `PLACENA`, `STORNIRANA`).
* **FR-07 Generisanje PDF dokumenata:** Izvoz faktura sa zaglavljem firme i mjesečnih izvještaja radnih sati po zaposleniku u PDF format putem *Apache PDFBox* biblioteke.
* **FR-08 Analitika, pretraga i notifikacije:** Dashboard grafikoni mjesečnih prihoda i sati po odjelima, brza pretraga/filtriranje tabela i in-app obavijesti o dospjelim fakturama i nezatvorenim smjenama.
* **FR-09 Sigurnosna kopija (Backup/Restore):** Kreiranje i vraćanje `.sql` sigurnosne kopije MySQL baze podataka iz aplikacije.

---

## 3. Nefunkcionalni zahtjevi

* **NFR-01 Sigurnost:** Lozinke se u bazi čuvaju isključivo u hashiranom obliku (`jBCrypt`), a svi SQL upiti koriste `PreparedStatement` radi zaštite od SQL Injection napada.
* **NFR-02 Korisnički interfejs:** Desktop aplikacija izrađena u *JavaFX*-u sa podrškom za *Light* i *Dark* temu.
* **NFR-03 Pouzdanost i arhitektura:** Slojevita arhitektura (`View`, `Controller`, `Service`, `DAO`, `Model`) uz automatizovano testiranje poslovne logike putem *JUnit 5* i *GitHub Actions* CI/CD provjere.