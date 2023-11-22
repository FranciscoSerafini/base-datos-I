/*

ACTIVIDAD 1

Presente un ranking de los 10 vendedores no encargados que realizaron m�s cantidad de ventas (facturas) minoristas 
en los a�os 2004, 2005 y 2006. Muestre el n�mero de vendedor, el nombre y la cantidad de facturas.

Excluya las ventas anuladas, y presente el ranking ordenado de forma decreciente por la cantidad de facturas.

*/
use Ventas2

SELECT TOP 10
	V.vendedor,
	V.nombre,
	COUNT(VC.factura) AS CANTIDAD
FROM
	vendedores AS v INNER JOIN
	vencab AS vc ON v.vendedor = vc.vendedor 
WHERE
	YEAR(vc.fecha) IN (2004,2005,2006) AND
	vc.anulada = 0 AND
	V.encargado = 'S'
GROUP BY
	v.vendedor,
	v.nombre
ORDER BY
	3 DESC,1

	/*

ACTIVIDAD 2

Determine en una sola consulta qu� art�culos (mostrando c�digo, nombre e importe) generaron m�s ventas MAYORISTAS
(en importe) en el a�o 2006 que el art�culo A205221022 en el 2005. 

Excluya las ventas anuladas, y utilice para el c�lculo de los totales CANTIDAD * PRECIOREAL.

*/

--primero realizamos la subconsulta

SELECT
	SUM(my.cantidad * my.precioreal)
FROM
	mayordet AS my INNER JOIN
	mayorcab AS mc ON mc.letra = my.letra AND mc.factura = my.factura
WHERE
	my.articulo = 'A205221022' and
	mc.anulada = 0 and
	YEAR(mc.fecha) = 2005

SELECT
	a.articulo,
	a.nombre,
	SUM(my.cantidad * my.precioreal)
FROM
	articulos AS a INNER JOIN
	mayordet AS my ON my.articulo = a.articulo INNER JOIN
	mayorcab AS mc ON mc.letra = my.letra AND mc.factura = my.factura
WHERE
	mc.anulada = 0 and
	YEAR(mc.fecha) = 2006 
GROUP BY
	a.articulo,
	a.nombre
HAVING 
	SUM(my.cantidad * my.precioreal) > (SELECT
												SUM(my.cantidad * my.precioreal)
											FROM
												mayordet AS my INNER JOIN
												mayorcab AS mc ON mc.letra = my.letra AND mc.factura = my.factura
											WHERE
												my.articulo = 'A205221022' and
												mc.anulada = 0 and
												YEAR(mc.fecha) = 2005)

/*

ACTIVIDAD 3

Desarrolle una consulta que presente Art�culo, Nombre Art�culo, Nombre Marca y Total, que muestre 
aquellos art�culos pertenecientes a marcas activas (ACTIVO = 'S') que vendieron como m�nimo $50.000
durante el a�o 2006 de forma MINORISTA.

Excluya las ventas anuladas, y tome para el c�lculo de los totales CANTIDAD * PRECIO. 

Ordene por c�digo de art�culo.

*/
SELECT
	a.articulo,
	a.nombre,
	m.nombre,
	SUM(vt.cantidad * vt.precio)
FROM
	articulos AS a INNER JOIN
	marcas AS m ON a.marca = m.marca INNER JOIN
	vendet AS vt ON vt.articulo = a.articulo INNER JOIN
	vencab AS vc ON vc.letra = vt.letra AND vt.factura = vc.factura
WHERE
	vc.anulada = 0 AND
	m.activo = 'S' AND
	YEAR(vc.fecha) = 2006
GROUP BY
	a.articulo,
	a.nombre,
	m.nombre
HAVING
		SUM(vt.cantidad * vt.precio) > 50000
ORDER BY
	1
/*

ACTIVIDAD 1

Realice una consulta donde se calculen las comisiones que le corresponden a cada vendedor para cada mes del a�o 2008, de acuerdo con sus ventas, 
su antig�edad y su categor�a (encargado o no encargado). 

El criterio de c�lculo de las comisiones es el siguiente: 
�	Si el vendedor es encargado, la comisi�n mensual es del 0.05, y se le pagan $500 adicionales por cada a�o de antig�edad.
�	Si el vendedor NO es encargado, la comisi�n mensual es de 0.03 y se le pagan $300 adicionales por cada a�o de antig�edad.
�	Solamente se deben pagar comisiones si el vendedor super� los $5000 en ventas por mes.

El resultado debe mostrar el c�digo del vendedor, el nombre, si es o no encargado, la antig�edad que ten�a en el 2008, el a�o, el mes, el importe total 
de ventas y la comisi�n a cobrar. Ordene por nombre del vendedor, y mes. Excluya ventas anuladas.

*/

SELECT
	v.vendedor,
	v.nombre,
	v.encargado,
	2008 - YEAR(v.ingreso) AS antiguedad,
	YEAR(vc.fecha) a�o,
	MONTH(vc.fecha) mes,
	SUM(vc.total) Total,
	(SUM(vc.total) * 0.05) + (2008 - YEAR(v.ingreso)) * 500 AS comision
FROM
	vendedores AS v INNER JOIN
	vencab AS vc  ON vc.vendedor = v.vendedor
WHERE
	vc.anulada = 0 AND
	YEAR(vc.fecha) = 2008 AND
	v.encargado = 'S'
GROUP BY 
	v.vendedor,
	v.nombre,
	v.encargado,
	2008 - YEAR(v.ingreso),
	YEAR(vc.fecha),
	MONTH(vc.fecha)
HAVING
	SUM(vc.total) > 5000
--
UNION
--
SELECT
	v.vendedor,
	v.nombre,
	v.encargado,
	2008 - YEAR(v.ingreso) AS antiguedad,
	YEAR(vc.fecha) a�o,
	MONTH(vc.fecha) mes,
	SUM(vc.total) Total,
	(SUM(vc.total) * 0.03) + (2008 - YEAR(v.ingreso)) * 300 AS comision
FROM
	vendedores AS v INNER JOIN
	vencab AS vc  ON vc.vendedor = v.vendedor
WHERE
	vc.anulada = 0 AND
	YEAR(vc.fecha) = 2008 AND
	v.encargado = 'N'
GROUP BY 
	v.vendedor,
	v.nombre,
	v.encargado,
	2008 - YEAR(v.ingreso),
	YEAR(vc.fecha),
	MONTH(vc.fecha)
HAVING
	SUM(vc.total) > 5000
ORDER BY
	2 ASC
-- parcial 2
/*

ACTIVIDAD 1

Determine mediante una consulta que retorne una sola fila cu�l fue el A�O y MES en el cual se generaron 
mas cantidad de facturas por venta MAYORISTA.

Excluya las ventas anuladas, y presente solamente el mes correspondiente, mostrando a�o, mes y cantidad de facturas.

*/

SELECT TOP 1 
	YEAR(my.fecha),
	MONTH(my.fecha),
	COUNT(*)
FROM
	mayorcab AS my
WHERE
	my.anulada = 0
GROUP BY
	YEAR(FECHA),
	MONTH(FECHA)
	--COUNT(VT.CANTIDAD)
ORDER BY
	3 DESC

/*

ACTIVIDAD 2

Desarrolle una consulta que presente Art�culo, Nombre Art�culo, Nombre Marca, Total, que muestre 
aquellos art�culos pertenecientes a marcas activas (ACTIVO = 'S') que vendieron como m�nimo $50.000
durante a�o 2006 de forma MINORISTA.

Excluya siempre las ventas anuladas, y tome para el c�lculo de los totales CANTIDAD * PRECIO.

Ordene por c�digo de art�culo.

*/

SELECT
	a.articulo,
	a.nombre,
	m.nombre,
	SUM(vt.cantidad * vt.precio) AS total
FROM
	articulos AS a INNER JOIN
	marcas AS m ON m.marca = a.marca INNER JOIN
	vendet AS vt ON vt.articulo = a.articulo INNER JOIN
	vencab AS vc ON vc.factura = vt.factura AND vc.letra = vt.letra
WHERE
	vc.anulada = 0 AND
	m.activo = 'S' AND
	YEAR(vc.fecha) = 2006
GROUP BY
	a.articulo,
	a.nombre,
	m.nombre
HAVING
	SUM(vt.cantidad * vt.precio) > 50000

/*

ACTIVIDAD 3

La empresa decidi� pagar un premio equivalente al 3% de las ventas generadas en el a�o 2008 por los vendedores que
no son encargados (ENCARGADO = 'N'), est�n activos (ACTIVO = 'S'), y superaron los $100.000 en ventas en el a�o.
Adem�s, debe cumplir la condici�n de haber tenido una antig�edad en el a�o 2008 de al menos 3 a�os para recibir 
el premio. Para calcular la antig�edad deber� tomar el a�o de la fecha de ingreso.

Liste el nombre del vendedor, su antig�edad, el total vendido en el 2008, y el valor del premio a pagar. Ordene por
vendedor y excluya ventas anuladas.

*/
SELECT
	v.nombre,
	2008 - YEAR(v.ingreso) AS antiguedad,
	SUM(vc.total) AS total,
	SUM(vc.total) * 0,03 AS comision
FROM
	vendedores AS v INNER JOIN
	vencab AS vc ON v.vendedor = vc.vendedor
WHERE
	2008 - YEAR(v.ingreso) >= 3 AND
	vc.anulada = 0 AND
	v.encargado = 'N' AND
	v.activo = 'S' AND
	YEAR(vc.fecha) = 2008
GROUP BY
	v.nombre,
	2008 - YEAR(v.ingreso)
HAVING
	SUM(vc.total) > 100000

/*

ACTIVIDAD 1
ctividad 1: Consulta SQL (50 puntos)

Desarrolle una consulta que permita obtener la categorizaci�n de los clientes (A, B, C) de acuerdo a su volumen de ventas mayoristas acumuladas.
La consulta deber� retornar las siguientes columnas: Cliente, Nombre, Ventas Acumuladas (importe total) y Categor�a, el resultado deber� estar 
ordenado por Categor�a y Nombre.

La clasificaci�n deber� realizarse de acuerdo con el siguiente criterio:
�	La columna Categor�a debe mostrar el valor �A� para aquellos clientes que superaron con sus ventas acumuladas los 100000.
�	El valor �B� para los que tuvieron ventas acumuladas comprendidas entre los valores 100000 y 50000 (incluidos), y �C� para los clientes 
	con ventas acumuladas mayores a 0 (cero) y menores a 50000, excluyendo al resto.
�	No debe tener en cuenta las ventas anuladas.

*/

SELECT
	c.cliente,
	c.nombre,
	SUM(mc.total) TOTAL,
	'A' AS CATEGORIA
FROM
	clientes AS c INNER JOIN
	mayorcab AS mc ON c.cliente = mc.cliente
WHERE
	mc.anulada = 0
GROUP BY
	c.cliente,
	c.nombre
HAVING 
	SUM(mc.total) > 100000
--
UNION
--
--CLASE B
SELECT
	c.cliente,
	c.nombre,
	SUM(mc.total) TOTAL,
	'B' AS CATEGORIA
FROM
	clientes AS c INNER JOIN
	mayorcab AS mc ON c.cliente = mc.cliente
WHERE
	mc.anulada = 0
GROUP BY
	c.cliente,
	c.nombre
HAVING 
	SUM(mc.total)  BETWEEN 50000 AND  100000
--
UNION
--
--CLASE C
SELECT
	c.cliente,
	c.nombre,
	SUM(mc.total) TOTAL,
	'C' AS CATEGORIA
FROM
	clientes AS c INNER JOIN
	mayorcab AS mc ON c.cliente = mc.cliente
WHERE
	mc.anulada = 0
GROUP BY
	c.cliente,
	c.nombre
HAVING 
	SUM(mc.total)  BETWEEN 0 AND  50000
ORDER BY
	3,1 DESC


	/*

Actividad 2: Procedimiento Almacenado (50 puntos)

Tomando como base la consulta anterior, implemente un procedimiento almacenado que se denomine sp_categorias_clientes, que reciba 
como par�metros los valores marcados en rojo en el enunciado anterior, que se llamaran RangoA y RangoB. Deber� validar que 
RangoA sea mayor a RangoB.

El procedimiento deber� generar generar la tabla tmp_categorias_clientes con las filas retornadas del resultado, mostrando 
el mensaje �El procedimiento finaliz� correctamente. Se insertaron [..] filas.� en caso de funcionamiento correcto, o 
�Se produjo un error durante la inserci�n. La tabla no fue actualizada.� en caso contrario.

Ejemplo de ejecuci�n:

EXEC sp_categorias_clientes 100000, 50000

*/
CREATE OR ALTER PROCEDURE sp_categorias_clientes
	@rangoA AS int,
	@rangoB AS int
AS
SET NOCOUNT ON

BEGIN TRY
	BEGIN TRANSACTION
		IF @rangoA < @rangoB --validamos
			--GOTO FIN
		IF OBJECT_ID('temp_categorias_clientes')IS NOT NULL --preguntamos si existe la tabla
			DROP TABLE temp_categorias_clientes

		--creamos tabla
		CREATE TABLE temp_categorias_clientes(
			"cliente" char(100),
			"Ventas"  decimal(9,2),
			"categoria cliente" char(1))
		--insercion de datos
		INSERT INTO temp_categorias_clientes
		SELECT c.nombre,SUM(mc.total) TOTAL,'A' AS CATEGORIA FROM clientes AS c INNER JOIN mayorcab AS mc ON c.cliente = mc.cliente WHERE
		mc.anulada = 0 GROUP BY c.nombre HAVING SUM(mc.total) > @rangoA
		UNION
		SELECT	c.nombre,SUM(mc.total) TOTAL,'B' AS CATEGORIA FROM clientes AS c INNER JOIN mayorcab AS mc ON c.cliente = mc.cliente WHERE 
		mc.anulada = 0 GROUP BY  c.nombre HAVING SUM(mc.total)  BETWEEN @rangoB AND  @rangoA
		UNION
		SELECT c.nombre,SUM(mc.total) TOTAL,'C' AS CATEGORIA FROM clientes AS c INNER JOIN mayorcab AS mc ON c.cliente = mc.cliente WHERE
		mc.anulada = 0 GROUP BY  c.nombre HAVING  SUM(mc.total)  BETWEEN @rangoB AND  @rangoA ORDER BY 3,1 DESC


		PRINT 'El procedimiento finaliz�. Se insertaron ' + TRIM(STR(@@ROWCOUNT)) + ' filas.'

		COMMIT TRANSACTION
END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION
	PRINT 'Ocurri� un error durante la ejecuci�n del procedimiento.'
END CATCH




EXEC sp_categorias_clientes 100000, 50000

SELECT * FROM tmp_categorias_clientes

DROP TABLE tmp_categorias_clientes	

			






