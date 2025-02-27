-- ZADÁNÍ: 
-- Připravte i tabulku s HDP, GINI koeficientem a populací dalších evropských států
-- ve stejném období, jako primární přehled pro ČR.

-- Nahled do tabulky
 
SELECT *
FROM economies;

-- Select nazvu zemi z countries

SELECT *
FROM countries
WHERE continent =  'Europe';

-- Pohled na relevantni sloupce a vsechny dostupne evropske zeme (jejich nazvy jsem 
-- zkopiroval do kodu nize).

CREATE OR REPLACE VIEW v_europe 
AS
SELECT 
    country AS zeme,
    year AS rok,
    GDP AS HDP,
    gini,
    population AS pocet_obyvatel 
FROM economies
WHERE country IN (
    'Albania', 'Andorra', 'Austria', 'Belarus', 'Belgium', 'Bosnia and Herzegovina', 
    'Bulgaria', 'Croatia', 'Czech Republic', 'Denmark', 'Estonia', 'Faroe Islands', 
    'Finland', 'France', 'Germany', 'Gibraltar', 'Greece', 'Holy See (Vatican City State)', 
    'Hungary', 'Iceland', 'Ireland', 'Italy', 'Latvia', 'Liechtenstein', 'Lithuania', 
    'Luxembourg', 'Malta', 'Moldova', 'Monaco', 'Montenegro', 'Netherlands', 
    'North Macedonia', 'Northern Ireland', 'Norway', 'Poland', 'Portugal', 'Romania', 
    'Russian Federation', 'San Marino', 'Serbia', 'Slovakia', 'Slovenia', 'Spain', 
    'Svalbard and Jan Mayen', 'Sweden', 'Switzerland', 'Ukraine', 'United Kingdom') 
AND gini IS NOT NULL 
AND GDP IS NOT NULL
AND population IS NOT NULL;

-- Omezeni na relevantni roky. 

SELECT *  
FROM v_europe
WHERE rok BETWEEN 2006 AND 2018;

-- Vytvoreni tabulky.

CREATE OR REPLACE TABLE t_jan_vlkovsky_project_SQL_secondary_final
AS
SELECT *
FROM v_europe;

SELECT *
FROM t_jan_vlkovsky_project_SQL_secondary_final;



