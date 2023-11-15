/*

EJERCICIO 1

Implemente un SP llamado sp_inserta_sucursal que permita insertar nuevas sucursales en la tabla correspondiente. 
El procedimiento deberá solicitar como parámetros de entrada el CODIGO (sucursal), la DENOMINACIÓN y la DIRECCIÓN.

Tener en cuenta:
	- Utilizar transacciones.
	- Validar errores mediante TRY / CATCH
	- Validar si la sucursal existe antes de crearla.

*/

CREATE OR ALTER PROCEDURE sp_inserta_sucursal
	@suc int,
	@den char(40),
	@dir char(50)
AS

BEGIN TRY
	BEGIN TRANSACTION
	--
	INSERT INTO sucursales
		(sucursal,denominacion,direccion,activa) 
	VALUES 
		(@suc,UPPER(@den),UPPER(@dir),'N')
	--
	COMMIT TRANSACTION
	--
	PRINT 'La sucursal ' + TRIM(@den) + ' se insertó correctamente.'
END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION
	--
	IF ERROR_NUMBER() = 2627
		PRINT 'La sucursal ' + TRIM(STR(@suc)) + ' ya existe en la tabla.'
	ELSE
		PRINT 'Se produjo un error durante la inserción de la sucursal.'
END CATCH

-- EJECUCIÓN
EXEC sp_inserta_sucursal 1001, 'ALTA GRACIA', 'belgrano 228'

SELECT * FROM sucursales

/*

EJERCICIO 2

Crear el procedimiento almacenado sp_ventas_periodo, que muestre un resumen de la cantidad y el importe
total vendido por cada vendedor en un periodo de tiempo establecido entre 2 fechas.

El procedimiento debe generar la tabla tmp_ventas_periodo, con las columnas:
- Vendedor (Id)
- Nombre
- Cantidad de Ventas
- Importe Total

Se debe validar la existencia de la tabla, y que la fecha_desde sea menor o igual a la fecha_hasta.

*/

CREATE OR ALTER PROCEDURE sp_ventas_periodo
	@fdesde smalldatetime,
	@fhasta smalldatetime
AS

BEGIN TRY
	IF @fdesde > @fhasta
		PRINT 'Error en los parámetros de entrada: La fecha desde debe ser menor o igual a la fecha hasta.'
	ELSE
		IF OBJECT_ID('tmp_ventas_periodo') IS NOT NULL DROP TABLE tmp_ventas_periodo
		--
		SELECT
			v.vendedor AS "Vendedor",
			v.nombre AS "Nombre",
			COUNT(*) AS "Cantidad de Ventas",
			SUM(vc.total) AS "Importe Total"
		INTO
			tmp_ventas_periodo
		FROM
			vencab AS vc
			INNER JOIN vendedores AS v ON vc.vendedor = v.vendedor
		WHERE
			vc.anulada = 0
			AND vc.fecha BETWEEN @fdesde AND @fhasta
		GROUP BY
			v.vendedor,
			v.nombre
		--
		PRINT 'El procedimiento finalizó correctamente. Se insertaron ' + TRIM(STR(@@ROWCOUNT)) + ' filas.'
END TRY

BEGIN CATCH
	PRINT 'El procedimiento finalizó con errores.'
END CATCH

EXEC sp_ventas_periodo '01/01/2006', '15/01/2005'

SELECT * FROM tmp_ventas_periodo