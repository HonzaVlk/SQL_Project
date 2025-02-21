-- Otazka 5.
-- Má výška HDP vliv na změny ve mzdách a cenách potravin? 
-- Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na 
-- cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

-- Studium tabulky economies a countries.

SELECT *
FROM economies;


SELECT *
FROM countries;

-- Countries nepotrebuji. 

-- Zacilenejsi select na CR a roky. Udaje o cenach a pottravinch mame jen pro roky mezi 2006 a 2018. 

SELECT 
    country,
    year,
    GDP 
FROM economies
WHERE YEAR BETWEEN 2006 AND 2018
AND country = 'Czech Republic'
ORDER BY year;
 
-- Zjistim rust HDP v letech a nasledne porovnam s rustem cen a mezd v roce x a x+1

-- Vypocitam procentualni rozdil HD mezi roky. Pridam sloupce predchozi HDP a mezirocni zmena.  
-- Zajimaji me jen kladne hodnoty. 

CREATE OR REPLACE VIEW v_hdp_1
AS
SELECT 
    country,
    year,
    GDP,
    LAG(GDP) OVER (PARTITION BY country ORDER BY year) AS predchozi_GDP,
    ROUND(((GDP - LAG(GDP) OVER (PARTITION BY country ORDER BY year)) / 
           LAG(GDP) OVER (PARTITION BY country ORDER BY year)) * 100, 1) AS HDP_mezirocni_zmena_procenta
FROM economies
WHERE year BETWEEN 2006 AND 2018
AND country = 'Czech Republic'
ORDER BY year, HDP_mezirocni_zmena_procenta;

SELECT
	year as rok,
	HDP_mezirocni_zmena_procenta
FROM v_hdp_1
WHERE HDP_mezirocni_zmena_procenta > 0;

CREATE OR REPLACE VIEW v_hdp 
AS
SELECT
	year as rok,
	HDP_mezirocni_zmena_procenta
FROM v_hdp_1
WHERE HDP_mezirocni_zmena_procenta > 0;

SELECT *
FROM v_hdp
ORDER BY HDP_mezirocni_zmena_procenta DESC;

-------------------------------------------------------------------
 
-- Nyni porovnam s udaji o zmenach mezd a cen a vyvodim zaver. 
-- Vyuziji select z predchoziho ukolu. 
-- Spojim si vsechny views. 
-- Pouziji aliasy pro lepsi identifikaci tabulek a sloupcu.
-- Nejdrive mzdy a ceny:

CREATE OR REPLACE VIEW v_mzdy_ceny
AS
SELECT 
    c.rok,
    c.potravina,
    ROUND(c.potraviny_mezirocni_zmena_procenta, 2) AS potraviny_mezirocni_zmena_procenta,
    m.mzdy_mezirocni_zmena_procenta
FROM v_4otazka_ceny c
JOIN v_4otazka_mzdy_final m ON c.rok = m.rok;

SELECT *
FROM v_mzdy_ceny
WHERE potraviny_mezirocni_zmena_procenta > 0;

 -- Pouziji aliasz pre lespi idnetifikaci tabulek a sloupcu.

SELECT 
    c.rok,
    c.potravina, 
    h.HDP_mezirocni_zmena_procenta,
    c.potraviny_mezirocni_zmena_procenta,
    c.mzdy_mezirocni_zmena_procenta
FROM v_mzdy_ceny c
JOIN v_hdp h ON c.rok = h.rok
WHERE potraviny_mezirocni_zmena_procenta > 0; 

-- Pro lepsi prehlednost si seradim podle nejvyssich hodnot nahore:

SELECT 
    c.rok,
    c.potravina, 
    h.HDP_mezirocni_zmena_procenta,
    ROUND(c.potraviny_mezirocni_zmena_procenta, 1) AS potraviny_mezirocni_zmena_procenta,
    ROUND(c.mzdy_mezirocni_zmena_procenta, 1) AS mzdy_mezirocni_zmena_procenta
FROM v_mzdy_ceny c
JOIN v_hdp h ON c.rok = h.rok
ORDER BY 
    h.HDP_mezirocni_zmena_procenta DESC, 
    c.potraviny_mezirocni_zmena_procenta DESC, 
    c.mzdy_mezirocni_zmena_procenta DESC;

-- Odstranil jsem podminku kladne zmeny cen, abych videl, zda
-- nebyla nekdy zaporna.    
   
   
 -- ODPOVED:
 -- Studiem rustu po letech se neda jednoznacne urcit, zda existuje prima 
 -- a jednoznacna zavislost mezi rustem HDP a narustem cen a mezd. 
 -- Zatimco mezirocni rust mezd se pohybuje ve sledovanem obdobi v jednotkach 
 -- procent, tak ceny nekterych kategorii potravin se zvysily i o desitky 
 -- procent (a mektere potraviny zlevnily, taktez o desitky procent!}. 
 -- Pokud bychom se zamerili na jendotlive roky, pak lze najit leta, 
--  kdy vyraznejsi rust HDP korepsondoval s vzraynejsim rustem meyd a NEKTERYCH potravin 
-- (napr. roky 2007 nebo 2017}. Vycoj cen a mezd tak pravdepodobne ovlivnuje krome vydoje HDP i 
 -- i jine makroekonomicke ukazatele a politiky. 

   
   
   

