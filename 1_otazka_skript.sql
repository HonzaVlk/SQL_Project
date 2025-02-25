-- Otázka č. 1:
	-- Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

-- Můj postup:
-- Seznamit se se strukturou vstupnich dat.  
-- Identifikovat sloupce, obsahujici relevantni informace. 
  
SELECT *
FROM czechia_payroll cp;

SELECT *
FROM czechia_payroll_calculation cpc;

SELECT *
FROM czechia_payroll_industry_branch cpib;

SELECT *
FROM czechia_payroll_unit cpu;

SELECT *
FROM czechia_payroll_value_type cpvt;

-- Prejmenovat relevantni sloupce z ciselniku podle legendy v cp prolepso orientaci
-- a napojit je k cp. 

SELECT 
		cp.*, 
		cpc.name AS fyzicky_prepocteny, 
		cpib.name AS odvetvi, 
		cpu.name AS osoby_Kc,
		cpvt.name AS prumzam_prummzda
FROM 
		czechia_payroll cp
LEFT JOIN 
		czechia_payroll_calculation cpc ON cp.calculation_code = cpc.code 
LEFT JOIN 
		czechia_payroll_industry_branch cpib ON cp.industry_branch_code  = cpib.code 
LEFT JOIN 
		czechia_payroll_unit cpu ON cp.unit_code = cpu.code
LEFT JOIN 
		czechia_payroll_value_type cpvt ON cp.value_type_code = cpvt.code;
		
-- Zacit tvorit tabulku s pozadovanym nazvem. 
	
CREATE TABLE t_jan_vlkovsky_project_SQL_primary_final

SELECT 
		cp.*, 
		cpc.name AS fyzicky_prepocteny, 
		cpib.name AS odvetvi, 
		cpu.name AS osoby_Kc,
		cpvt.name AS prumzam_prummzda
FROM 
		czechia_payroll cp
LEFT JOIN 
		czechia_payroll_calculation cpc ON cp.calculation_code = cpc.code 
LEFT JOIN 
		czechia_payroll_industry_branch cpib ON cp.industry_branch_code  = cpib.code 
LEFT JOIN 
		czechia_payroll_unit cpu ON cp.unit_code = cpu.code
LEFT JOIN 
		czechia_payroll_value_type cpvt ON cp.value_type_code = cpvt.code;
	
-- Overim si, ze tabulka existuje a funguje. 
	
SELECT *
FROM t_jan_vlkovsky_project_SQL_primary_final tjvpspf;


-- Zajima me prumerna mzda. To mi ukazuje hodnota 5958 ve sloupci value_type_code.
-- Vyfiltruji si jen tyto hodnoty. 
	
SELECT * 
FROM t_jan_vlkovsky_project_SQL_primary_final tjvpspf 
WHERE value_type_code = 5958;

-- Pro analyzu dat si musim upravit tabulku:  
-- Odstranim NULL hodnoty ve sloupci odvetvi.
-- Seradim podle let a podle odvetvi.  
-- Sloupec value mi ukazuje hodnoty prumerne mzdy v Kc.

SELECT * 
FROM t_jan_vlkovsky_project_SQL_primary_final tjvpspf 
WHERE value_type_code = 5958
AND odvetvi IS NOT NULL
ORDER BY odvetvi ASC;

-- Podívam se, zda vsechny roky u jednotlivych odvetvi obsahuji vsechna ctvrtleti. 
-- Napr. podle tohoto vzoru. 

SELECT * 
FROM t_jan_vlkovsky_project_SQL_primary_final tjvpspf 
WHERE value_type_code = 5958
AND odvetvi = 'Administrativní a podpůrné činnosti'
ORDER BY payroll_year;


-- Co znamená kód "fyzický nebo prepočtený?" Je pro můj výpocet dulezity? 
-- Dela mi to zmatek v rocích, kdy navysuje pocet kvartalu a ja potrebuji jen 4 v roce ... 
-- Chybi mi nejake vysvetlivky k ciselnikum? 
-- Rozhoduji se zahrnout pro vypocet pouze hodnotu "prepocteny". 


SELECT * 
FROM t_jan_vlkovsky_project_SQL_primary_final tjvpspf 
WHERE value_type_code = 5958
AND odvetvi = 'Administrativní a podpůrné činnosti'
AND fyzicky_prepocteny = 'přepočtený'
ORDER BY payroll_year;

-- Vadi mi format roku s carkou. Prevedu si na cele cislo bez carky v nastaveni DBeaveru.
-- Vidim, ze takto se mi zformatovala i ostatni cisla. Necham tak. 

SELECT * 
FROM t_jan_vlkovsky_project_SQL_primary_final tjvpspf 
WHERE value_type_code = 5958
AND odvetvi = 'Administrativní a podpůrné činnosti'
AND fyzicky_prepocteny = 'přepočtený'
ORDER BY payroll_year;

-- Vidím, že rok 2021 nema vsechny 4 kvartaly, proto 2021 z analyzy vynecham. 

SELECT * 
FROM t_jan_vlkovsky_project_SQL_primary_final tjvpspf 
WHERE value_type_code = 5958
AND industry_branch_code = 'A'
AND fyzicky_prepocteny = 'přepočtený'
ORDER BY payroll_year;

-- Udelam si vyber jen mzdy, rok, kvartal a odvetvi, napr. 

SELECT 
	value,
	payroll_year,
	payroll_quarter,
	industry_branch_code 
FROM t_jan_vlkovsky_project_SQL_primary_final tjvpspf 
WHERE value_type_code = 5958
AND industry_branch_code = 'A'
AND fyzicky_prepocteny = 'přepočtený'
ORDER BY payroll_year;

-- Sectu vsechny kvartalni hodnoty do jednoho roku u odvetvi, 
-- abych videl mzdu za dany rok, napr. 

SELECT 
    payroll_year, 
    SUM(value) AS total_value,
    industry_branch_code 
FROM t_jan_vlkovsky_project_SQL_primary_final tjvpspf 
WHERE value_type_code = 5958
AND industry_branch_code = 'S'
AND fyzicky_prepocteny = 'přepočtený'
GROUP BY payroll_year
ORDER BY payroll_year;

-- Z teto tabulky jsou videt kumulativni hodnoty za kazdy rok. 
-- Takto si postupne udelam tabulky pro kazde odvetvi, nahlednu na hodnoty
-- a vyvodim zavery. 
-- Vyselektuji si jen potrebne sloupce a srozumitelne je pojmenuji. 

SELECT 
	odvetvi,    
	payroll_year AS rok, 
    SUM(value) AS rocni_prumerna_mzda
FROM t_jan_vlkovsky_project_SQL_primary_final tjvpspf 
WHERE value_type_code = 5958
AND fyzicky_prepocteny = 'přepočtený'
AND odvetvi IS NOT NULL
AND payroll_year != 2021
GROUP BY payroll_year, odvetvi
ORDER BY odvetvi, payroll_year;

-- ODPOVED:
-- Mezi lety 2000 a 2020 mzdy ve vsech odvetvich obecne rostly. V tomto obdobi vsak byly i roky, 
-- kdy mzdy v nekterych odvetvich mezirocne klesaly. Podrobnosti nize:

-- Zemědělství, lesnictví, rybářství - prum. mzdy rostly kazdy rok
-- Těžba a dobývání - prum. mzdy rostly kazdy rok krome mezirocne v letech 2009, 2013, 2014, 2016
-- Zpracovatelský průmysl - prum. mzdy rostly kazdy rok
-- Výroba a rozvod elektřiny, plynu, tepla a klimatiz. vzduchu - prum. mzdy rostly kazdy rok krome mezirocne v letech 2011, 2013, 2015
-- Zásobování vodou; činnosti související s odpady a sanacemi - prum. mzdy rostly kazdy rok krome mezirocne v letech 2013
-- Stavebnictví - prum. mzdy rostly kazdy rok krome mezirocne v letech 2013
-- Velkoobchod a maloobchod; opravy a údržba motorových vozidel - prum. mzdy rostly kazdy rok krome mezirocne v letech 2013 
-- Doprava a skladování - prum. mzdy rostly kazdy rok krome mezirocne v letech 2011
-- Ubytování, stravování a pohostinství - prum. mzdy rostly kazdy rok krome mezirocne v letech 2009, 2011, 2020
-- Informační a komunikační činnosti - prum. mzdy rostly kazdy rok krome mezirocne v letech 2013
-- Peněžnictví a pojišťovnictví - prum. mzdy rostly kazdy rok krome mezirocne v letech 2013
-- Činnosti v oblasti nemovitostí - prum. mzdy rostly kazdy rok krome mezirocne v letech 2009, 2013, 2020
-- Profesní, vědecké a technické činnosti - prum. mzdy rostly kazdy rok krome mezirocne v letech 2010, 2013
-- Administrativní a podpůrné činnosti - prum. mzdy rostly kazdy rok krome mezirocne v letech 2013
-- Veřejná správa a obrana; povinné sociální zabezpečení - prum. mzdy rostly kazdy rok krome mezirocne v letech 2010
-- Vzdělávání - prum. mzdy rostly kazdy rok krome mezirocne v letech 2010
-- Zdravotní a sociální péče - prum. mzdy rostly kazdy rok 
-- Kulturní, zábavní a rekreační činnosti - prum. mzdy rostly kazdy rok krome mezirocne v letech 2013
-- Ostatní činnosti - prum. mzdy rostly kazdy rok. 







