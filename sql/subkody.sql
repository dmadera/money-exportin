SELECT
	K.Nazev,
	SUBSTRING(K.Kod, 5, 4) AS PodKod,
	SUBSTRING(K.Kod, 1, 4) AS Kod,
	''
FROM Artikly_KategorieArtiklu AS K WITH(NOLOCK)
WHERE 
	LEN(K.Kod) = 8
ORDER BY K.Poradi_UserData;