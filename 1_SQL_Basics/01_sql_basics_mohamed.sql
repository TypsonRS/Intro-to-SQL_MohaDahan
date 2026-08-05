SELECT *
FROM record
WHERE id_gender = 2;

SELECT
    r.record_date,
    r.cases,
    g.name
FROM record AS r
INNER JOIN gender AS g
    ON r.id_gender = g.id
WHERE g.name = 'female';

SELECT
    r.record_date,
    r.cases,
    g.name
FROM record AS r
INNER JOIN gender AS g
    ON r.id_gender = g.id
WHERE g.name = 'male';

SELECT *
FROM age_bucket;

SELECT
    r.record_date,
    r.cases,
    g.name,
    a.range
FROM record r
JOIN gender g
    ON r.id_gender = g.id
    
SELECT
    r.record_date,
    r.cases,
    g.name
FROM record AS r
INNER JOIN gender AS g
    ON r.id_gender = g.id
WHERE g.name = 'male'
ORDER BY r.cases DESC
LIMIT 10;
JOIN age_bucket a
    ON r.id_age_bucket = a.id
WHERE g.name = 'male'
AND r.id_age_bucket BETWEEN 4 AND 6;

SELECT *
FROM record
ORDER BY cases DESC
limit 10;

SELECT COUNT(*)
FROM record;

SELECT COUNT(*)
FROM record AS r
INNER JOIN gender AS g
    ON r.id_gender = g.id
WHERE g.name = 'male';


SELECT COUNT(*)
FROM record AS r
INNER JOIN gender AS g
    ON r.id_gender = g.id
WHERE g.name = 'female';

SELECT SUM(r.cases)
FROM record AS r;

