SELECT 
	name, 
	provider_type 
FROM healthcare_provider hp
ORDER BY TRIM (name) ASC;


SELECT *
FROM healthcare_provider hp;

 -- Úkol 1: Vypište od všech poskytovatelů zdravotních služeb jméno a typ. Záznamy seřaďte podle jména vzestupně.
SELECT
	name, 
	provider_type 
FROM healthcare_provider hp
ORDER BY TRIM (name);

-- Úkol 2: Vypište od všech poskytovatelů zdravotních služeb ID, jméno a typ. Záznamy seřaďte primárně podle kódu kraje a sekundárně podle kódu okresu.


SELECT
	provider_id,
	name,
	provider_type 
FROM healthcare_provider hp 
ORDER BY region_code, district_code;   

-- Úkol 3: Seřaďte na výpisu data z tabulky czechia_district sestupně podle kódu okresu.

SELECT *
FROM czechia_district cd
LIMIT 5;

SELECT *
FROM czechia_district cd
ORDER BY code DESC;   

-- Vypište abacedně pět posledních krajů v ČR.

SELECT *
FROM czechia_region cd
ORDER BY name DESC 
LIMIT 5;

SELECT *
FROM healthcare_provider hp 
LIMIT 5; 


 -- Úkol 5: Data z tabulky healthcare_provider vypište seřazena vzestupně dle typu poskytovatele a sestupně dle jména.


SELECT *
FROM healthcare_provider hp
ORDER BY provider_type, TRIM (name) DESC; 

-- Úkol 1: Přidejte na výpisu k tabulce healthcare_provider nový sloupec is_from_Prague, který bude obsahovat 1 pro poskytovate z Prahy a 0 pro ty mimo pražské.

ALTER TABLE healthcare_provider
	ADD COLUMN 'Is from Prague',

SELECT 
	name, 
	region_code	
	CASE 
		WHEN region_code =  'CZ010' THEN 1 
	END AS "IS form Prague"
	
FROM healthcare_provider hp; 
	
SELECT *
FROM czechia_region cr
WHERE name LIKE '%Praha%'
LIMIT 5;







