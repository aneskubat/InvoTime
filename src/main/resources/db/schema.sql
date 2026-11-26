

CREATE DATABASE IF NOT EXISTS invotime
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE invotime;

CREATE TABLE odjeli (
    odjel_id INT NOT NULL AUTO_INCREMENT,
    naziv VARCHAR(100) NOT NULL,
    opis VARCHAR(255) NULL,
    aktivan BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (odjel_id),
    UNIQUE KEY uq_odjeli_naziv (naziv)
) ENGINE=InnoDB;

CREATE TABLE uloge (
    uloga_id INT NOT NULL AUTO_INCREMENT,
    naziv VARCHAR(30) NOT NULL,
    opis VARCHAR(255) NULL,
    PRIMARY KEY (uloga_id),
    UNIQUE KEY uq_uloge_naziv (naziv)
) ENGINE=InnoDB;

CREATE TABLE zaposlenici (
    zaposlenik_id INT NOT NULL AUTO_INCREMENT,
    odjel_id INT NOT NULL,
    ime VARCHAR(80) NOT NULL,
    prezime VARCHAR(80) NOT NULL,
    email VARCHAR(150) NULL,
    telefon VARCHAR(35) NULL,
    datum_zaposlenja DATE NOT NULL,
    datum_prestanka DATE NULL,
    aktivan BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (zaposlenik_id),
    UNIQUE KEY uq_zaposlenici_email (email),
    KEY idx_zaposlenici_odjel (odjel_id),
    CONSTRAINT fk_zaposlenici_odjeli FOREIGN KEY (odjel_id)
        REFERENCES odjeli (odjel_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE korisnici (
    korisnik_id INT NOT NULL AUTO_INCREMENT,
    zaposlenik_id INT NOT NULL,
    uloga_id INT NOT NULL,
    korisnicko_ime VARCHAR(70) NOT NULL,
    lozinka_hash VARCHAR(100) NOT NULL,
    aktivan BOOLEAN NOT NULL DEFAULT TRUE,
    zadnja_prijava DATETIME NULL,
    PRIMARY KEY (korisnik_id),
    UNIQUE KEY uq_korisnici_zaposlenik (zaposlenik_id),
    UNIQUE KEY uq_korisnici_ime (korisnicko_ime),
    KEY idx_korisnici_uloga (uloga_id),
    CONSTRAINT fk_korisnici_zaposlenici FOREIGN KEY (zaposlenik_id)
        REFERENCES zaposlenici (zaposlenik_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_korisnici_uloge FOREIGN KEY (uloga_id)
        REFERENCES uloge (uloga_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE korisnicke_postavke (
    korisnik_id INT NOT NULL,
    tema VARCHAR(10) NOT NULL DEFAULT 'LIGHT',
    jezik VARCHAR(10) NOT NULL DEFAULT 'bs',
    PRIMARY KEY (korisnik_id),
    CONSTRAINT fk_postavke_korisnici FOREIGN KEY (korisnik_id)
        REFERENCES korisnici (korisnik_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_postavke_tema CHECK (tema IN ('LIGHT','DARK'))
) ENGINE=InnoDB;

CREATE TABLE nfc_kartice (
    kartica_id INT NOT NULL AUTO_INCREMENT,
    zaposlenik_id INT NOT NULL,
    uid VARCHAR(64) NOT NULL,
    datum_dodjele DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    datum_deaktivacije DATETIME NULL,
    aktivna BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (kartica_id),
    UNIQUE KEY uq_nfc_uid (uid),
    KEY idx_nfc_zaposlenik (zaposlenik_id),
    CONSTRAINT fk_nfc_zaposlenici FOREIGN KEY (zaposlenik_id)
        REFERENCES zaposlenici (zaposlenik_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE radne_smjene (
    smjena_id BIGINT NOT NULL AUTO_INCREMENT,
    zaposlenik_id INT NOT NULL,
    kartica_dolazak_id INT NULL,
    kartica_odlazak_id INT NULL,
    vrijeme_dolaska DATETIME NOT NULL,
    vrijeme_odlaska DATETIME NULL,
    nacin_dolaska VARCHAR(15) NOT NULL DEFAULT 'NFC',
    nacin_odlaska VARCHAR(15) NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'OTVORENA',
    PRIMARY KEY (smjena_id),
    KEY idx_smjene_zaposlenik_dolazak (zaposlenik_id, vrijeme_dolaska),
    KEY idx_smjene_status (status),
    KEY idx_smjene_kartica_dolazak (kartica_dolazak_id),
    KEY idx_smjene_kartica_odlazak (kartica_odlazak_id),
    CONSTRAINT fk_smjene_zaposlenici FOREIGN KEY (zaposlenik_id)
        REFERENCES zaposlenici (zaposlenik_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_smjene_kartica_dolazak FOREIGN KEY (kartica_dolazak_id)
        REFERENCES nfc_kartice (kartica_id) ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_smjene_kartica_odlazak FOREIGN KEY (kartica_odlazak_id)
        REFERENCES nfc_kartice (kartica_id) ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT chk_smjene_vrijeme CHECK (vrijeme_odlaska IS NULL OR vrijeme_odlaska >= vrijeme_dolaska),
    CONSTRAINT chk_smjene_status CHECK (status IN ('OTVORENA','ZATVORENA','KORIGOVANA')),
    CONSTRAINT chk_smjene_nacin_dolaska CHECK (nacin_dolaska IN ('NFC','RUCNO')),
    CONSTRAINT chk_smjene_nacin_odlaska CHECK (nacin_odlaska IS NULL OR nacin_odlaska IN ('NFC','RUCNO'))
) ENGINE=InnoDB;

CREATE TABLE nfc_ocitanja (
    ocitanje_id BIGINT NOT NULL AUTO_INCREMENT,
    kartica_id INT NULL,
    zaposlenik_id INT NULL,
    smjena_id BIGINT NULL,
    unosio_korisnik_id INT NULL,
    ocitani_uid VARCHAR(64) NOT NULL,
    datum_vrijeme DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    nacin_ocitanja VARCHAR(15) NOT NULL DEFAULT 'NFC',
    rezultat VARCHAR(20) NOT NULL,
    razlog_odbijanja VARCHAR(255) NULL,
    PRIMARY KEY (ocitanje_id),
    KEY idx_ocitanja_vrijeme (datum_vrijeme),
    KEY idx_ocitanja_uid (ocitani_uid),
    KEY idx_ocitanja_kartica (kartica_id),
    KEY idx_ocitanja_zaposlenik (zaposlenik_id),
    KEY idx_ocitanja_smjena (smjena_id),
    KEY idx_ocitanja_korisnik (unosio_korisnik_id),
    CONSTRAINT fk_ocitanja_kartica FOREIGN KEY (kartica_id)
        REFERENCES nfc_kartice (kartica_id) ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_ocitanja_zaposlenik FOREIGN KEY (zaposlenik_id)
        REFERENCES zaposlenici (zaposlenik_id) ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_ocitanja_smjena FOREIGN KEY (smjena_id)
        REFERENCES radne_smjene (smjena_id) ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_ocitanja_korisnik FOREIGN KEY (unosio_korisnik_id)
        REFERENCES korisnici (korisnik_id) ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT chk_ocitanja_nacin CHECK (nacin_ocitanja IN ('NFC','RUCNO')),
    CONSTRAINT chk_ocitanja_rezultat CHECK (rezultat IN ('CHECK_IN','CHECK_OUT','ODBIJENO'))
) ENGINE=InnoDB;

CREATE TABLE korekcije_smjena (
    korekcija_id BIGINT NOT NULL AUTO_INCREMENT,
    smjena_id BIGINT NOT NULL,
    admin_korisnik_id INT NOT NULL,
    tip_korekcije VARCHAR(15) NOT NULL,
    staro_vrijeme DATETIME NULL,
    novo_vrijeme DATETIME NOT NULL,
    razlog TEXT NOT NULL,
    datum_korekcije DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (korekcija_id),
    KEY idx_korekcije_smjena (smjena_id),
    KEY idx_korekcije_admin (admin_korisnik_id),
    CONSTRAINT fk_korekcije_smjena FOREIGN KEY (smjena_id)
        REFERENCES radne_smjene (smjena_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_korekcije_admin FOREIGN KEY (admin_korisnik_id)
        REFERENCES korisnici (korisnik_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_korekcije_tip CHECK (tip_korekcije IN ('DOLAZAK','ODLAZAK')),
    CONSTRAINT chk_korekcije_razlog CHECK (CHAR_LENGTH(TRIM(razlog)) > 0)
) ENGINE=InnoDB;

CREATE TABLE podaci_firme (
    firma_id INT NOT NULL AUTO_INCREMENT,
    naziv VARCHAR(200) NOT NULL,
    adresa VARCHAR(255) NOT NULL,
    grad VARCHAR(100) NOT NULL,
    postanski_broj VARCHAR(20) NULL,
    drzava VARCHAR(100) NOT NULL DEFAULT 'Bosna i Hercegovina',
    jib VARCHAR(13) NULL,
    pdv_broj VARCHAR(12) NULL,
    iban VARCHAR(40) NULL,
    naziv_banke VARCHAR(150) NULL,
    email VARCHAR(150) NULL,
    telefon VARCHAR(35) NULL,
    aktivna BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (firma_id),
    CONSTRAINT chk_firma_jib CHECK (jib IS NULL OR CHAR_LENGTH(jib) = 13),
    CONSTRAINT chk_firma_pdv CHECK (pdv_broj IS NULL OR CHAR_LENGTH(pdv_broj) = 12)
) ENGINE=InnoDB;

CREATE TABLE klijenti (
    klijent_id INT NOT NULL AUTO_INCREMENT,
    naziv VARCHAR(200) NOT NULL,
    adresa VARCHAR(255) NULL,
    grad VARCHAR(100) NULL,
    drzava VARCHAR(100) NOT NULL DEFAULT 'Bosna i Hercegovina',
    jib VARCHAR(13) NULL,
    pdv_broj VARCHAR(12) NULL,
    email VARCHAR(150) NULL,
    telefon VARCHAR(35) NULL,
    aktivan BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (klijent_id),
    KEY idx_klijenti_naziv (naziv),
    CONSTRAINT chk_klijenti_jib CHECK (jib IS NULL OR CHAR_LENGTH(jib) = 13),
    CONSTRAINT chk_klijenti_pdv CHECK (pdv_broj IS NULL OR CHAR_LENGTH(pdv_broj) = 12)
) ENGINE=InnoDB;

CREATE TABLE artikli (
    artikal_id INT NOT NULL AUTO_INCREMENT,
    sifra VARCHAR(50) NOT NULL,
    naziv VARCHAR(200) NOT NULL,
    opis TEXT NULL,
    tip VARCHAR(10) NOT NULL,
    jedinica_mjere VARCHAR(30) NOT NULL DEFAULT 'kom',
    cijena_bez_pdv DECIMAL(14,2) NOT NULL,
    pdv_stopa DECIMAL(5,2) NOT NULL DEFAULT 17.00,
    aktivan BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (artikal_id),
    UNIQUE KEY uq_artikli_sifra (sifra),
    KEY idx_artikli_naziv (naziv),
    CONSTRAINT chk_artikli_tip CHECK (tip IN ('PROIZVOD','USLUGA')),
    CONSTRAINT chk_artikli_cijena CHECK (cijena_bez_pdv >= 0),
    CONSTRAINT chk_artikli_pdv CHECK (pdv_stopa >= 0 AND pdv_stopa <= 100)
) ENGINE=InnoDB;

CREATE TABLE fakture (
    faktura_id BIGINT NOT NULL AUTO_INCREMENT,
    broj_fakture VARCHAR(9) NOT NULL,
    firma_id INT NOT NULL,
    klijent_id INT NOT NULL,
    odjel_id INT NOT NULL,
    kreirao_korisnik_id INT NOT NULL,
    datum_izdavanja DATE NOT NULL,
    datum_dospijeca DATE NOT NULL,
    valuta CHAR(3) NOT NULL DEFAULT 'BAM',
    status VARCHAR(15) NOT NULL DEFAULT 'NACRT',
    izdavalac_naziv VARCHAR(200) NOT NULL,
    izdavalac_adresa VARCHAR(255) NOT NULL,
    izdavalac_jib VARCHAR(13) NULL,
    izdavalac_pdv_broj VARCHAR(12) NULL,
    izdavalac_iban VARCHAR(40) NULL,
    klijent_naziv VARCHAR(200) NOT NULL,
    klijent_adresa VARCHAR(255) NULL,
    klijent_drzava VARCHAR(100) NULL,
    klijent_jib VARCHAR(13) NULL,
    klijent_pdv_broj VARCHAR(12) NULL,
    osnovica DECIMAL(14,2) NOT NULL DEFAULT 0,
    pdv_iznos DECIMAL(14,2) NOT NULL DEFAULT 0,
    ukupan_iznos DECIMAL(14,2) NOT NULL DEFAULT 0,
    napomena TEXT NULL,
    PRIMARY KEY (faktura_id),
    UNIQUE KEY uq_fakture_broj (broj_fakture),
    KEY idx_fakture_firma (firma_id),
    KEY idx_fakture_klijent (klijent_id),
    KEY idx_fakture_odjel (odjel_id),
    KEY idx_fakture_korisnik (kreirao_korisnik_id),
    KEY idx_fakture_dospijece (status, datum_dospijeca),
    KEY idx_fakture_izdavanje (datum_izdavanja),
    CONSTRAINT fk_fakture_firma FOREIGN KEY (firma_id)
        REFERENCES podaci_firme (firma_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_fakture_klijent FOREIGN KEY (klijent_id)
        REFERENCES klijenti (klijent_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_fakture_odjel FOREIGN KEY (odjel_id)
        REFERENCES odjeli (odjel_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_fakture_korisnik FOREIGN KEY (kreirao_korisnik_id)
        REFERENCES korisnici (korisnik_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_fakture_status CHECK (status IN ('NACRT','IZDATA','PLACENA','STORNIRANA')),
    CONSTRAINT chk_fakture_iznosi CHECK (osnovica >= 0 AND pdv_iznos >= 0 AND ukupan_iznos >= 0),
    CONSTRAINT chk_fakture_rok CHECK (datum_dospijeca >= datum_izdavanja)
) ENGINE=InnoDB;

CREATE TABLE stavke_fakture (
    stavka_id BIGINT NOT NULL AUTO_INCREMENT,
    faktura_id BIGINT NOT NULL,
    artikal_id INT NULL,
    redni_broj INT NOT NULL,
    sifra_artikla VARCHAR(50) NULL,
    naziv_artikla VARCHAR(200) NOT NULL,
    opis VARCHAR(255) NULL,
    jedinica_mjere VARCHAR(30) NOT NULL,
    kolicina DECIMAL(14,3) NOT NULL,
    jedinicna_cijena DECIMAL(14,2) NOT NULL,
    pdv_stopa DECIMAL(5,2) NOT NULL DEFAULT 17.00,
    osnovica DECIMAL(14,2) NOT NULL,
    pdv_iznos DECIMAL(14,2) NOT NULL,
    ukupno DECIMAL(14,2) NOT NULL,
    PRIMARY KEY (stavka_id),
    UNIQUE KEY uq_stavke_redni_broj (faktura_id, redni_broj),
    KEY idx_stavke_artikal (artikal_id),
    CONSTRAINT fk_stavke_faktura FOREIGN KEY (faktura_id)
        REFERENCES fakture (faktura_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_stavke_artikal FOREIGN KEY (artikal_id)
        REFERENCES artikli (artikal_id) ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT chk_stavke_iznosi CHECK (
        kolicina > 0 AND jedinicna_cijena >= 0 AND osnovica >= 0
        AND pdv_stopa >= 0 AND pdv_stopa <= 100 AND pdv_iznos >= 0 AND ukupno >= 0
    )
) ENGINE=InnoDB;

CREATE TABLE uplate (
    uplata_id BIGINT NOT NULL AUTO_INCREMENT,
    faktura_id BIGINT NOT NULL,
    evidentirao_korisnik_id INT NOT NULL,
    datum_uplate DATE NOT NULL,
    iznos DECIMAL(14,2) NOT NULL,
    nacin_placanja VARCHAR(30) NOT NULL,
    referenca VARCHAR(120) NULL,
    napomena VARCHAR(255) NULL,
    PRIMARY KEY (uplata_id),
    KEY idx_uplate_faktura (faktura_id),
    KEY idx_uplate_korisnik (evidentirao_korisnik_id),
    KEY idx_uplate_datum (datum_uplate),
    CONSTRAINT fk_uplate_faktura FOREIGN KEY (faktura_id)
        REFERENCES fakture (faktura_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_uplate_korisnik FOREIGN KEY (evidentirao_korisnik_id)
        REFERENCES korisnici (korisnik_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_uplate_iznos CHECK (iznos > 0)
) ENGINE=InnoDB;

CREATE TABLE obavijesti (
    obavijest_id BIGINT NOT NULL AUTO_INCREMENT,
    korisnik_id INT NOT NULL,
    faktura_id BIGINT NULL,
    smjena_id BIGINT NULL,
    tip VARCHAR(30) NOT NULL,
    naslov VARCHAR(160) NOT NULL,
    poruka TEXT NOT NULL,
    procitana BOOLEAN NOT NULL DEFAULT FALSE,
    datum_kreiranja DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (obavijest_id),
    KEY idx_obavijesti_korisnik (korisnik_id, procitana),
    KEY idx_obavijesti_faktura (faktura_id),
    KEY idx_obavijesti_smjena (smjena_id),
    CONSTRAINT fk_obavijesti_korisnik FOREIGN KEY (korisnik_id)
        REFERENCES korisnici (korisnik_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_obavijesti_faktura FOREIGN KEY (faktura_id)
        REFERENCES fakture (faktura_id) ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_obavijesti_smjena FOREIGN KEY (smjena_id)
        REFERENCES radne_smjene (smjena_id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE backup_evidencija (
    backup_id BIGINT NOT NULL AUTO_INCREMENT,
    korisnik_id INT NOT NULL,
    tip_operacije VARCHAR(10) NOT NULL,
    naziv_datoteke VARCHAR(255) NOT NULL,
    status VARCHAR(15) NOT NULL,
    datum_operacije DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    detalji TEXT NULL,
    PRIMARY KEY (backup_id),
    KEY idx_backup_korisnik (korisnik_id),
    CONSTRAINT fk_backup_korisnik FOREIGN KEY (korisnik_id)
        REFERENCES korisnici (korisnik_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_backup_tip CHECK (tip_operacije IN ('BACKUP','RESTORE')),
    CONSTRAINT chk_backup_status CHECK (status IN ('USPJESNO','NEUSPJESNO'))
) ENGINE=InnoDB;

CREATE TABLE audit_log (
    log_id BIGINT NOT NULL AUTO_INCREMENT,
    korisnik_id INT NULL,
    akcija VARCHAR(100) NOT NULL,
    naziv_tabele VARCHAR(100) NULL,
    zapis_id BIGINT NULL,
    datum_akcije DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    detalji TEXT NULL,
    PRIMARY KEY (log_id),
    KEY idx_audit_korisnik (korisnik_id),
    KEY idx_audit_datum (datum_akcije),
    CONSTRAINT fk_audit_korisnik FOREIGN KEY (korisnik_id)
        REFERENCES korisnici (korisnik_id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;


