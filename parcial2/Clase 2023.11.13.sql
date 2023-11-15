/*

Crear el procedimiento almacenado "sp_cantidad_vendida", que presente el total de prendas vendidas (minorista) por sucursal para
un artículo determinado en un rango de fechas específico.

El procedimiento deberá recibir tres parámetros: el artículo (código), fecha desde, fecha hasta; y devolver como resultado
SUCURSAL (denominación) y CANTIDAD VENDIDA, ordenando por sucursal de forma ascendente.

Se deberá validar que la fecha desde sea menor o igual a la fecha hasta, y en caso contrario detener la ejecución y mostrar
el mensaje "El rango de fechas ingresado no es correcto!". Se deberá validar también que el artículo ingresado exista, y en caso 
contrario mostrar "El artículo [código] no existe!.".

*/


CREATE OR ALTER PROCEDURE sp_cantidad_vendida
	@articulo char(10),
	@fechadesde smalldatetime,
	@fechahasta smalldatetime
AS
SET NOCOUNT ON
DECLARE 
	@mensaje char(256)
BEGIN
	IF @fechadesde > @fechahasta
		BEGIN
			SET @mensaje = 'Las fechas ingresadas no son correctas!.'
			GOTO FIN
		END
	--
	IF  NOT EXISTS (SELECT * FROM articulos WHERE articulo = @articulo)
		BEGIN
			SET @mensaje = 'El artículo ' + TRIM(@articulo) + ' no existe!.'
			GOTO FIN
		END
	--
	SELECT
		s.denominacion,
		SUM(vd.cantidad) as Cantidad
	FROM
		vendet as vd 
		INNER JOIN vencab as vc ON vd.letra = vc.letra and vd.factura = vc.factura
		INNER JOIN sucursales as s ON vc.sucursal = s.sucursal
	WHERE
		vc.fecha BETWEEN @fechadesde AND @fechahasta
		and vd.articulo = @articulo
		and vc.anulada = 0
	GROUP BY
		s.denominacion
	ORDER BY
		1
	--
	SET @mensaje = 'El proceso finalizó sin novedades.'
FIN:
	PRINT @mensaje
END

EXEC sp_cantidad_vendida 'A105220291','10/01/2004','12/01/2006'

EXEC sp_cantidad_vendida 'X105220291','10/01/2009','12/01/2009'

SELECT * FROM ARTICULOS

SELECT * FROM ARTICULOS WHERE articulo IN (SELECT DISTINCT articulo FROM vendet)

SELECT * FROM ARTICULOS WHERE articulo IN (SELECT DISTINCT articulo FROM mayordet)


/*

Una vez resuelto lo anterior, deberá modificar el procedimiento para agregarle un nuevo parámetro donde se especifique el tipo
de venta a calcular, y que podrá tener dos valores: 1 - Minorista, 2 - Mayorista. En caso de ingresar otro valor que no sea 1 o 2
deberá detener la ejecución mostrando el mensaje  "El parámetro de tipo de venta debe ser 1 (Minorista) o 2 (Mayorista)!".

Deberá validar además si el artículo tuvo ventas, y en el caso contrario mostrar "El artículo [codigo] no registra ventas 
[minoristas o mayoristas] en el periodo especificado!"

*/



CREATE OR ALTER PROCEDURE sp_cantidad_vendida
	@articulo char(10),
	@fechadesde smalldatetime,
	@fechahasta smalldatetime,
	@tipo int
AS
SET NOCOUNT ON
DECLARE 
	@mensaje char(256)
BEGIN
	IF @fechadesde > @fechahasta
		BEGIN
			SET @mensaje = 'Las fechas ingresadas no son correctas!.'
			GOTO FIN
		END
	--
	IF  NOT EXISTS (SELECT * FROM articulos WHERE articulo = @articulo)
		BEGIN
			SET @mensaje = 'El artículo ' + TRIM(@articulo) + ' no existe!.'
			GOTO FIN
		END
	--
	IF @tipo NOT IN (1,2)
		BEGIN
			SET @mensaje = 'El parámetro de tipo de venta debe ser 1 (Minorista) o 2 (Mayorista)'
			GOTO FIN
		END
	ELSE
		IF @tipo = 1
			BEGIN
				IF EXISTS (	SELECT articulo FROM vendet as vd INNER JOIN vencab as vc ON vd.letra = vc.letra and vd.factura = vc.factura
							WHERE vc.fecha BETWEEN @fechadesde AND @fechahasta and vd.articulo = @articulo and vc.anulada = 0)
					BEGIN
						SELECT
							s.denominacion,
							SUM(vd.cantidad) as Cantidad
						FROM
							vendet as vd 
							INNER JOIN vencab as vc ON vd.letra = vc.letra and vd.factura = vc.factura
							INNER JOIN sucursales as s ON vc.sucursal = s.sucursal
						WHERE
							vc.fecha BETWEEN @fechadesde AND @fechahasta
							and vd.articulo = @articulo
							and vc.anulada = 0
						GROUP BY
							s.denominacion
						--
						SET @mensaje = 'El proceso finalizó sin novedades.'
					END 
				ELSE
					SET @mensaje = 'El artículo ' + TRIM(@articulo) + ' no registra ventas Minoristas en el periodo especificado!.'
			END
		ELSE
			BEGIN
				IF EXISTS ( SELECT articulo FROM mayordet as md INNER JOIN mayorcab as mc ON md.letra = mc.letra and md.factura = mc.factura
							WHERE mc.fecha BETWEEN @fechadesde AND @fechahasta and md.articulo = @articulo and mc.anulada = 0)
					BEGIN
						SELECT
							s.denominacion,
							SUM(md.cantidad) as Cantidad
						FROM
							mayordet as md 
							INNER JOIN mayorcab as mc ON md.letra = mc.letra and md.factura = mc.factura
							INNER JOIN sucursales as s ON mc.sucursal = s.sucursal
						WHERE
							mc.fecha BETWEEN @fechadesde AND @fechahasta
							and md.articulo = @articulo
							and mc.anulada = 0
						GROUP BY
							s.denominacion
						--
						SET @mensaje = 'El proceso finalizó sin novedades.'
					END
				ELSE
					SET @mensaje = 'El artículo ' + TRIM(@articulo) + ' no registra ventas Mayoristas en el periodo especificado!.'
			END
		
FIN:
	PRINT @mensaje
END

EXEC sp_cantidad_vendida 'X105220291','10/01/2004','12/01/2004', 1

SELECT * FROM ARTICULOS

SELECT * FROM ARTICULOS WHERE articulo IN (SELECT DISTINCT articulo FROM vendet)

SELECT * FROM ARTICULOS WHERE articulo IN (SELECT DISTINCT articulo FROM mayordet)