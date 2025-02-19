-- Otázka č.2: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období 
-- v dostupných datech cen a mezd?

-- Podivam se na zdrojove tabulky a ciselniky a prostuduji.

SELECT *
FROM czechia_price cp; 

SELECT *
FROM czechia_price_category cpc;

SELECT *
FROM czechia_price cp
ORDER BY cp.date_from; 
-- Zajimaji me sloupce value, category_code, date_from a date_to.

SELECT *
FROM czechia_price_category cpc
ORDER BY cpc.name;
-- Zajima me sloupec name a codes 111301 (chleb) a 114201 (mleko)

-- Udelam si select s relevantnimi sloupci, napr.:

SELECT 
	value AS cena,
	category_code AS potravina,
	date_from AS od,
	date_to AS do
FROM czechia_price cp
WHERE category_code IN (111301, 114201)
ORDER BY cp.date_from;

-- Prevedu si datum na srozumitelnejsi format, abych videl, ktere je nejstarsi
-- a ktere nejnovejsi obdobi a jaky casovy interval to je. V dalsich krocich porovnam s udaji o prumerne mzde
-- v techto obdobich. 

SELECT 
    value AS cena,
    category_code AS potravina,
    DATE_FORMAT(date_from, '%d.%m.%Y') AS od,
    DATE_FORMAT(date_to, '%d.%m.%Y') AS do
FROM czechia_price cp
WHERE category_code IN (111301, 114201)
ORDER BY cp.date_from;
 
-- Zobrazim si i nazvy potravin chleb a mleko.

SELECT 
    value AS cena,
    CASE 
        WHEN category_code = 111301 THEN 'chléb'
        WHEN category_code = 114201 THEN 'mléko'
        ELSE category_code 
    END AS potravina,
    DATE_FORMAT(date_from, '%d.%m.%Y') AS od,
    DATE_FORMAT(date_to, '%d.%m.%Y') AS do
FROM czechia_price cp
WHERE category_code IN (111301, 114201)
ORDER BY cp.date_from;

-- Vidim, ze obdobi cen jsou po tydnech. Navic cen pro obe potraviny je vice v jednom tydnu ... 
-- Budu asi muset zprumerovat tyto hodnoty.
-- Pripomenu si tabulku mezd kvuli prvnimu a poslednimu obdobi. 

SELECT *
FROM czechia_payroll cp;

-- Obdobi mezd jsou po ctvrtletich. Budu muset zprumerovat ceny za prvni a posledni srovnatelne ctvrtleti. 
-- Zjednodusim si zobrazeni via view, napr:

CREATE OR REPLACE VIEW v_2otazka
AS
SELECT 
    value AS cena,
    CASE 
        WHEN category_code = 111301 THEN 'chléb'
        WHEN category_code = 114201 THEN 'mléko'
        ELSE category_code 
    END AS potravina,
    DATE_FORMAT(date_from, '%d.%m.%Y') AS od,
    DATE_FORMAT(date_to, '%d.%m.%Y') AS do
FROM czechia_price cp
WHERE category_code IN (111301, 114201)
ORDER BY cp.date_from;

SELECT *
FROM v_2otazka; 

-- Nyni potrebuji:
-- seskupit do ctvrtleti
-- chci videt prvni a posledni datum ve ctvrtleti
-- zprumerovat ceny, napr.: 

SELECT 
    YEAR(date_from) AS rok,
    QUARTER(date_from) AS ctvrtleti,
    CASE 
        WHEN category_code = 111301 THEN 'chléb'
        WHEN category_code = 114201 THEN 'mléko'
        ELSE 'ostatní'
    END AS potravina,
    DATE_FORMAT(MIN(date_from), '%d.%m.%Y') AS od, 
    DATE_FORMAT(MAX(date_to), '%d.%m.%Y') AS do, 
    ROUND(AVG(value),2) AS prumerna_cena
FROM czechia_price cp
WHERE category_code IN (111301, 114201)
GROUP BY rok, ctvrtleti, potravina
ORDER BY rok DESC, ctvrtleti DESC, potravina ASC;

-- Vidim, ze nektera ctvrtleti nejsou uplna (neobsahuji vsechny dny ve ctvrtleti). 
-- Rozhodl jsem se to ignorovat a vzit jakekoliv prvni a posledni ctvrtleti,
-- pro ktera existuji jakakoliv data. 

CREATE OR REPLACE VIEW v_2otazka_1
AS
SELECT 
    YEAR(date_from) AS rok,
    QUARTER(date_from) AS ctvrtleti,
    CASE 
        WHEN category_code = 111301 THEN 'chléb'
        WHEN category_code = 114201 THEN 'mléko'
        ELSE 'ostatní'
    END AS potravina,
    DATE_FORMAT(MIN(date_from), '%d.%m.%Y') AS od, 
    DATE_FORMAT(MAX(date_to), '%d.%m.%Y') AS do, 
    ROUND(AVG(value),2) AS prumerna_cena
FROM czechia_price cp
WHERE category_code IN (111301, 114201)
GROUP BY rok, ctvrtleti, potravina
ORDER BY rok DESC, ctvrtleti DESC, potravina ASC;

SELECT *
FROM v_2otazka_1;

-- Rozhoduji se pouzit 1. ctvrtleti roku 2006 a 4 ctvrtleti roku 2018. 
-- Zobrazim si prislusne radky:

CREATE OR REPLACE VIEW v_2otazka_ceny
AS 
SELECT 
    rok, 
    ctvrtleti, 
    potravina, 
    prumerna_cena
FROM v_2otazka_1
WHERE (rok = 2018 AND ctvrtleti = 4)
   OR (rok = 2006 AND ctvrtleti = 1);
  
SELECT *
FROM v_2otazka_ceny;
 
-- Nyni potrebuji ziskat prumernou mzdu ve stejnych obdobich. Pomuzu si vysledky z otazky c. 1
-- Vyberu jen relevantni sloupce a seskupim podle kvartalu a mezd ve vsech odvetvich. 

CREATE OR REPLACE VIEW v_2otazka_mzdy_mezikrok
AS
SELECT
	value AS prum_mzda,
	payroll_year AS rok,
	payroll_quarter AS ctvrtleti,
	industry_branch_code AS odvetvi
FROM czechia_payroll cp
WHERE ((payroll_year = 2006 AND payroll_quarter = 1)
   OR (payroll_year = 2018 AND payroll_quarter = 4))
AND value_type_code = 5958
AND industry_branch_code IS NOT NULL
AND value IS NOT NULL 
AND calculation_code = 200;

-- Zkontroluji si zastoupeni vsech odvetvi A-S.

SELECT *
FROM v_2otazka_mzdy_mezikrok
ORDER BY rok, odvetvi;

CREATE OR REPLACE VIEW v_2otazka_mzdy
AS
SELECT 
    rok,
    ctvrtleti,
    ROUND(AVG(prum_mzda),2) AS prum_mzda
FROM v_2otazka_mzdy_mezikrok
GROUP BY rok
ORDER BY rok;

SELECT *
FROM v_2otazka_mzdy;

-- Napojim si obe view.

SELECT 
v_2otazka_ceny. *, v_2otazka_mzdy. * 
FROM v_2otazka_ceny
LEFT JOIN v_2otazka_mzdy ON v_2otazka_ceny.rok = v_2otazka_mzdy.rok;

-- Vytvorim sloupec se vzorcem pro vypocet kolikrat se cena vejde do mzdy.

SELECT 
    v_2otazka_ceny.*, 
    v_2otazka_mzdy.*, 
    ROUND(v_2otazka_mzdy.prum_mzda / v_2otazka_ceny.prumerna_cena) AS kolik_l_kg
FROM v_2otazka_ceny
LEFT JOIN v_2otazka_mzdy ON v_2otazka_ceny.rok = v_2otazka_mzdy.rok
ORDER BY v_2otazka_ceny.rok, v_2otazka_ceny.potravina DESC;

-- ODPOVED:
-- Za prvni srovnatelne obdobi bylo mozne si koupit 1405l mléka a 1358kg chleba. 
-- Za posledni srovnatelne obdobi bylo mozne koupit 1803l mléka a 1471kg chleba. 
-- Vysv.: Porovnavanymi obdobimi jsou 1. ctvrtleti roku 2006 a 4. ctvrtleti roku 2018.  

-- nejvice me potrapilo prevedeni data po tzdnech an ctvrtleti a pak royhodnuti, ktera jsou relevantni obdobi

		
