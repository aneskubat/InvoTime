# InvoTime

Desktop aplikacija za evidenciju radnog vremena, upravljanje klijentima i generisanje faktura, razvijena za potrebe kompanije **M. S. COMPANY d.o.o. Zenica** u okviru nastave na Politehničkom fakultetu Univerziteta u Zenici (PTF).

---

## Tehnologije i biblioteke

- **Jezik i platforma:** Java (JDK 25)
- **Korisnički interfejs:** JavaFX 25 (FXML + CSS)
- **Build i upravljanje zavisnostima:** Apache Maven
- **Baza podataka:** MySQL (`mysql-connector-j` 9.2.0)
- **Generisanje PDF dokumenata:** Apache PDFBox 3.0.4
- **Sigurnost (hashiranje lozinki):** jBCrypt 0.4
- **Testiranje:** JUnit 5 (Jupiter 5.11.4)

---

## Arhitektura projekta

Projekat prati slojevitu **MVC** arhitekturu unutar paketa `ba.unze.ptf.invotime`:

```text
src/
├── main/
│   ├── java/ba/unze/ptf/invotime/
│   │   ├── controller/   # JavaFX kontroleri za FXML ekrane
│   │   ├── service/      # Poslovna logika i validacija
│   │   ├── dao/          # Pristup MySQL bazi podataka (CRUD operacije)
│   │   ├── model/        # Entiteti i modeli podataka
│   │   ├── util/         # Pomoćne klase (konekcija na bazu, PDF export, hash)
│   │   └── Main.java     # Ulazna tačka aplikacije
│   └── resources/
│       ├── view/         # FXML datoteke
│       ├── css/          # Stilovi korisničkog interfejsa
│       └── images/       # Ikonice i logotipi
└── test/
    └── java/ba/unze/ptf/invotime/
        └── AppSanityTest.java