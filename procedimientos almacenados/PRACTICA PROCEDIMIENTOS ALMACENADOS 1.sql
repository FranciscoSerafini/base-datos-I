USE Ventas2
/*

HACER UN PROCEDIMIENTO ALMACENADO QUE PERMITA INSERTAR FILAS EN LA TABLA RUBROS

*/
SELECT * FROM rubros

CREATE OR ALTER PROCEDURE sp_insertar_rubro
	--declaracion de variables para luego pasarle al procedimiento almacenado en su ejecucion
	@rubro int,
	@nombre char(30)
AS
BEGIN
	IF EXISTS(SELECT * FROM rubros WHERE @rubro = rubro)
		PRINT 'EL RUBRO ' + TRIM(STR(@rubro)) + '' + 'QUE QUIERE INGRESAR YA EXISTE'
	ELSE
		BEGIN
			INSERT INTO rubros
				(rubro,nombre)
			VALUES
				(@rubro, @nombre)
			IF @@ERROR <> 0
				PRINT 'HUBO UN PROBLEMA'
			ELSE
				PRINT 'TU RUBRO ' + TRIM(STR(@rubro)) + '' + 'SE INGRESO CORRECTAMENTE'
		END
END

EXEC sp_insertar_rubro 7,Francisco
SELECT * FROM rubros

/*

EJERCICIO DE APLICACIÓN

Desarrolle el SP "sp_ventasanuales", que genera la tabla "tmp_ventasanuales" que contiene el total de ventas minoristas por
artículo. La tabla debe tener las columnas ARTICULO, CANTIDAD, IMPORTE. Tenga en cuenta los siguientes puntos:

	- Se deben excluir ventas anuladas.
	- Se debe tomar para el cálculo del importe CANTIDAD * PRECIO de la tabla VENDET.
	- El procedimiento debe recibir como parámetro de entrada el AÑO, y generar la tabla con las ventas de ese año solamente.
	- Se debe evaluar la existencia de la tabla. Si no existe usar SELECT..INTO, y si existe usar TRUNCATE con INSERT..SELECT.
	- Realizar control de errores, mostrando el mensaje "La tabla fue generada con éxito, se insertaron [n] filas." en caso de
	  éxito, o en caso contrario "Se produjo un error durante la inserción. Contacte con el administrador".

TIP: para evaluar si la tabla existe o no, utilice la función OBJECT_ID([nombre_objeto]), que retorna NULL si un objeto no
existe, o un número entero que identifica al objeto en caso contrario. Ver el ejemplo debajo.

*/

--PROCEDIMIENTO ALMACENADO

CREATE OR ALTER  PROCEDURE sp_ventasanuales
	@FECHA SMALLDATETIME
AS

BEGIN
	IF OBJECT_ID('temp_ventasanuales', 'U') IS NOT NULL --VERIFICAMOS SI LA TABLA EXISTE
		TRUNCATE TABLE temp_ventasanuales; -- SI EXISTE, SE TRUNCA
	ELSE --SI NO, CREAMOS LA TABLA TEMP
		SELECT
		a.articulo AS 'ARTICULO',
		SUM(vt.cantidad) AS 'CANTIDAD',
		SUM(vt.cantidad * vt.precio) AS 'IMPORTE'
	INTO temp_ventasanuales
	FROM
		articulos AS a
		INNER JOIN vendet AS vt ON a.articulo = vt.articulo
		INNER JOIN vencab AS vc ON vt.letra = vc.letra AND vc.factura = vt.factura
	WHERE
		vc.anulada = 0 AND
		YEAR(vc.fecha) = @FECHA
	GROUP BY
		a.articulo 

	--insertamos los datos
	INSERT INTO temp_ventasanuales
		(articulo, cantidad, importe)
		SELECT
		a.articulo AS 'ARTICULO',
		vt.cantidad AS 'CANTIDAD',
		vt.cantidad * vt.precio AS 'IMPORTE'
	FROM
		articulos AS a
		INNER JOIN vendet AS vt ON a.articulo = vt.articulo
		INNER JOIN vencab AS vc ON vt.letra = vc.letra AND vc.factura = vt.factura
	WHERE
		vc.anulada = 0 AND
		YEAR(vc.fecha) = @FECHA
	GROUP BY
		  a.articulo 
	
	IF @@ROWCOUNT > 0 --PREGUNTAMOS SI HAY INSERCIONES
		BEGIN
			PRINT 'SE GENERO LA TABLA CON EXITO Y SE INSERTARON LAS FILAS'
		END
	ELSE
		BEGIN
			PRINT 'SE PRODUJO UN ERROR,CONTACTE CON EL ADMINISTRADOR'
		END
END
select fecha from vencab

EXEC sp_ventasanuales @FECHA = '2004-09-15T00:00:00';
SELECT * FROM temp_ventasanuales

-- ----------------------------------------------------------------------------------------------------------------------
--PRACTICA 30-10
/*

EJERCICIO 2

Cree el procedimiento almacenado "sp_ArticulosSinVentas" que, recibiendo como parámetro un año determinado,
cree la tabla TmpArticulosSinVentas. Esta tabla deberá contener los artículos que no registraron ninguna venta
en el año especificado. La estructura de la tabla debe ser: artículo (código), nombre, marca (nombre), 
rubro (nombre), preciomayor y preciomenor. 

El procedimiento deberá validar la existencia de la tabla y contar con manejo de errores y mensajes con el 
resumen de las filas insertadas.

*/

--recibe parametro
--crear tabla insert into
--validar existencia de la tabla y manejo de errores

select fecha from vencab 
select articulo,cantidad,factura from vendet 
		SELECT 
			a.articulo AS 'Articulo',
			a.nombre AS 'Nombre del Articulo',
			m.nombre AS 'Marca',
			r.nombre AS 'Rubro',
			a.preciomayor AS 'Precio mayor',
			a.preciomenor AS 'Precio menor',
			vc.total AS 'TOTAL VENTAS',
			vc.fecha,
			vc.anulada
		FROM
			articulos AS a INNER JOIN
			marcas AS m ON a.marca = m.marca INNER JOIN
			rubros AS r ON a.rubro = r.rubro INNER JOIN
			vendet AS vt ON a.articulo = vt.articulo INNER JOIN 
			vencab AS vc ON vc.letra = vt.letra AND vc.factura = vt.factura
		WHERE
			YEAR(vc.fecha) = 2006 AND
			vc.anulada = 0 AND
			vc.total = 0
			
		
			


CREATE OR ALTER PROCEDURE sp_ArticulosSinVentas
	@año int
AS

SET NOCOUNT ON

DECLARE @filas int 

BEGIN TRY
	BEGIN TRANSACTION
		IF OBJECT_ID('TempArticulosSinVentas') IS NOT NULL
			TRUNCATE TABLE TempArticulosSinVentas;
		ELSE
			SELECT 
				a.articulo AS 'Articulo',
				a.nombre AS 'Nombre del Articulo',
				m.nombre AS 'Marca',
				r.nombre AS 'Rubro',
				a.preciomayor AS 'Precio mayor',
				a.preciomenor AS 'Precio menor'
			INTO
				TempArticulosSinVentas
			FROM
				articulos AS a INNER JOIN
				marcas AS m ON a.marca = m.marca INNER JOIN
				rubros AS r ON a.rubro = r.rubro INNER JOIN
				vendet AS vt ON a.articulo = vt.articulo INNER JOIN 
				vencab AS vc ON vc.letra = vt.letra AND vc.factura = vt.factura
			WHERE
				YEAR(vc.fecha) = @año AND
				vc.anulada = 0 AND
				vc.total = 0
			--
			SET @filas = @@ROWCOUNT
			--
			COMMIT TRANSACTION
			--
			PRINT 'Se registraron ' + TRIM(STR(@filas)) + ' filas'
END TRY		

BEGIN CATCH
	ROLLBACK TRANSACTION
	PRINT 'Se produjo un error. El error es: ' + ERROR_MESSAGE() + '.'
END CATCH
EXEC sp_ArticulosSinVentas 2009
SELECT * FROM TempArticulosSinVentas
