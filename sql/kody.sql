SELECT
	K.Nazev,
	SUBSTRING(K.Kod, 1, 4) AS Kod,
	''
FROM Artikly_KategorieArtiklu AS K WITH(NOLOCK)
WHERE 
	LEN(K.Kod) = 4
ORDER BY K.Poradi_UserData;