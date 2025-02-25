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

-- Zacilenejsi select na CR a roky. Udaje o cenach a potravinch mame jen pro roky mezi 2006 a 2018. 

SELECT 
    country,
    year,
    GDP 
FROM economies
WHERE YEAR BETWEEN 2006 AND 2018
AND country = 'Czech Republic'
ORDER BY year;
 
-- Zjistim rust HDP v letech a nasledne porovnam s rustem cen a mezd v roce x a x+1

-- Vypocitam procentualni rozdil HDP mezi roky. Pridam sloupce "predchozi HDP" a "mezirocni zmena".  
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
-- Spojim si vsechny views. (Pouziji aliasy pro lepsi identifikaci tabulek a sloupcu.)
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

 -- Aliasy pro lepsi identifikaci tabulek a sloupcu.

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

-- Odstranil jsem podminku kladne zmeny cen, abych videl, zda nekdy neklesaly.     

 -- ODPOVED:
  
 -- DOPAD rustu HDP na CENY potravin:  
 -- Data nepotvrzuji primou souvislost mezi vyraznym (ci jakymkoliv) rustem HDP a naslednym (vyraznym) rustem 
 -- cen vsech potravin. V nekterych letech po vyraznem predchozim rustu HDP sice v roce nasledujicim 
 -- ceny potravin vzrostly (a to i o dvouciferne hodnoty), ale stejne tak mezirocne nektere potraviny
 -- zlevnily (take o dvojciferne hodnoty, napr. roky 2007/2008). Roky 2015/2016 zase ukazuji, ze
 -- po vyznamnem rustu HDP ceny mezironce poklesly u vice nez poloviny sledovanych kategorii. 
   
 -- DOPAD rustu HDP na MZDY:
 -- Data nepotvrzuji jednoznacnou korelaci mezi vyraznym rustem HDP v jednom roce a vyraznym rustem
 -- mezd v roce nasledujicim. Prima umera nastala napr. v roce 2007 a 2008: 
 -- HDP v roce 2007 vzrostl o 5,6% (coz byla maximalni hodnota za sledovane obdobi) a mzdy v roce 2008 
 -- vzrostly o 7,7% (coz je take nejvyssi hodnota). Ale napr. druhy nejvyssi rust HDP 
 -- (o 5,4% v roce 2015) se projevil jen prumernym rustem mezd v roce nasledujicim (o 3,6% v roce 2016). 
 -- Data ukazuji i stav, kdy po nevysokem rustu HDP v jednom roce nasledoval pomerne vyrazny rust mezd 
 -- v roce nasledujicim (2016: rust HDP o 2,5% a 2017: rust mezd o 6,2%).   
     
 -- Vyvoj cen a mezd tak velmi pravdepodobne ovlivnuji krome vyvoje HDP i jine makroekonomicke 
 -- ukazatele a politiky a dalsi vlivy. 

   
   

