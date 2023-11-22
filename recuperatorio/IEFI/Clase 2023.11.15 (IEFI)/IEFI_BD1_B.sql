/*

ACTIVIDAD 1

*/

SELECT 
	c.nombre AS "Cliente", 
	SUM(mc.total) "Ventas Acumuladas", 
	'A' AS "Categoría Cliente"
FROM 
	mayorcab AS mc 
	INNER JOIN clientes AS c ON c.cliente = mc.cliente
WHERE 
	mc.anulada = 0 
GROUP BY 
	c.nombre 
HAVING 
	SUM(mc.total) > 100000
--
UNION
--
SELECT 
	c.nombre AS "Cliente",
	SUM(mc.total) "Ventas Acumuladas",
	'B' AS "Categoría Cliente"
FROM
	mayorcab AS mc 
	INNER JOIN clientes AS c ON c.cliente = mc.cliente
WHERE 
	mc.anulada = 0 
GROUP BY 
	c.nombre 
HAVING 
	SUM(mc.total) BETWEEN 50000 AND 100000
--
UNION
--
SELECT 
	c.nombre AS "Cliente",
	SUM(mc.total) "Ventas Acumuladas",
	'C' AS "Categoría Cliente"
FROM
	mayorcab AS mc 
	INNER JOIN clientes AS c ON c.cliente = mc.cliente
WHERE 
	mc.anulada = 0 
GROUP BY 
	c.nombre 
HAVING 
	SUM(mc.total) > 0 AND SUM(mc.total) < 50000
--
ORDER BY 3, 1

/*

ACTIVIDAD 2

*/

CREATE OR ALTER PROCEDURE sp_categorias_clientes
	@RangoA AS int,
	@RangoB AS int
AS

SET NOCOUNT ON

BEGIN TRY

	BEGIN TRANSACTION

	IF @RangoA < @RangoB
		GOTO FIN

	IF OBJECT_ID('tmp_categorias_clientes') IS NOT NULL
		DROP TABLE tmp_categorias_clientes

	CREATE TABLE tmp_categorias_clientes (
		"Cliente" char(100),
		"Ventas Acumuladas" decimal(9,2),
		"Categoría Cliente" char(1) )
			
	--
	INSERT INTO tmp_categorias_clientes
	--
	SELECT c.nombre AS "Cliente", SUM(mc.total) "Ventas Acumuladas", 'A' AS "Categoría Cliente"
	FROM mayorcab AS mc INNER JOIN clientes AS c ON c.cliente = mc.cliente
	WHERE mc.anulada = 0 GROUP BY c.nombre HAVING SUM(mc.total) > @RangoA
	--
	UNION
	--
	SELECT c.nombre AS "Cliente", SUM(mc.total) "Ventas Acumuladas", 'B' AS "Categoría Cliente"
	FROM mayorcab AS mc INNER JOIN clientes AS c ON c.cliente = mc.cliente
	WHERE mc.anulada = 0 GROUP BY c.nombre HAVING SUM(mc.total) BETWEEN @RangoB AND @RangoA
	--
	UNION
	--
	SELECT c.nombre AS "Cliente", SUM(mc.total) "Ventas Acumuladas", 'C' AS "Categoría Cliente"
	FROM mayorcab AS mc INNER JOIN clientes AS c ON c.cliente = mc.cliente
	WHERE mc.anulada = 0 GROUP BY c.nombre HAVING SUM(mc.total) > 0 AND SUM(mc.total) < @RangoB
	--
	ORDER BY 3, 1
	--
	PRINT 'El procedimiento finalizó. Se insertaron ' + TRIM(STR(@@ROWCOUNT)) + ' filas.'
	--
	COMMIT TRANSACTION

END TRY

BEGIN CATCH

	ROLLBACK TRANSACTION
	--
	PRINT 'Ocurrió un error durante la ejecución del procedimiento.'

END CATCH

-- FIN PROCEDIMIENTO

EXEC sp_categorias_clientes 100000, 50000

SELECT * FROM tmp_categorias_clientes

DROP TABLE tmp_categorias_clientes