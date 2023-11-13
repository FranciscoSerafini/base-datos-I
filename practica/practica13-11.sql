/*

Crear el procedimiento almacenado "sp_cantidad_vendida", que presente el total de prendas vendidas (minorista) por sucursal para
un artículo determinado en un rango de fechas específico.

El procedimiento deberá recibir tres parámetros: el artículo (código), fecha desde, fecha hasta; y devolver como resultado
SUCURSAL (denominación) y CANTIDAD VENDIDA, ordenando por sucursal de forma ascendente.

Se deberá validar que la fecha desde sea menor o igual a la fecha hasta, y en caso contrario detener la ejecución y mostrar
el mensaje "El rango de fechas ingresado no es correcto!". Se deberá validar también que el artículo ingresado exista, y en caso 
contrario mostrar "El artículo [código] no existe!.".


vencab, vendet y sucursales -> tablas
*/
use Ventas2

SELECT * FROM vencab
SELECT * FROM vendet
SELECT * FROM sucursales

SELECT articulo FROM vendet WHERE articulo = @articulo

SELECT
	s.denominacion AS 'Nombre sucursal',
	SUM(vt.cantidad) AS 'prendas vendidas'
FROM
	vendet AS vt INNER JOIN
	vencab AS vc ON vc.letra = vt.letra AND vc.factura = vt.factura INNER JOIN
	sucursales AS s ON s.sucursal = vc.sucursal
WHERE
	vc.fecha BETWEEN '01/01/2005' AND '31/12/2005' AND
	VC.anulada = 0
GROUP BY
	s.denominacion
ORDER BY
	s.denominacion ASC


CREATE OR ALTER PROCEDURE sp_cantidad_vendida
	@articulo char(10),
	@desde smalldatetime,
	@hasta smalldatetime
AS
	BEGIN TRY
		IF @desde > @hasta
			PRINT 'LAS FECHAS ESTAN MAL'
		ELSE
			IF EXISTS ( SELECT * FROM articulos WHERE @articulo = articulo )
				BEGIN
					SELECT
						s.denominacion AS 'Nombre sucursal',
						SUM(vt.cantidad) AS 'prendas vendidas'
					--INTO
						--temp_cantidad_vendidas
					FROM
						vendet AS vt INNER JOIN
						vencab AS vc ON vc.letra = vt.letra AND vc.factura = vt.factura INNER JOIN
						sucursales AS s ON s.sucursal = vc.sucursal
					WHERE
						vc.fecha BETWEEN @desde AND @hasta AND
						vc.anulada = 0
					GROUP BY
						s.denominacion
					ORDER BY
						s.denominacion ASC
					
					PRINT 'SE GENERA BIEN'
				END
	END TRY
	BEGIN CATCH
		PRINT 'ERROR EN LAS FECHAS'
	END CATCH

EXEC sp_cantidad_vendida 'A204220137','2005/01/01','2005/12/31'

--falta hacer la autenticacion del articulo


/*

Una vez resuelto lo anterior, deberá modificar el procedimiento para agregarle un nuevo parámetro donde se especifique el tipo
de venta a calcular, y que podrá tener dos valores: 1 - Minorista, 2 - Mayorista. En caso de ingresar otro valor que no sea 1 o 2
deberá detener la ejecución mostrando el mensaje  "El parámetro de tipo de venta debe ser 1 (Minorista) o 2 (Mayorista)!".

Deberá validar además si el artículo tuvo ventas, y en el caso contrario mostrar "El artículo [codigo] no registra ventas 
[minoristas o mayoristas] en el periodo especificado!"

*/