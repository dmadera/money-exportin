SELECT
	Cenik.Kod AS Skupina,
	Art.Kod AS ID,
	FORMAT(C.Cena, '0.00') AS Cena,
	''
FROM Ceniky_PolozkaCeniku AS C
INNER JOIN Artikly_Artikl AS Art ON Art.ID = C.Artikl_ID
INNER JOIN Ceniky_Cenik AS Cenik ON Cenik.ID = C.Cenik_ID
WHERE 
	Cenik.Kod NOT LIKE '\_%' ESCAPE '\'
ORDER BY ID;