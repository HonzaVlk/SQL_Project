-- UKOL:
-- Vytvorit tabulku pro data mezd a cen potravin za Českou republiku sjednocených na totožné porovnatelné období – společné roky.

-- Jelikoz jsem tak nedelal od zacatku, musim tabulku vytvorit z relevantnich views a dale si je upravit, napr.:

-- Mzdy


CREATE OR REPLACE VIEW v_mzdy 
AS
SELECT 
	cp.*, 
	cpc.name AS fyz_nebo_prepoc, 
	cpib.name AS odvetvi, 
	cpu.name AS Kc_nebo_osoby, 
	cpvt.name AS prum_mzda_nebo_osoby
FROM czechia_payroll AS cp 
LEFT JOIN 
	czechia_payroll_calculation cpc ON cp.calculation_code = cpc.code 
LEFT JOIN 
	czechia_payroll_industry_branch cpib ON cp.industry_branch_code  = cpib.code 
LEFT JOIN 
	czechia_payroll_unit cpu ON cp.unit_code = cpu.code
LEFT JOIN 
	czechia_payroll_value_type cpvt ON cp.value_type_code = cpvt.code
WHERE 
	value_type_code = 5958 AND calculation_code = 200
AND cp.industry_branch_code IS NOT NULL
GROUP BY payroll_year, odvetvi;


SELECT *
FROM v_mzdy;

-- Ceny

SELECT *
FROM czechia_price cp 

SELECT *
FROM czechia_price_category cpc 

CREATE OR REPLACE VIEW v_ceny
AS
SELECT 
    cp.value AS cena,
    cp.category_code AS kod_potraviny,
    cpc.name AS potravina,
    DATE_FORMAT(cp.date_from, '%d.%m.%Y') AS od,
    DATE_FORMAT(cp.date_to, '%d.%m.%Y') AS do
FROM czechia_price cp
LEFT JOIN czechia_price_category cpc ON cp.category_code = cpc.code;

SELECT * 
FROM v_ceny;

--Sjednotim roky podle prumerne ceny dane potraviny v tom kterem roce, serazeno podle abecedy.

CREATE OR REPLACE VIEW v_ceny
AS
SELECT 
    ROUND(AVG(cp.value), 2) AS cena,
    cp.category_code AS kod_potraviny,
    cpc.name AS potravina,
    YEAR(cp.date_from) AS rok  
FROM czechia_price cp
LEFT JOIN czechia_price_category cpc ON cp.category_code = cpc.code
GROUP BY cp.category_code, cpc.name, YEAR(cp.date_from)
ORDER BY potravina, rok;

SELECT * 
FROM v_ceny;

-- Spojim obe views

CREATE OR REPLACE VIEW v_jan_vlkovsky_project_SQL_primary_final_interim
AS 
SELECT 
    v_ceny.*,
    v_mzdy.*  
FROM v_mzdy 
LEFT JOIN v_ceny ON v_mzdy.payroll_year = v_ceny.rok
WHERE payroll_year BETWEEN 2006 AND 2018
ORDER BY payroll_year, odvetvi;

SELECT *
FROM v_jan_vlkovsky_project_SQL_primary_final_interim;

-- Ucesani  s cilem mit co nejmene sloupcu (vzhledem k mnozinam odvetvi 
-- a potraviny nelze dosahnout zaznam typu 1 rok = 1 odvetvi = 1 potravina).

CREATE OR REPLACE TABLE t_jan_vlkovsky_project_SQL_primary_final
AS
SELECT 
	rok,
	odvetvi,
	value AS prumerna_mzda,
	potravina,
	cena AS prumerna_cena
FROM v_jan_vlkovsky_project_SQL_primary_final_interim;

SELECT *
FROM t_jan_vlkovsky_project_SQL_primary_final;


