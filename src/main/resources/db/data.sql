
USE invotime;

-- INV-6: Pocetni podaci za InvoTime


INSERT INTO uloge (naziv)
SELECT 'ADMIN'
WHERE NOT EXISTS (
    SELECT 1 FROM uloge WHERE naziv = 'ADMIN'
);

INSERT INTO uloge (naziv)
SELECT 'RACUNOVODJA'
WHERE NOT EXISTS (
    SELECT 1 FROM uloge WHERE naziv = 'RACUNOVODJA'
);

INSERT INTO uloge (naziv)
SELECT 'RADNIK'
WHERE NOT EXISTS (
    SELECT 1 FROM uloge WHERE naziv = 'RADNIK'
);


INSERT INTO odjeli (naziv, aktivan)
SELECT 'Metalne konstrukcije', 1
WHERE NOT EXISTS (
    SELECT 1 FROM odjeli
    WHERE naziv = 'Metalne konstrukcije'
);

INSERT INTO odjeli (naziv, aktivan)
SELECT 'Fitness', 1
WHERE NOT EXISTS (
    SELECT 1 FROM odjeli
    WHERE naziv = 'Fitness'
);


SELECT * FROM uloge;
SELECT * FROM odjeli;
