/*
 United States Department of Agriculture's (USDA) Data Exploration
 
Skills uses: Joins, Subqueries, Aggregate Functions
computing environment/ecosystem: SQLite on SQLite Studio
*/

-- Total milk production for 2023

SELECT Sum(Value) FROM milk_production
WHERE Year=2023; 
/* result 8,755,564 (total production over all years, without the WHERE clause) can not be right, 
especially since the value of the first entity is already greater (428,000,000) 
*/
-- removing the commas from the value column and run query again
UPDATE milk_production SET value=REPLACE(value,",", "");
SELECT Sum(Value) FROM milk_production;
-- after ruining query again the number is 91,812,000,000 which seems likely, given that most of the numbers reported seemed to be rounded to the million 

--remove commas for all the tables
UPDATE cheese_production SET value=REPLACE(value,",", "");
UPDATE coffee_production SET value=REPLACE(value,",", "");
UPDATE egg_production SET value=REPLACE(value,",", "");
UPDATE honey_production  SET value=REPLACE(value,",", "");
UPDATE yogurt_production  SET value=REPLACE(value,",", "");

--average honey production
SELECT AVG(Value) FROM honey_production
WHERE Year = 2022;

-- What ANSI number does Iowa have (see state lookup)
SELECT * FROM state_lookup
WHERE UPPER(State) = "IOWA" ; 

-- Highest yoghurt production value for year 2022
SELECT MAX(Value) FROM yogurt_production 
WHERE Year = 2022;

-- States that produced honey and milk 
SELECT *    
FROM state_lookup AS s
INNER JOIN honey_production AS h  ON s.State_ANSI = h.State_ANSI
INNER JOIN milk_production AS m ON s.State_ANSI= m.State_ANSI
WHERE h.Year = 2022 AND m.YEAR = 2022 
;

-- Total honey production for states that also produced milk for the year 2022
SELECT SUM(Value)  
FROM yogurt_production
WHERE YEAR= 2022 AND State_ANSI IN (SELECT State_ANSI FROM cheese_production WHERE Year = 2022) 
;

-- States with cheese production greater that 100M in April 2023
SELECT SUM(Value) AS Apr23_prod, State_ANSI
FROM cheese_production
WHERE YEAR = 2023 AND UPPER(Period)= 'APR' 
GROUP BY State_ANSI
HAVING SUM(Value) > 100000000 
; 
/* One of the entires for the query above has no/NULL value for the State_ANSI
As seen in query below it is only one entity (row), but as the production is over 100M just in April 2023 we can assume it is the reported number of another state
*/ 
SELECT * 
FROM cheese_production
WHERE YEAR = 2023 AND UPPER(Period)= 'APR' AND State_ANSI = '' 
; 

-- Total value of coffee production over time
SELECT SUM(Value), Year 
FROM coffee_production
GROUP BY Year
;

-- Total coffee production in year 2011
SELECT SUM(Value), Year 
FROM coffee_production
WHERE Year = 2011
GROUP BY Year
;

-- Average honey production for 2022
SELECT AVG(Value) AS AVG_production 
FROM honey_production
WHERE Year = 2022
;


-- Cheese production value for New Jersey in April 2023
-- using a subquery
SELECT * 
FROM cheese_production
WHERE Year = 2023 AND UPPER(Period) = 'APR' 
AND State_ANSI IN (SELECT State_ANSI FROM state_lookup WHERE UPPER(State) = "NEW JERSEY")
;

-- using a join
SELECT s.State, s.State_ANSI,  c.Value , c.Year, c.Period, c.State_ANSI
FROM cheese_production c
LEFT JOIN state_lookup s
ON c.State_ANSI=  s.State_ANSI 
WHERE c.YEAR = 2023 AND UPPER(c.Period) = "APR" AND UPPER(s.State) LIKE 'NEW J%' 
;


-- Total yogurt production in 2022 for states that also have cheese production in 2023
-- using subquery 
SELECT SUM(Value) 
FROM yogurt_production
WHERE  State_ANSI IN (SELECT State_ANSI FROM cheese_production WHERE Year = 2023) AND Year = 2022 
;
-- using JOIN
SELECT SUM(y.Value)    
FROM yogurt_production y
INNER JOIN cheese_production c
ON y.State_ANSI = c.State_ANSI AND c.Year =2023 AND y.Year =2022 

;


-- States that didn't produce milk in 2023
-- using Subquery
SELECT COUNT(*)
FROM state_lookup
WHERE State_ANSI NOT IN (SELECT State_ANSI FROM milk_production WHERE Year =2023)  
;
--checking if Delaware NOT produced milk in 2023 
SELECT *
FROM state_lookup
WHERE State_ANSI NOT IN (SELECT State_ANSI FROM milk_production WHERE Year =2023) AND State LIKE 'D%' 
;

-- using Left Join
SELECT s.State
FROM state_lookup s
LEFT JOIN milk_production m
ON s.State_ANSI = m.State_ANSI AND m.Year = 2023 -- AND UPPER(c.Period) = 'APR'  in case you want to filter by month/period as well
WHERE m.State_ANSI IS NULL -- AND s.State LIKE 'D%' -- in case you need specifically check for Delaware
;
/*WHERE c.Year = 2023 AND UPPER(c.PERIOD) = 'APR' 
would filter after the JOIN, so result would only show states that produced cheese and not NULL values
*/



--Average coffee production for year where honey production exceeded 1M
SELECT AVG(c.Value)  
FROM coffee_production c
WHERE c.Year IN (SELECT h.Year FROM honey_production h WHERE h.Value > 1000000)
;
