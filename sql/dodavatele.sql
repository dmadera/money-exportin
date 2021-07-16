SET NOCOUNT ON

USE S4_Agenda_PEMA
GO

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
FROM Adresar_Firma AS F
LEFT JOIN System_Groups AS Grp ON Grp.ID = F.Group_ID
LEFT JOIN Adresar_Osoba AS Os ON Os.ID = F.HlavniOsoba_ID
LEFT JOIN (
	SELECT 
		STRING_AGG(SpojeniCislo, ',') AS SpojeniCislo, Spoj.Parent_ID
	FROM Adresar_Spojeni AS Spoj
	INNER JOIN Adresar_TypSpojeni AS TypSpoj ON TypSpoj.ID = Spoj.TypSpojeni_ID AND TypSpoj.Kod = 'Email'
	GROUP BY Spoj.Parent_ID
) AS Spoj ON Spoj.Parent_ID = F.ID
WHERE 
	F.Deleted = 0
	AND F.Nazev NOT LIKE '||%'
	AND F.Kod LIKE 'AD2%'
	AND (Grp.Kod != 'ZRUS' OR Grp.Kod IS NULL)
ORDER BY ID