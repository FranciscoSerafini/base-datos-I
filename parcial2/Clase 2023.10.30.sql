/*

EJERCICIO 1

Crear el procedimiento almacenado "sp_actualiza_precios_rubro", que solicite tres par�metros: 1) c�digo del rubro, 2) porcentaje de
modificaci�n de preciomenor, y 3) porcentaje de modificaci�n de precio mayor.

El procedimiento deber� validar que el rubro exista, y retornar en un mensaje la cantidad de filas que se actualizaron al finalizar.

Se deber� validar la ocurrencia de errores utilizando TRY / CATCH, y utilizar TRANSACCIONES para volver atr�s los 
cambios en caso de ocurrir alguno.

*/

USE Ventas2

SELECT
	articulo,
	nombre,
	rubro,
	preciomenor,
	preciomayor
INTO
	tmp_articulos
FROM
	articulos

DROP TABLE tmp_articulos

SELECT * FROM tmp_articulos

SELECT * FROM RUBROS

CREATE OR ALTER PROCEDURE sp_actualiza_precios_rubro
	@rubro as int,
	@porcentajemenor AS int,
	@porcentajemayor AS int
AS

SET NOCOUNT ON

DECLARE @filas int

BEGIN TRY
	IF NOT EXISTS (SELECT * FROM tmp_articulos WHERE rubro = @rubro)
		PRINT 'No existen art�culos para el rubro ' + TRIM(STR(@rubro)) + '.'
	ELSE
		BEGIN 
			BEGIN TRANSACTION
			--
			UPDATE tmp_articulos SET 
			preciomenor = preciomenor + (preciomenor * @porcentajemenor / 100),
			preciomayor = preciomayor + (preciomayor * @porcentajemayor / 100)
			WHERE rubro = @rubro
			--	
			SET @filas = @@ROWCOUNT
			--
			COMMIT TRANSACTION
			--
			PRINT 'La actualizacion fue realizada con �xito, se modificaron ' + TRIM(STR(@filas)) + ' filas.'
		END
END TRY

BEGIN CATCH

	ROLLBACK TRANSACTION
	--
	PRINT 'Se produjo un error durante la actualizaci�n. El error es: ' + ERROR_MESSAGE() + '.'

END CATCH

EXEC sp_actualiza_precios_rubro 11, -10, -10

SELECT * FROM tmp_articulos WHERE rubro = 11


RAISERROR ('Error, transacci�n no completada! :-(', 16, -1) 

select * from sys.messages where message_id = 2627 and 


/*

EJERCICIO 2

Cree el procedimiento almacenado "sp_ArticulosSinVentas" que, recibiendo como par�metro un a�o determinado,
cree la tabla TmpArticulosSinVentas. Esta tabla deber� contener los art�culos que no registraron ninguna venta
en el a�o especificado. La estructura de la tabla debe ser: art�culo (c�digo), nombre, marca (nombre), 
rubro (nombre), preciomayor y preciomenor. 

El procedimiento deber� validar la existencia de la tabla y contar con manejo de errores y mensajes con el 
resumen de las filas insertadas.

*/