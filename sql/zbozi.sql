SELECT DISTINCT
	A.Kod AS ID,
	A.Nazev AS Nazev,
	CONVERT(DECIMAL(10,2), Cena.Cena) AS ProdCena,
	CONVERT(INT, ISNULL(ArtJed.VychoziMnozstvi, 0)) AS VKart,
	CONVERT(INT, ISNULL(ArtJed1.VychoziMnozstvi, 0)) AS VFol,
	CONVERT(INT, IIF(Jednotka.NedelitelneMnozstvi > 1, Jednotka.NedelitelneMnozstvi, ISNULL(ArtJed1.VychoziMnozstvi, 0))) AS MinPocet,
	IIF(Jednotka.NedelitelneMnozstvi > 1, 'A', 'N') AS MinFol,
	A.Zkratka12 AS Pozice,
	CONVERT(INT, Dph.Sazba) AS Sazba,
	Jednotka.Kod AS Jednotka,
	ISNULL((SELECT TOP 1 SUBSTRING(Kod,1,4) FROM Artikly_KategorieArtiklu INNER JOIN STRING_SPLIT(A.Kategorie, '|') AS Split ON Split.value = CAST(Artikly_KategorieArtiklu.ID AS varchar(100)) ORDER BY LEN(Kod) DESC), '0000') AS Kod, 
	ISNULL((SELECT TOP 1 SUBSTRING(Kod,5,4) FROM Artikly_KategorieArtiklu INNER JOIN STRING_SPLIT(A.Kategorie, '|') AS Split ON Split.value = CAST(Artikly_KategorieArtiklu.ID AS varchar(100)) ORDER BY LEN(Kod) DESC), '0000') AS PodKod,
	CONVERT(INT, Zasoba.DostupneMnozstvi) AS AktualniStav,
	ISNULL(Priznak.Kod, '') AS Priznak,
	IIF(Druh.Kod = 'SPE', 'N', 'A') AS Zobrazovat,
	SUBSTRING(Firma.Kod, 3, 100) AS CisloDodavatele,
	''
FROM Artikly_Artikl AS A WITH(NOLOCK)
INNER JOIN USER_ArtiklyDph AS Dph WITH(NOLOCK) ON Dph.ID = A.ID
INNER JOIN Ciselniky_DruhArtiklu Druh WITH(NOLOCK) ON Druh.ID = A.DruhArtiklu_ID
INNER JOIN Sklady_Zasoba AS Zasoba WITH(NOLOCK) ON Zasoba.Artikl_ID = A.ID
INNER JOIN Ceniky_PolozkaCeniku AS Cena WITH(NOLOCK) ON Cena.Artikl_ID = A.ID AND Cena.Cenik_ID = (SELECT TOP 1 VychoziCenik_ID FROM System_AgendaDetail)
LEFT JOIN Artikly_ArtiklJednotka AS Jednotka WITH(NOLOCK) ON Jednotka.ID = A.HlavniJednotka_ID
LEFT JOIN (
	SELECT ArtProdKlic.Parent_ID AS Parent_ID, ProdKlic.Kod AS Kod
	FROM Artikly_ArtiklProduktovyKlic AS ArtProdKlic WITH(NOLOCK)
	INNER JOIN Artikly_ProduktovyKlic AS ProdKlic WITH(NOLOCK) ON ProdKlic.ID = ArtProdKlic.ProduktovyKlic_ID
	WHERE ProdKlic.Kod = '#'
) AS ProdKlicNeEshop ON ProdKlicNeEshop.Parent_ID = A.ID
LEFT JOIN (
	SELECT C.Artikl_ID AS Artikl_ID
	FROM Ceniky_PolozkaCeniku C WITH(NOLOCK)
	INNER JOIN Ceniky_Cenik Cenik WITH(NOLOCK) ON Cenik.ID = C.Cenik_ID
	WHERE Cenik.Kod NOT LIKE '\_%' ESCAPE '\'
	GROUP BY C.Artikl_ID
) AS SpecCena ON SpecCena.Artikl_ID = A.ID
LEFT JOIN (
	SELECT ArtProdKlic.Parent_ID AS Parent_ID, MIN(ProdKlic.Kod) AS Kod
	FROM Artikly_ArtiklProduktovyKlic AS ArtProdKlic WITH(NOLOCK)
	INNER JOIN Artikly_ProduktovyKlic AS ProdKlic WITH(NOLOCK) ON ProdKlic.ID = ArtProdKlic.ProduktovyKlic_ID
	WHERE ProdKlic.Kod IN ('A', 'S', 'N', 'O', 'X', 'D')
	GROUP BY ArtProdKlic.Parent_ID
) AS Priznak ON Priznak.Parent_ID = A.ID
LEFT JOIN (
	SELECT ArtJed.Parent_ID AS Parent_ID, ArtJed.VychoziMnozstvi
	FROM Artikly_ArtiklJednotka AS ArtJed WITH(NOLOCK) 
	INNER JOIN Ciselniky_Jednotka AS Jednotka WITH(NOLOCK) ON Jednotka.ID = ArtJed.Jednotka_ID AND Jednotka.Kod = 'kar'
) AS ArtJed ON ArtJed.Parent_ID = A.ID 
LEFT JOIN (
	SELECT ArtJed.Parent_ID AS Parent_ID, ArtJed.VychoziMnozstvi
	FROM Artikly_ArtiklJednotka AS ArtJed WITH(NOLOCK) 
	INNER JOIN Ciselniky_Jednotka AS Jednotka WITH(NOLOCK) ON Jednotka.ID = ArtJed.Jednotka_ID AND Jednotka.Kod = 'fol'
) AS ArtJed1 ON ArtJed1.Parent_ID = A.ID
LEFT JOIN Artikly_ArtiklDodavatel AS Dod WITH(NOLOCK) ON Dod.ID = A.HlavniDodavatel_ID
LEFT JOIN Adresar_Firma AS Firma WITH(NOLOCK) ON Firma.ID = Dod.Firma_ID
WHERE 
	A.Deleted = 0 AND A.Hidden = 0
	AND	ProdKlicNeEshop.Parent_ID IS NULL
	AND (Druh.Kod = 'ZBO' OR (Druh.Kod = 'SPE' AND SpecCena.Artikl_ID IS NOT NULL))
ORDER BY ID;