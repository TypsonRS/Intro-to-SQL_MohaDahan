-- ============================================================
-- At the Vet – Musterlösung
-- PostgreSQL / DBeaver
-- ============================================================
-- Annahmen zu Tabellen und Spalten:
-- owners("OwnerID", "Name", "Surname", "City")
-- pets("PetID", "Name", "Kind", "Gender", "Age", "OwnerID")
-- procedurehistory("PetID", "Date", "ProcedureType", "ProcedureSubCode")
-- proceduredetails("ProcedureType", "ProcedureSubCode", "Description", "Price")
-- Falls deine Namen abweichen, passe sie entsprechend an.

-- 1. Wie viele Haustiere und Besitzer gibt es?
SELECT COUNT(*) AS number_of_pets
FROM pets;

SELECT COUNT(*) AS number_of_owners
FROM owners;

-- 2. Häufigste und seltenste Tiernamen
SELECT "Name" AS pet_name, COUNT(*) AS name_count
FROM pets
GROUP BY "Name"
ORDER BY name_count DESC, pet_name ASC;

SELECT "Name" AS most_common_pet_name, COUNT(*) AS name_count
FROM pets
GROUP BY "Name"
ORDER BY name_count DESC, "Name" ASC
LIMIT 1;

SELECT "Name" AS least_common_pet_name, COUNT(*) AS name_count
FROM pets
GROUP BY "Name"
ORDER BY name_count ASC, "Name" ASC
LIMIT 1;

-- 3. Welche Tierarten gibt es?
SELECT DISTINCT "Kind" AS pet_kind
FROM pets
ORDER BY pet_kind;

-- 4. Geschlechterverteilung insgesamt und je Tierart
SELECT "Gender" AS gender, COUNT(*) AS number_of_pets
FROM pets
GROUP BY "Gender"
ORDER BY number_of_pets DESC;

SELECT "Kind" AS pet_kind, "Gender" AS gender, COUNT(*) AS number_of_pets
FROM pets
GROUP BY "Kind", "Gender"
ORDER BY pet_kind, gender;

-- 5. Durchschnittsalter
SELECT ROUND(AVG("Age")::numeric, 2) AS average_pet_age
FROM pets;

-- 6. Wie viele Besitzer haben mehr als ein Tier?
SELECT COUNT(*) AS owners_with_more_than_one_pet
FROM (
    SELECT "OwnerID"
    FROM pets
    GROUP BY "OwnerID"
    HAVING COUNT(*) > 1
) AS multiple_pet_owners;

-- 7. Haben Mehrtier-Besitzer dieselbe Tierart?
SELECT
    p."OwnerID",
    ARRAY_AGG(p."Name" ORDER BY p."Name") AS pet_names,
    ARRAY_AGG(DISTINCT p."Kind") AS distinct_pet_kinds,
    COUNT(*) AS number_of_pets,
    COUNT(DISTINCT p."Kind") AS number_of_different_kinds
FROM pets AS p
GROUP BY p."OwnerID"
HAVING COUNT(*) > 1
ORDER BY number_of_pets DESC;

-- number_of_different_kinds = 1: gleiche Tierart
-- number_of_different_kinds > 1: verschiedene Tierarten

-- 8. Haben Besitzer und Tier denselben Vornamen?
SELECT
    o."OwnerID",
    o."Name" AS owner_first_name,
    o."Surname" AS owner_last_name,
    p."PetID",
    p."Name" AS pet_name
FROM owners AS o
INNER JOIN pets AS p
    ON o."OwnerID" = p."OwnerID"
WHERE LOWER(o."Name") = LOWER(p."Name")
ORDER BY owner_last_name, owner_first_name;

-- 9. Tier- und Besitzerinformationen nebeneinander
SELECT
    p."PetID",
    p."Name" AS pet_name,
    p."Kind" AS pet_kind,
    o."OwnerID",
    o."Name" AS owner_first_name,
    o."Surname" AS owner_last_name,
    o."City" AS owner_city
FROM pets AS p
FULL JOIN owners AS o
    ON p."OwnerID" = o."OwnerID"
ORDER BY o."OwnerID", p."PetID";

-- 10. Top 3 Städte nach Anzahl der Tiere
SELECT o."City" AS city, COUNT(p."PetID") AS number_of_pets
FROM owners AS o
INNER JOIN pets AS p
    ON o."OwnerID" = p."OwnerID"
GROUP BY o."City"
ORDER BY number_of_pets DESC, city ASC
LIMIT 3;

-- 11. Behandlungshistorie mit Behandlungsdetails kombinieren
SELECT
    ph."PetID",
    ph."Date" AS procedure_date,
    ph."ProcedureType",
    ph."ProcedureSubCode",
    pd."Description",
    pd."Price"
FROM procedurehistory AS ph
INNER JOIN proceduredetails AS pd
    ON ph."ProcedureType" = pd."ProcedureType"
   AND ph."ProcedureSubCode" = pd."ProcedureSubCode"
ORDER BY ph."PetID", ph."Date";

-- 12. Tiere ohne Tollwutimpfung
-- Zuerst genaue Schreibweise prüfen:
SELECT DISTINCT "Description"
FROM proceduredetails
WHERE "Description" ILIKE '%rabies%';

-- Musterlösung mit exaktem Text 'Rabies Vaccination':
SELECT
    p."PetID",
    p."Name" AS pet_name,
    ARRAY_AGG(pd."Description")
        FILTER (WHERE pd."Description" IS NOT NULL) AS procedures
FROM pets AS p
LEFT JOIN procedurehistory AS ph
    ON p."PetID" = ph."PetID"
LEFT JOIN proceduredetails AS pd
    ON ph."ProcedureType" = pd."ProcedureType"
   AND ph."ProcedureSubCode" = pd."ProcedureSubCode"
GROUP BY p."PetID", p."Name"
HAVING 'Rabies Vaccination' <> ALL(
    COALESCE(
        ARRAY_AGG(pd."Description")
            FILTER (WHERE pd."Description" IS NOT NULL),
        ARRAY[]::text[]
    )
)
ORDER BY pet_name;

-- 13. Häufigste Operationsart
SELECT pd."Description" AS surgery_description, COUNT(*) AS number_of_procedures
FROM procedurehistory AS ph
INNER JOIN proceduredetails AS pd
    ON ph."ProcedureType" = pd."ProcedureType"
   AND ph."ProcedureSubCode" = pd."ProcedureSubCode"
WHERE pd."ProcedureType" ILIKE '%surgery%'
GROUP BY pd."Description"
ORDER BY number_of_procedures DESC, surgery_description ASC
LIMIT 1;

-- 14. Besitzer mit den höchsten Gesamtausgaben
SELECT
    o."OwnerID",
    o."Name" AS owner_first_name,
    o."Surname" AS owner_last_name,
    ROUND(SUM(pd."Price")::numeric, 2) AS total_spent
FROM owners AS o
INNER JOIN pets AS p
    ON o."OwnerID" = p."OwnerID"
INNER JOIN procedurehistory AS ph
    ON p."PetID" = ph."PetID"
INNER JOIN proceduredetails AS pd
    ON ph."ProcedureType" = pd."ProcedureType"
   AND ph."ProcedureSubCode" = pd."ProcedureSubCode"
GROUP BY o."OwnerID", o."Name", o."Surname"
ORDER BY total_spent DESC
LIMIT 1;

-- 15. Zusätzliche Analysefragen
-- A) Welche Tierart hat im Durchschnitt die höchsten Behandlungskosten?
SELECT p."Kind" AS pet_kind, ROUND(AVG(pd."Price")::numeric, 2) AS average_procedure_cost
FROM pets AS p
INNER JOIN procedurehistory AS ph ON p."PetID" = ph."PetID"
INNER JOIN proceduredetails AS pd
    ON ph."ProcedureType" = pd."ProcedureType"
   AND ph."ProcedureSubCode" = pd."ProcedureSubCode"
GROUP BY p."Kind"
ORDER BY average_procedure_cost DESC;

-- B) Welches Tier hatte die meisten Behandlungen?
SELECT p."PetID", p."Name" AS pet_name, COUNT(*) AS number_of_procedures
FROM pets AS p
INNER JOIN procedurehistory AS ph ON p."PetID" = ph."PetID"
GROUP BY p."PetID", p."Name"
ORDER BY number_of_procedures DESC
LIMIT 1;
