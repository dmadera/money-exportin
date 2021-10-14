SELECT DISTINCT
	SUBSTRING(F.Kod, 3, 100) AS ID, 
	F.ProvNazev AS Nazev, 
	'' AS Nazev2,
	F.ProvUlice AS Ulice, 
	F.ProvPsc AS PSC, 
	F.ProvMisto AS Mesto,
	''
FROM Adresar_Firma AS F WITH(NOLOCK) 
WHERE 
	F.Deleted = 0 AND F.Hidden = 0
	AND NOT (F.Kod LIKE 'AD20%' OR F.Kod LIKE 'AD21%')
ORDER BY ID;