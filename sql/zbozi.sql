SET NOCOUNT ON

USE S4_Agenda_PEMA
GO

SELECT DISTINCT
	A.Kod AS ID,
	A.Nazev AS Nazev,
	CONVERT(DECIMAL(10,2), Cena.Cena) AS ProdCena,
	CONVERT(INT, ISNULL(ArtJed.VychoziMnozstvi, 0)) AS VKart,
	CONVERT(INT, ISNULL(ArtJed1.VychoziMnozstvi, 0)) AS VFol,
	IIF(Jednotka.NedelitelneMnozstvi = ArtJed1.VychoziMnozstvi, 'A', 'N') AS MinFol,
	A.Zkratka12 AS Pozice,
	CONVERT(INT, Dph.Sazba) AS Sazba,
	Jednotka.Kod AS Jednotka,
	ISNULL((SELECT TOP 1 SUBSTRING(Kod,1,4) FROM Artikly_KategorieArtiklu INNER JOIN STRING_SPLIT(A.Kategorie, '|') AS Split ON Split.value = CAST(Artikly_KategorieArtiklu.ID AS varchar(100)) ORDER BY LEN(Kod) DESC), '0000') AS Kod, 
	ISNULL((SELECT TOP 1 SUBSTRING(Kod,5,4) FROM Artikly_KategorieArtiklu INNER JOIN STRING_SPLIT(A.Kategorie, '|') AS Split ON Split.value = CAST(Artikly_KategorieArtiklu.ID AS varchar(100)) ORDER BY LEN(Kod) DESC), '0000') AS PodKod,
	Zasoba.DostupneMnozstvi,
	ISNULL(Priznak.Kod, '') AS Priznak,
	IIF(ProdKlicExtraOnly.Kod IS NULL, 'A', 'N') AS Zobrazovat,
	SUBSTRING(Firma.Kod, 3, 100) AS CisloDodavatele,
	''
FROM Artikly_Artikl AS A
INNER JOIN USER_ArtiklyDph AS Dph ON Dph.ID = A.ID
INNER JOIN Sklady_Zasoba AS Zasoba ON Zasoba.Artikl_ID = A.ID
INNER JOIN Ceniky_PolozkaCeniku AS Cena ON Cena.Artikl_ID = A.ID AND Cena.Cenik_ID = (SELECT TOP 1 VychoziCenik_ID FROM System_AgendaDetail)
LEFT JOIN Artikly_ArtiklJednotka AS Jednotka ON Jednotka.ID = A.HlavniJednotka_ID
LEFT JOIN (
	SELECT ArtProdKlic.Parent_ID AS Parent_ID, ProdKlic.Kod AS Kod
	FROM Artikly_ArtiklProduktovyKlic AS ArtProdKlic
	INNER JOIN Artikly_ProduktovyKlic AS ProdKlic ON ProdKlic.ID = ArtProdKlic.ProduktovyKlic_ID
	WHERE ProdKlic.Kod = '#'
) AS ProdKlicNeEshop ON ProdKlicNeEshop.Parent_ID = A.ID
LEFT JOIN (
	SELECT ArtProdKlic.Parent_ID AS Parent_ID, ProdKlic.Kod AS Kod
	FROM Artikly_ArtiklProduktovyKlic AS ArtProdKlic
	INNER JOIN Artikly_ProduktovyKlic AS ProdKlic ON ProdKlic.ID = ArtProdKlic.ProduktovyKlic_ID
	WHERE ProdKlic.Kod = '@'
) AS ProdKlicExtraOnly ON ProdKlicExtraOnly.Parent_ID = A.ID
LEFT JOIN (
	SELECT ArtProdKlic.Parent_ID AS Parent_ID, MIN(ProdKlic.Kod) AS Kod
	FROM Artikly_ArtiklProduktovyKlic AS ArtProdKlic
	INNER JOIN Artikly_ProduktovyKlic AS ProdKlic ON ProdKlic.ID = ArtProdKlic.ProduktovyKlic_ID
	WHERE ProdKlic.Kod IN ('A', 'S', 'N', 'O', 'X', 'D')
	GROUP BY ArtProdKlic.Parent_ID
) AS Priznak ON Priznak.Parent_ID = A.ID
LEFT JOIN (
	SELECT ArtJed.Parent_ID AS Parent_ID, ArtJed.VychoziMnozstvi
	FROM Artikly_ArtiklJednotka AS ArtJed 
	INNER JOIN Ciselniky_Jednotka AS Jednotka ON Jednotka.ID = ArtJed.Jednotka_ID AND Jednotka.Kod = 'kar'
) AS ArtJed ON ArtJed.Parent_ID = A.ID 
LEFT JOIN (
	SELECT ArtJed.Parent_ID AS Parent_ID, ArtJed.VychoziMnozstvi
	FROM Artikly_ArtiklJednotka AS ArtJed 
	INNER JOIN Ciselniky_Jednotka AS Jednotka ON Jednotka.ID = ArtJed.Jednotka_ID AND Jednotka.Kod = 'fol'
) AS ArtJed1 ON ArtJed1.Parent_ID = A.ID
LEFT JOIN Artikly_ArtiklDodavatel AS Dod ON Dod.ID = A.HlavniDodavatel_ID
LEFT JOIN Adresar_Firma AS Firma ON Firma.ID = Dod.Firma_ID
WHERE 
	ProdKlicNeEshop.Parent_ID IS NULL
	AND A.ExistujeKategorie = 1
ORDER BY ID