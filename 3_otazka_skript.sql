-- Otázka č. 3:
-- Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?


SELECT *
FROM czechia_price AS cp
LIMIT 20;

SELECT *
FROM czechia_price_category AS cpc;

-- Spojim si tabulky pres code.

CREATE OR REPLACE VIEW v_3otazka_full 
AS
SELECT 
czechia_price.*,
czechia_price_category.name AS category_name
FROM czechia_price 
LEFT JOIN czechia_price_category ON czechia_price.category_code = czechia_price_category.code; 

SELECT *
FROM v_3otazka_full;

-- Vyberu jen relevantni sloupce.

SELECT 
	value AS cena,
	category_name AS potravina,
	date_from AS od,
	date_to AS do
FROM v_3otazka_full;

-- Seskupim podle let a podle prumerne ceny za potravinu v danem roce.

CREATE OR REPLACE VIEW v_3otazka_prum_cena
AS
SELECT 
    YEAR(date_from) AS rok,
    category_name AS potravina,
    ROUND(AVG(value), 2) AS prumerna_cena
FROM v_3otazka_full
GROUP BY YEAR(date_from), potravina
ORDER BY potravina, rok;

SELECT *
FROM v_3otazka_prum_cena;

-- Krajni roky jsou 2006 a 2018. 
-- Porovnam tedy ceny vsech potravin v techto dvou letech. 

SELECT *
FROM v_3otazka_prum_cena
WHERE rok = 2006 OR rok = 2018;


-- Pridam vypocet procentualni zmeny mezi temito dvema roky, napr.:

SELECT potravina, 
       AVG(CASE WHEN rok = 2006 THEN prumerna_cena END) AS cena_2006,
       AVG(CASE WHEN rok = 2018 THEN prumerna_cena END) AS cena_2018,
       ROUND((AVG(CASE WHEN rok = 2018 THEN prumerna_cena END) - AVG(CASE WHEN rok = 2006 THEN prumerna_cena END)) 
             / AVG(CASE WHEN rok = 2006 THEN prumerna_cena END) * 100, 2) AS procentualni_zmena
FROM v_3otazka_prum_cena
WHERE rok IN (2006, 2018)  
GROUP BY potravina
ORDER BY procentualni_zmena ASC;

-- Vidím, že nektere potraviny zlevnily (zaporny rozdil). Toto musim zohlednit v odpovedi!

-- Vyradim Jakostni vino bílé, pro ktere neexistuje udaj za rok rok 2006: 

SELECT *
FROM v_3otazka_full
WHERE category_name = 'Jakostní víno bílé'
ORDER BY YEAR(date_from) ASC;


-- ODPOVED: 
-- V porovnavanem obdobi let 2006 a 2018 nejmene zdrazila kategorie Banany zlute.
-- V tomto obdobo dokonce existuji dve kategorie potravin, které zlevnily: Cukr krystalový a Rajská jablka. 
 










