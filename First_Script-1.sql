#Sql_1

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'introduction';
-- 
SELECT *
FROM record r ;

select *
from gender g ;

SELECT *
FROM age_bucket ab  ;
-- 
SELECT *
FROM record
WHERE id = 2 ;



SELECT *
FROM record
WHERE id = 1 
  AND id_age_bucket  BETWEEN 20 AND 50;

SELECT * FROM record LIMIT 5;
SELECT * FROM age_bucket;

SELECT r.*, g.name AS gender
FROM record r
JOIN gender g
ON r.id_gender  = g.id
WHERE g.name = 'female';


SELECT r.*, g.name AS gender
FROM record r
JOIN gender g
ON r.id_gender = g.id
JOIN age_bucket a
ON r.id_age_bucket = a.id
WHERE g.name = 'female';

SELECT r.*, g.name AS gender
FROM record r
JOIN gender g
ON r.id_gender = g.id
JOIN age_bucket a
ON r.id_age_bucket = a.id
WHERE g.name = 'female'
 AND r.id_age_bucket BETWEEN 20 AND 50; 

SELECT r.*, g.name AS gender
FROM record r
JOIN gender g
ON r.id_gender = g.id
JOIN age_bucket a
ON r.id_age_bucket = a.id
WHERE g.name = 'male';

SELECT r.*, g.name AS gender,
FROM record r
JOIN gender g
ON r.id_gender  = g.id
JOIN age_bucket a
ON r.id_age_bucket  = a.id
WHERE g.name = 'male'
  AND r.id_age_bucket BETWEEN 20 AND 50;



SELECT
    r.record_date,
    g.name AS gender,
    a.range AS age_bucket,
    r.cases
FROM record r
JOIN gender g
    ON r.id_gender = g.id
JOIN age_bucket a
    ON r.id_age_bucket = a.id
WHERE g.name = 'female'
ORDER BY a.range ASC, r.record_date ASC;


SELECT
    AVG(r.cases) AS average_cases
FROM record r
JOIN gender g
    ON r.id_gender = g.id
WHERE g.name = 'female';

SELECT
    MAX(r.cases) AS maximum_cases
FROM record r
JOIN gender g
    ON r.id_gender = g.id
WHERE g.name = 'male';

SELECT
    g.name AS gender,
    a.range AS age_group,
    SUM(r.cases) AS total_cases
FROM record r
JOIN gender g
    ON r.id_gender = g.id
JOIN age_bucket a
    ON r.id_age_bucket = a.id
GROUP BY
    g.name,
    a.range ;

SELECT
    r.record_date,
    r.cases
FROM record r
WHERE r.cases > 8000 ;


