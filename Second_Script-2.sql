#Sql_2

SELECT COUNT(*) AS number_of_pets
FROM pets p ;

SELECT COUNT(*) AS number_of_owners
FROM owners o ;

select count(*) as most_common_pet_names 
from pets p 
group by p.name
 ;

SELECT
    p.name AS pet_name,
    COUNT(*) AS least_common_pet_names
FROM pets p
GROUP BY p.name
ORDER BY COUNT(*) asc ;

SELECT DISTINCT
    p.kind 
FROM pets p;

select 
    p.kind,
    p.gender,
    COUNT(*) AS number_of_pets
from  pets p
group  by 
    p.kind,
    p.gender ;

SELECT
    p.kind,
    AVG(p.age) AS average_age
FROM pets p
GROUP BY p.kind;

SELECT
    p.ownerid,
    COUNT(*) AS number_of_pets
FROM pets p
GROUP BY p.ownerid
HAVING COUNT(*) > 1;

SELECT
    p.ownerid,
    ARRAY_AGG(p.kind) AS pet_types
FROM pets p
GROUP BY p.ownerid
HAVING COUNT(*) > 1;

SELECT
    o.name AS owner_name,
    p.name AS pet_name
FROM owners o
INNER JOIN pets p
    ON o.name = p.name ;

SELECT
    p.name AS pet_name,
    o.name AS owner_name
FROM pets p
FULL JOIN owners o
    ON p.petid  = o.ownerid ;

SELECT
    o.city,
    COUNT(p.petid) AS number_of_pets
FROM owners o
INNER JOIN pets p
    ON o.ownerid = p.petid
GROUP BY o.city
ORDER BY number_of_pets DESC
LIMIT 3;

SELECT
    ph.proceduredate ,
    ph.proceduresubcode as codep2,
    ph.proceduretype as ty2,
    ph.petid ,
    pd.description ,
    pd.proceduretype as ty1,
    pd.price ,
    pd.proceduresubcode as codep1
FROM procedurehistory ph
INNER JOIN proceduredetails pd
    ON ph.proceduretype  = pd.proceduretype 
   AND ph.proceduresubcode  = pd.proceduresubcode ;


SELECT
    p.name AS name,
    ARRAY_AGG(pd.proceduretype) AS procedures
FROM pets p
LEFT JOIN procedurehistory ph
    ON p.petid = ph.petid
LEFT JOIN proceduredetails pd
    ON ph.proceduretype = pd.proceduretype
   AND ph.proceduresubcode = pd.proceduresubcode
GROUP BY p.name
HAVING 'rabies_vaccination' <> ALL(ARRAY_AGG(pd.proceduretype));

SELECT
    pd.description AS surgery_type,
    COUNT(*) AS number_of_surgeries
FROM procedurehistory ph
INNER JOIN proceduredetails pd
    ON ph.proceduretype = pd.proceduretype
   AND ph.proceduresubcode = pd.proceduresubcode 
WHERE pd.proceduretype = 'GENERAL SURGERIES'
GROUP BY pd.description
ORDER BY number_of_surgeries DESC
LIMIT 1;

SELECT
    o.name AS owner_name,
    SUM(pd.price) AS total_spent
FROM owners o
INNER JOIN pets p
    ON o.ownerid  = p.ownerid  
INNER JOIN procedurehistory ph
    ON p.petid  = ph.petid
INNER JOIN proceduredetails pd
    ON ph.proceduretype = pd.proceduretype
   AND ph.proceduresubcode = pd.proceduresubcode
GROUP BY o.name
ORDER BY total_spent DESC
LIMIT 5 ;

SELECT
    p.name
FROM pets p
LEFT JOIN procedurehistory ph
ON p.petid = ph.petid
WHERE ph.petid IS NULL;

