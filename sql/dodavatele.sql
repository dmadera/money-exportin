SELECT DISTINCT
	SUBSTRING(F.Kod, 3, 100) AS ID, 
	F.ObchNazev AS Nazev, 
	'' AS Nazev2,
	F.ObchUlice AS Ulice, 
	F.ObchPsc AS PSC, 
	F.ObchMisto AS Mesto, 
	F.ICO AS ICO, 
	ISNULL(TRIM(SUBSTRING(F.DIC, 1, 2)),'') AS DIC1, 
	ISNULL(TRIM(SUBSTRING(F.DIC, 3, 100)),'') AS DIC2,
	ISNULL(Os.Prijmeni,'') AS Zastoupeny,
	ISNULL(F.Tel1Cislo,'') AS Telefon,
	ISNULL(F.Tel2Cislo,'') AS Telefon1,
	ISNULL(F.Email,'') AS Mail,
	''
FROM Adresar_Firma AS F WITH(NOLOCK) 
LEFT JOIN Adresar_Osoba AS Os WITH(NOLOCK) ON Os.ID = F.HlavniOsoba_ID
LEFT JOIN (
	SELECT 
		STRING_AGG(SpojeniCislo, ',') AS SpojeniCislo, Spoj.Parent_ID
	FROM Adresar_Spojeni AS Spoj WITH(NOLOCK)
	INNER JOIN Adresar_TypSpojeni AS TypSpoj WITH(NOLOCK) ON TypSpoj.ID = Spoj.TypSpojeni_ID AND TypSpoj.Kod = 'Email'
	GROUP BY Spoj.Parent_ID
) AS Spoj ON Spoj.Parent_ID = F.ID
WHERE 
	F.Deleted = 0 
	AND F.Hidden = 0
	AND (F.Kod LIKE 'AD20%' OR F.Kod LIKE 'AD21%')
ORDER BY ID;