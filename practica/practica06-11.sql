/*

Implemente un SP llamado sp_inserta_sucursal que permita insertar nuevas sucursales en la tabla correspondiente. 
El procedimiento deberá solicitar como parámetros de entrada el CODIGO (sucursal), la DENOMINACIÓN y la DIRECCIÓN.

Tener en cuenta:
	- Utilizar transacciones.
	- Validar errores mediante TRY / CATCH
	- Validar si la sucursal existe antes de crearla.

*/
USE Ventas2

Select * from sucursales

CREATE OR ALTER PROCEDURE sp_insertar_sucursal
	--declaracion de varaibles
	@sucursal INT,
	@denominacion CHAR(40),
	@direccion CHAR (50)
AS
BEGIN TRY
	IF EXISTS( SELECT * FROM sucursales WHERE sucursal = @sucursal)
		PRINT 'EL CODIGO QUE QUERES INGRESAR YA EXISTE'
	ELSE
		BEGIN
			BEGIN TRANSACTION
				INSERT INTO sucursales
					(sucursal,denominacion,direccion,Activa)
				VALUES
					(@sucursal,@denominacion,@direccion,'N')
				COMMIT TRANSACTION
				PRINT 'SE INGRESO PERFECTO'
		END
END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION
		PRINT 'ERROR'
END CATCH

EXEC sp_insertar_sucursal 1,'ITUZAINGO', 'ITUZAINGO 179-CORDOBA'

--Msg 3903, Level 16, State 1, Procedure sp_insertar_sucursal, Line 21 [Batch Start Line 39]
--La solicitud ROLLBACK TRANSACTION no tiene la correspondiente BEGIN TRANSACTION
--FALTAN LOS BEGIN EN LOS BLOQUES DE CODIGOS
--ERROR 2627 -> ES PORQUE LA CLAVE YA EXISTE

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

--resolvemos el select
--usar vendet y tabla vendedores

select * from vendedores

select * from vendet

select * from vencab

SELECT 
	v.vendedor AS 'CODIGO VENDEDOR',
	v.nombre AS 'NOMBRE',
	COUNT(vc.total) AS 'CANTIDAD',
	SUM(vc.total) AS 'IMPORTE TOTAL'
FROM
	vendedores AS v INNER JOIN
	vencab AS vc ON v.vendedor = vc.vendedor
WHERE
	VC.anulada = 0 AND
	vc.fecha BETWEEN @fecha1 AND @fecha2
GROUP BY
	v.vendedor,
	v.nombre


CREATE OR ALTER PROCEDURE sp_ventas_periodo
	--declaracion de variables
	@fecha1 SMALLDATETIME,
	@fecha2 SMALLDATETIME
AS
IF OBJECT_ID('temp_ventasanuales') IS NOT NULL 
		TRUNCATE TABLE temp_ventas_periodo; 
	ELSE
		BEGIN
			SELECT 
				v.vendedor AS 'CODIGO VENDEDOR',
				v.nombre AS 'NOMBRE',
				COUNT(vc.total) AS 'CANTIDAD', --probar con * entre parentesis
				SUM(vc.total) AS 'IMPORTE TOTAL'
			 INTO
				temp_ventas_periodo
			FROM
				vendedores AS v INNER JOIN
				vencab AS vc ON v.vendedor = vc.vendedor
			WHERE
				VC.anulada = 0 AND
				vc.fecha BETWEEN @fecha1 AND @fecha2
			GROUP BY
				v.vendedor,
				v.nombre

--terminar el ejercicio
--faltan controles de errores
		
			
	
