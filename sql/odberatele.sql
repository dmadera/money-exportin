SELECT DISTINCT
	SUBSTRING(F.Kod, 3, 100) AS ID, 
	F.ObchNazev AS Nazev, 
	IIF(F.Nazev = F.ObchNazev, '', F.Nazev) AS Nazev2,
	F.ObchUlice AS Ulice, 
	F.ObchPsc AS PSC, 
	F.ObchMisto AS Mesto, 
	F.ICO AS ICO, 
	ISNULL(TRIM(SUBSTRING(F.DIC, 1, 2)),'') AS DIC1, 
	ISNULL(TRIM(SUBSTRING(F.DIC, 3, 100)),'') AS DIC2,
	CASE WHEN Os.Prijmeni IS NULL THEN ''
	WHEN Os.Prijmeni = '<Neznamy>' THEN ''
	ELSE Os.Prijmeni END AS Prebirajici,
	ISNULL(F.Tel1Cislo,'') AS Telefon,
	ISNULL(F.Email, '') AS Mail,
	'N' AS Odesilat,
	ISNULL(Spoj.SpojeniCislo,'') AS MailFA,  
	IIF(F.PouzivatKredit = 1, 'N', 'A') AS KupniSmlouva,
	FORMAT(F.HodnotaSlevy, '0.00') AS RabatO, 
	FORMAT(IIF(F.SlevaUvadena_UserData != 0, F.SlevaUvadena_UserData, F.HodnotaSlevy), '0.00') AS PRabatO,
	-- pokud neni akcni nebo ma nizsi prioritu nez prodejni => prirazka=A, v eshopu: pokud sleva<0 a prirazka=N tak sleva je 0
	IIF(FirmaCenikAkce.Poradi IS NULL OR FirmaCenikAkce.Poradi > FirmaCenikProdej.Poradi, 'A', 'N') AS Prirazka,
	-- vybere specialni cenik
	ISNULL(FirmaCenik1.Kod,'') AS CisloSkup,
	F.KodOdb_UserData AS KodOdb,
	ZpDopr.Kod,
	''
FROM Adresar_Firma AS F WITH(NOLOCK)
LEFT JOIN System_Groups AS Grp WITH(NOLOCK) ON Grp.ID = F.Group_ID
LEFT JOIN Adresar_Osoba AS Os WITH(NOLOCK) ON Os.ID = F.HlavniOsoba_ID
LEFT JOIN (
	SELECT
		FirmaCenik.Parent_ID AS Firma_ID, FirmaCenik.Poradi AS Poradi
	FROM Adresar_FirmaCenik AS FirmaCenik WITH(NOLOCK)
	INNER JOIN Ceniky_Cenik AS Cenik WITH(NOLOCK) ON Cenik.ID = FirmaCenik.Cenik_ID
	WHERE Cenik.Kod = '_AKCE'
) AS FirmaCenikAkce ON FirmaCenikAkce.Firma_ID = F.ID
LEFT JOIN (
	SELECT
		FirmaCenik.Parent_ID AS Firma_ID, FirmaCenik.Poradi AS Poradi
	FROM Adresar_FirmaCenik AS FirmaCenik WITH(NOLOCK)
	INNER JOIN Ceniky_Cenik AS Cenik WITH(NOLOCK) ON Cenik.ID = FirmaCenik.Cenik_ID
	WHERE Cenik.Kod = '_PRODEJ'
) AS FirmaCenikProdej ON FirmaCenikProdej.Firma_ID = F.ID
LEFT JOIN (
	SELECT
		MIN(FirmaCenik.Poradi) AS Poradi, FirmaCenik.Firma_ID AS Firma_ID, MIN(Cenik.Kod) AS Kod
	FROM Adresar_FirmaCenik AS FirmaCenik WITH(NOLOCK)
	INNER JOIN Ceniky_Cenik AS Cenik WITH(NOLOCK) ON Cenik.ID = FirmaCenik.Cenik_ID
	WHERE Cenik.Kod NOT IN ('_AKCE', '_NAKUP', '_PRODEJ')
	GROUP BY FirmaCenik.Firma_ID
) AS FirmaCenik1 ON FirmaCenik1.Firma_ID = F.ID
LEFT JOIN (
	SELECT TOP 1
		SpojeniCislo, Spoj.Parent_ID
	FROM Adresar_Spojeni AS Spoj WITH(NOLOCK)
	INNER JOIN Adresar_TypSpojeni AS TypSpoj WITH(NOLOCK) ON TypSpoj.ID = Spoj.TypSpojeni_ID AND TypSpoj.Kod = 'EmailFa'
) AS Spoj ON Spoj.Parent_ID = F.ID
LEFT JOIN Ciselniky_ZpusobDopravy AS ZpDopr ON ZpDopr.ID = F.ZpusobDopravy_ID
WHERE 
	F.Deleted = 0 AND F.Hidden = 0
	AND NOT (F.Kod LIKE 'AD20%' OR F.Kod LIKE 'AD21%')
ORDER BY ID;