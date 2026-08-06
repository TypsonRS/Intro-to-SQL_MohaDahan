-- At the Vet – Musterlösung passend zur Bootcamp-Datenbank
-- Tabellen: owners, pets, procedurehistory, proceduredetails

-- 1. Anzahl Haustiere und Besitzer
SELECT COUNT(*) AS number_of_pets FROM pets;
SELECT COUNT(*) AS number_of_owners FROM owners;

-- 2. Häufigster und seltenster Tiername
SELECT name AS pet_name, COUNT(*) AS name_count
FROM pets
GROUP BY name
ORDER BY name_count DESC, pet_name ASC
LIMIT 1;

SELECT name AS pet_name, COUNT(*) AS name_count
FROM pets
GROUP BY name
ORDER BY name_count ASC, pet_name ASC
LIMIT 1;

-- 3. Tierarten
SELECT DISTINCT kind AS pet_kind
FROM pets
ORDER BY pet_kind;

-- 4. Geschlechterverteilung insgesamt und je Tierart
SELECT gender, COUNT(*) AS number_of_pets
FROM pets
GROUP BY gender
ORDER BY number_of_pets DESC;

SELECT kind, gender, COUNT(*) AS number_of_pets
FROM pets
GROUP BY kind, gender
ORDER BY kind, gender;

-- 5. Durchschnittsalter
SELECT ROUND(AVG(age)::numeric, 2) AS average_pet_age
FROM pets;

-- 6. Besitzer mit mehr als einem Haustier
SELECT ownerid, COUNT(*) AS number_of_pets
FROM pets
GROUP BY ownerid
HAVING COUNT(*) > 1
ORDER BY number_of_pets DESC;

SELECT COUNT(*) AS owners_with_more_than_one_pet
FROM (
    SELECT ownerid
    FROM pets
    GROUP BY ownerid
    HAVING COUNT(*) > 1
) AS multiple_pet_owners;

-- 7. Haben Mehrtier-Besitzer dieselbe Tierart?
SELECT ownerid,
       ARRAY_AGG(name ORDER BY name) AS pet_names,
       ARRAY_AGG(kind ORDER BY kind) AS pet_kinds,
       ARRAY_AGG(DISTINCT kind) AS distinct_pet_kinds,
       COUNT(DISTINCT kind) AS number_of_different_kinds
FROM pets
GROUP BY ownerid
HAVING COUNT(*) > 1
ORDER BY ownerid;

-- 8. Gleicher Name bei Besitzer und Haustier?
SELECT o.ownerid,
       o.name AS owner_first_name,
       o.surname AS owner_last_name,
       p.petid,
       p.name AS pet_name
FROM owners AS o
INNER JOIN pets AS p
    ON o.ownerid = p.ownerid
WHERE LOWER(o.name) = LOWER(p.name)
ORDER BY owner_last_name, owner_first_name;

-- 9. Haustier- und Besitzerinformationen nebeneinander
SELECT p.petid,
       p.name AS pet_name,
       p.kind AS pet_kind,
       o.ownerid,
       o.name AS owner_first_name,
       o.surname AS owner_last_name,
       o.city
FROM pets AS p
FULL JOIN owners AS o
    ON p.ownerid = o.ownerid
ORDER BY o.ownerid, p.petid;

-- 10. Top 3 Städte mit den meisten Haustieren
SELECT o.city,
       COUNT(p.petid) AS number_of_pets
FROM owners AS o
INNER JOIN pets AS p
    ON o.ownerid = p.ownerid
GROUP BY o.city
ORDER BY number_of_pets DESC, o.city ASC
LIMIT 3;

-- 11. Behandlungshistorie mit Behandlungsdetails verbinden
SELECT ph.petid,
       ph.proceduredate,
       ph.proceduretype,
       ph.proceduresubcode,
       pd.description,
       pd.price
FROM procedurehistory AS ph
INNER JOIN proceduredetails AS pd
    ON ph.proceduretype = pd.proceduretype
   AND ph.proceduresubcode = pd.proceduresubcode
ORDER BY ph.petid, ph.proceduredate;

-- 12. Haustiere ohne Tollwutimpfung
-- Zuerst exakte Bezeichnung prüfen:
SELECT DISTINCT description
FROM proceduredetails
WHERE description ILIKE '%rabies%';

SELECT p.petid,
       p.name AS pet_name,
       ARRAY_AGG(pd.description)
           FILTER (WHERE pd.description IS NOT NULL) AS procedures
FROM pets AS p
LEFT JOIN procedurehistory AS ph
    ON p.petid = ph.petid
LEFT JOIN proceduredetails AS pd
    ON ph.proceduretype = pd.proceduretype
   AND ph.proceduresubcode = pd.proceduresubcode
GROUP BY p.petid, p.name
HAVING 'Rabies Vaccination' <> ALL(
    COALESCE(
        ARRAY_AGG(pd.description)
            FILTER (WHERE pd.description IS NOT NULL),
        ARRAY[]::text[]
    )
)
ORDER BY pet_name;

-- 13. Häufigste Operationsart
SELECT pd.description AS surgery_description,
       COUNT(*) AS number_of_procedures
FROM procedurehistory AS ph
INNER JOIN proceduredetails AS pd
    ON ph.proceduretype = pd.proceduretype
   AND ph.proceduresubcode = pd.proceduresubcode
WHERE pd.proceduretype ILIKE '%surgery%'
GROUP BY pd.description
ORDER BY number_of_procedures DESC, surgery_description ASC
LIMIT 1;

-- 14. Besitzer mit den höchsten Gesamtausgaben
SELECT o.ownerid,
       o.name AS owner_first_name,
       o.surname AS owner_last_name,
       ROUND(SUM(pd.price)::numeric, 2) AS total_spent
FROM owners AS o
INNER JOIN pets AS p
    ON o.ownerid = p.ownerid
INNER JOIN procedurehistory AS ph
    ON p.petid = ph.petid
INNER JOIN proceduredetails AS pd
    ON ph.proceduretype = pd.proceduretype
   AND ph.proceduresubcode = pd.proceduresubcode
GROUP BY o.ownerid, o.name, o.surname
ORDER BY total_spent DESC
LIMIT 1;

-- 15. Zusätzliche Frage: Welches Tier hatte die meisten Behandlungen?
SELECT p.petid,
       p.name AS pet_name,
       COUNT(*) AS number_of_procedures
FROM pets AS p
INNER JOIN procedurehistory AS ph
    ON p.petid = ph.petid
GROUP BY p.petid, p.name
ORDER BY number_of_procedures DESC
LIMIT 1;
