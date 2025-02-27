 -- Otazka c. 4 
 -- Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší 
 -- než růst mezd (větší než 10%)?

 -- Zatim nejmene jednozancne zadani. Trva mi chvili ujasnit si, na co se otazka pta a co pro odpoved musim zjistit.
 -- Asi je to takto: Existuje nejaka potravina, jejiz mezirocni zdrazeni je vice nez 10% nad  
 -- narustem mezirocni mzdy? Takto k zadani budu pristupovat. 
   
 -- Budu potrebovat souhrnne mezirocni mzdy za vsechna odvetvi dohromady a ty porovnam s mezirocnim narustem 
 -- cen potravin. Potrebuji vsechny potraviny a vsechny roky s mezirocnim rozdilem v procentech. 
 
 -- Vyuziji select z otazky c. 3 a udelam si novy view. 
 
SELECT *
FROM v_3otazka_prum_cena;
 
-- Pridam sloupec s procenty mezi roky, napr. s klauzuli LAG pro porovnani hodnot 
-- a PARTITION pro pocitani pro kazdou kategorii potravin z predchoziho roku.

CREATE OR REPLACE VIEW v_4otazka_ceny
AS
SELECT *,
    (prumerna_cena - LAG(prumerna_cena) OVER (PARTITION BY potravina ORDER BY rok)) / 
    LAG(prumerna_cena) OVER (PARTITION BY potravina ORDER BY rok) * 100 AS potraviny_mezirocni_zmena_procenta
FROM v_3otazka_prum_cena;

SELECT 
	rok,
	potravina,
	ROUND(potraviny_mezirocni_zmena_procenta, 2) AS potraviny_mezirocni_zmena_procenta
FROM v_4otazka_ceny
WHERE potraviny_mezirocni_zmena_procenta > 10;

-------------------------------------------------------------------

-- Nyní zjistim rozdily mezd mezirocne v procentech. 
-- Vyuziji select z otazky c. 1. 

CREATE OR REPLACE VIEW v_4otazka_mzdy
AS 
SELECT 
	odvetvi,    
	payroll_year AS rok, 
    SUM(value) AS rocni_mzda
FROM v_jan_vlkovsky_project_SQL_primary_final_1  
WHERE value_type_code = 5958
AND fyzicky_prepocteny = 'přepočtený'
AND odvetvi IS NOT NULL
GROUP BY payroll_year, odvetvi
ORDER BY odvetvi, payroll_year;

SELECT *
FROM v_4otazka_mzdy;

-- Sectu vsechny hodnoty podle odvetvi a vydelim poctem zaznamu, abych dostal prumernou mzdu
-- za dany rok, napr.: 

SELECT 
    rok, 
    SUM(rocni_mzda) / COUNT(*) AS prumerna_mzda
FROM v_4otazka_mzdy
GROUP BY rok
ORDER BY rok;

-- Pridam sloupec s procentualni mezirocni zmenou a udelam si novy view, napr. 

CREATE OR REPLACE VIEW v_4otazka_mzdy_final
AS
SELECT 
    rok, 
    SUM(rocni_mzda) / COUNT(*) AS prumerna_mzda,
    ROUND(
        (SUM(rocni_mzda) / COUNT(*) - LAG(SUM(rocni_mzda) / COUNT(*)) OVER (ORDER BY rok)) / 
        LAG(SUM(rocni_mzda) / COUNT(*)) OVER (ORDER BY rok) * 100, 2) AS mzdy_mezirocni_zmena_procenta
FROM v_4otazka_mzdy
GROUP BY rok
ORDER BY rok;

-- Zobrazim si jen potrebne:

SELECT 
	rok, 
	mzdy_mezirocni_zmena_procenta
FROM v_4otazka_mzdy_final;


 --------------------------------------------------------

-- Spojim si udaje o cenach a mzdach do jedne tabulky.

SELECT 
    c.rok,
    c.potravina,
    ROUND(c.potraviny_mezirocni_zmena_procenta, 2) AS potraviny_mezirocni_zmena_procenta,
    m.mzdy_mezirocni_zmena_procenta
FROM v_4otazka_ceny c
JOIN v_4otazka_mzdy_final m ON c.rok = m.rok
WHERE c.potraviny_mezirocni_zmena_procenta > 10;

-- Nyni zjistim ve kterych letech a potravinach je mezirocni rozdil narustu mzdy-ceny vyssi nez 10%. 

SELECT 
    c.rok,
    c.potravina,
    ROUND(c.potraviny_mezirocni_zmena_procenta, 2) AS potraviny_mezirocni_zmena_procenta,
    m.mzdy_mezirocni_zmena_procenta,
    ROUND(c.potraviny_mezirocni_zmena_procenta - m.mzdy_mezirocni_zmena_procenta, 2) AS rozdil_mezi_procenty
FROM v_4otazka_ceny c
JOIN v_4otazka_mzdy_final m ON c.rok = m.rok
WHERE c.potraviny_mezirocni_zmena_procenta > 10
ORDER BY rozdil_mezi_procenty DESC;

-- Vysledek je prekvapivy.
-- Zatimco udaje k mezirocnimu narustu mezd jsou celkem uveritelne (do 10%),
-- tak nektere ceny potravin mezirocne vyletely o desitky procent. 
-- Mzdam verim, ale musim si namatkou overit potraviny z predchozich selectů.

-- ODPOVED
-- V techto letech a kategoriich rostly ceny potravin vyrazneji nez mzdy. 
-- Serazeno podle nejvyssiho rozdilu rustu mezd a cen.  

   rok  potravina                               meziroční rozdíl mezi růstem cen a mezd

-- 2007	Papriky					87.94%
-- 2013	Konzumní brambory			61.88%
-- 2012	Vejce slepičí čerstvá			51.83%
-- 2018	Mrkev					41.67%
-- 2008	Pšeničná mouka hladká			35.26%
-- 2008	Rýže loupaná dlouhozrnná		29.32%
-- 2011	Pšeničná mouka hladká			28.11%
-- 2010	Konzumní brambory			27.93%
-- 2017	Máslo					27.17%
-- 2011	Pečivo pšeničné bílé			26.62%
-- 2015	Mrkev					25.88%
-- 2017	Eidamská cihla				22.4%
-- 2012	Rajská jablka červená kulatá		21.95%
-- 2010	Máslo					21.3%
-- 2017	Vejce slepičí čerstvá			20.67%
-- 2011	Cukr krystalový				20.55%
-- 2010	Rajská jablka červená kulatá		18.97%
-- 2013	Pšeničná mouka hladká			17.26%
-- 2010	Papriky					17.05%
-- 2007	Pšeničná mouka hladká			15.66%
-- 2008	Pečivo pšeničné bílé			15.63%
-- 2007	Pomeranče				15.36%
-- 2011	Chléb konzumní kmínový			15.29%
-- 2011	Máslo					15.24%
-- 2013	Máslo					14.53%
-- 2008	Rostlinný roztíratelný tuk		13.75%
-- 2008	Chléb konzumní kmínový			13.69%
-- 2011	Jablka konzumní				13.06%
-- 2013	Eidamská cihla				12.4%
-- 2013	Jablka konzumní				12.21%
-- 2012	Banány žluté				12.01%
-- 2013	Kuřata kuchaná celá			11.73%
-- 2008	Mrkev					11.35%
-- 2016	Konzumní brambory			10.45%
-- 2007	Chléb konzumní kmínový			10.06%
