SELECT DISTINCT
	D.Kod AS Kod,
	IIF(D.Popis_UserData <> '', D.Popis_UserData, D.Nazev) AS Nazev
FROM Ciselniky_ZpusobDopravy AS D WITH(NOLOCK)
WHERE D.Deleted = 0 AND D.Hidden = 0
ORDER BY Kod;