/*

ACTIVIDAD 1

*/

SELECT
	vc.vendedor AS Vendedor,
	v.nombre AS Nombre,
	v.encargado AS Encargado,
	2008 - YEAR(v.ingreso) AS Antigüedad,
	YEAR(vc.fecha) AS Año,
	MONTH(vc.fecha) AS Mes,
	SUM(vc.total) AS Total,
	(SUM(vc.total) * 0.05) + (2008 - YEAR(v.ingreso)) * 500 AS Comisión
FROM
	vencab as vc
	INNER JOIN vendedores AS v
	ON vc.vendedor = v.vendedor
WHERE
	YEAR(vc.fecha) = 2008
	AND vc.anulada = 0
	AND v.encargado = 'S'
GROUP BY
	vc.vendedor,
	v.nombre,
	v.encargado,
	2008 - YEAR(v.ingreso),
	YEAR(vc.fecha),
	MONTH(vc.fecha)
HAVING
	SUM(vc.total) > 5000
--
UNION
-- No encargados
SELECT
	vc.vendedor AS Vendedor,
	v.nombre AS Nombre,
	v.encargado AS Encargado,
	2008 - YEAR(v.ingreso) AS Antigüedad,
	YEAR(vc.fecha) AS Año,
	MONTH(vc.fecha) AS Mes,
	SUM(vc.total) AS Total,
	(SUM(vc.total) * 0.03) + (2008 - YEAR(v.ingreso)) * 300 AS Comisión
FROM
	vencab as vc
	INNER JOIN vendedores AS v
	ON vc.vendedor = v.vendedor
WHERE
	YEAR(vc.fecha) = 2008
	AND vc.anulada = 0
	AND v.encargado = 'N'
GROUP BY
	vc.vendedor,
	v.nombre,
	v.encargado,
	2008 - YEAR(v.ingreso),
	YEAR(vc.fecha),
	MONTH(vc.fecha)
HAVING
	SUM(vc.total) > 5000
ORDER BY Nombre, Mes


/*

ACTIVIDAD 2

*/

CREATE OR ALTER PROCEDURE sp_comisiones_vendedores
	@año int,
	@cenc decimal(9,2),
	@aenc decimal(9,2),
	@cven decimal(9,2),
	@aven decimal(9,2),
	@mven decimal(9,2)
AS
BEGIN TRY
	SET NOCOUNT ON

	BEGIN TRANSACTION

	IF OBJECT_ID('tmp_comisiones_vendedores') IS NOT NULL 
		DROP TABLE tmp_comisiones_vendedores

	SELECT
		vc.vendedor AS Vendedor,
		v.nombre AS Nombre,
		v.encargado AS Encargado,
		@año - YEAR(v.ingreso) AS Antigüedad,
		YEAR(vc.fecha) AS Año,
		MONTH(vc.fecha) AS Mes,
		SUM(vc.total) AS Total,
		CASE v.encargado
			WHEN 'S' THEN (SUM(vc.total) * @cven) + (@año - YEAR(v.ingreso)) * @aven
			WHEN 'N' THEN (SUM(vc.total) * @cven) + (@año - YEAR(v.ingreso)) * @aven
		END AS Comisión
	INTO
		tmp_comisiones_vendedores
	FROM
		vencab as vc
		INNER JOIN vendedores AS v
		ON vc.vendedor = v.vendedor
	WHERE
		YEAR(vc.fecha) = @año
		AND vc.anulada = 0
	GROUP BY
		vc.vendedor,
		v.nombre,
		v.encargado,
		@año - YEAR(v.ingreso),
		YEAR(vc.fecha),
		MONTH(vc.fecha)
	HAVING
		SUM(vc.total) > @mven
	--
	PRINT 'El procedimiento finalizó. Se insertaron ' + TRIM(STR(@@ROWCOUNT)) + ' filas.'
	--
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	--
	PRINT 'Se produjo un error durante la inserción. La tabla no fue actualizada.'
END CATCH

EXEC sp_comisiones_vendedores 2007, 0.05, 500, 0.03, 300, 15000

SELECT * FROM tmp_comisiones_vendedores