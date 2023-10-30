USE Ventas2
Select * FROM vencab
/*
EJERCICIO 1

Crear el procedimiento almacenado sp_actualiza_precios_rubro, que solicite tres parámetros 1) código del rubro, 2) porcentaje de
modificación de preciomenor, y 3) porcentaje de modificación de precio mayor.

El procedimiento deberá validar que el rubro exista, y retornar en un mensaje la cantidad de filas que se actualizaron al finalizar.

Se deberá validar la ocurrencia de errores utilizando TRY  CATCH, y utilizar TRANSACCIONES para volver atrás los 
cambios en caso de ocurrir alguno.

*/
	
SELECT * INTO temp_articulos FROM articulos

SELECT * INTO temp_preciosactualizados FROM articulos

SELECT * from temp_preciosactualizados

CREATE OR ALTER PROCEDURE sp_actualiza_precios_rubro
	@C int,
	@Pmen int,
	@Pmay int
AS
BEGIN TRANSACTION 
	BEGIN TRY 
		UPDATE temp_preciosactualizados	
		SET  preciomenor = preciomenor * @Pmen, preciomayor = preciomayor * @Pmay
		WHERE rubro = @C
		PRINT 'Los precios de '+ TRIM(STR(@@rowcount))+ ' filas se actualizaron correctamente'
		commit transaction

	END TRY
	BEGIN CATCH
		IF NOT EXISTS (SELECT rubro FROM rubros WHERE rubro = @C)
		PRINT 'Codigo de rubro no existe'
		ROLLBACK TRANSACTION
	END CATCH
EXEC sp_actualiza_precios_rubro 10,3,4		