--clase 25/10
--procedimientos almacenados: 
	--dos objetivos -> como resolverlo y el objetivo de negocio.

--Resolucion ejercicio de aplicacion -> clase 23/10


--1) resolvemos el select
--2)creamos la tabla temporal
--3) verificamos si la tabla existe
--4) insercion de datos
DROP TABLE temp_ventasanuales

CREATE OR ALTER  PROCEDURE sp_ventasanuales
	@a int 
AS
BEGIN
	DECLARE @r int
	IF OBJECT_ID('temp_ventasanuales') IS NULL
		BEGIN
			SELECT
				vd.articulo AS 'Articulo',
				SUM(vd.cantidad) AS 'Cantidad',
				SUM(vd.cantidad * vd.precio) AS 'Importe'
			INTO
				temp_ventasanuales
			FROM
				vencab AS vc
				INNER JOIN vendet AS vd ON vd.letra = vc.letra AND vd.factura = vc.factura
			WHERE
				 vc.anulada = 0 AND
				 YEAR(vc.fecha) = @a
			GROUP BY
				vd.articulo 

			SET @r = @@ROWCOUNT
		END
	ELSE
		BEGIN
			TRUNCATE TABLE temp_ventasanuales

			--insercion de datos
			INSERT INTO temp_ventasanuales
			SELECT
				vd.articulo AS 'Articulo',
				SUM(vd.cantidad) AS 'Cantidad',
				SUM(vd.cantidad * vd.precio) AS 'Importe'
			FROM
				vencab AS vc
				INNER JOIN vendet AS vd ON vd.letra = vc.letra AND vd.factura = vc.factura
			WHERE
				 vc.anulada = 0 AND
				 YEAR(vc.fecha) = @a
			GROUP BY
				vd.articulo

			SET @r = @@ROWCOUNT
		END
		IF @@ROWCOUNT <> 0
			PRINT 'SE PRODUJO UN ERROR DURANTE LA INSERCION'
		ELSE
			PRINT 'LA TABLA FUE GENERADA CON EXITO, SE INSERTARON' +	TRIM(STR(@r)) +'FILAS' 
	
END

EXEC sp_ventasanuales 2003
SELECT * FROM temp_ventasanuales

--ALTERNATIVA 2
--CLASE 25/10 --> CONTROL DE ERRORES

--SET NOCOUNT LO UTILIZAMOS PARA NO MOSTRAR EL MENSAJE POR DEFECTO CUANDO EJECUTAMOS UNA INSTRUCCION
	--DEBEMOS PONERLO EN ON ->> SET NOCOUNT ON

--FUNCIONALIDADES EN @@ERROR--> ES UN FUNCION GLOBAL
	--(INT) ERROR_NUMBER()
	--(CHAR) ERROR-MESSAGE

--USAREMOS EL TRY AND CATCH
	--BEGIN TRY

	--END TRY

	--BEGIN CATCH

	--END CATCH

/*

Construir el SP que permita insertar una nueva marca, solicitando como parámetros los tres valores, y que devuelva el mensaje
'La marca [nombre] se insertó correctamente', pero si no presentar el mensaje 'Hubo un problema! No se pudo insertar la marca.'
Si la marca ya existe, mostrar el mensaje 'La marca [marca] ya existe'.

*/

CREATE OR ALTER PROCEDURE sp_insertar_marca
	@marca char(1), 
	@nombre char(30),
	@activo char(1)
AS
BEGIN TRY
	DECLARE @error INT

	INSERT INTO marcas
	(marca, nombre, activo)
	VALUES
	(@marca,@nombre,@activo)

PRINT 'La marca ' + TRIM(@nombre) + ' se insertó correctamente.'

END TRY
BEGIN CATCH
	SET @error = @@ERROR

	IF @error <> 0
		IF @error = 2627
			PRINT 'La marca ' + TRIM(@marca) + ' ya existe.'
		ELSE
			PRINT 'Hubo un problema! No se pudo insertar la marca.'
END CATCH

EXEC sp_insertar_marca 'X','FRANCISCO','S'
SELECT * FROM marcas
-- MIGRAR EL PROCEDIMIENTO sp_insertar_marca A UNA NUEVA VERSION UTILIZANDO TRY / CATCH