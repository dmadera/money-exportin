SELECT DISTINCT
	SUBSTRING(F.Kod, 3, 100) AS ID, 
	F.ProvNazev AS Nazev, 
	'' AS Nazev2,
	F.ProvUlice AS Ulice, 
	F.ProvPsc AS PSC, 
	F.ProvMisto AS Mesto,
	''
FROM Adresar_Firma AS F
LEFT JOIN System_Groups AS Grp ON Grp.ID = F.Group_ID
WHERE 
	F.Kod NOT LIKE 'AD2%'
	AND (Grp.Kod != 'ZRUS' OR Grp.Kod IS NULL)
ORDER BY ID;