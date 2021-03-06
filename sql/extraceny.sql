SELECT
	Cenik.Kod AS Skupina,
	Art.Kod AS ID,
	FORMAT(C.Cena, '0.00') AS Cena,
	''
FROM Ceniky_PolozkaCeniku AS C WITH(NOLOCK)
INNER JOIN Artikly_Artikl AS Art WITH(NOLOCK) ON Art.ID = C.Artikl_ID
INNER JOIN Ceniky_Cenik AS Cenik WITH(NOLOCK) ON Cenik.ID = C.Cenik_ID
WHERE 
	Cenik.Kod NOT LIKE '\_%' ESCAPE '\'
ORDER BY ID;