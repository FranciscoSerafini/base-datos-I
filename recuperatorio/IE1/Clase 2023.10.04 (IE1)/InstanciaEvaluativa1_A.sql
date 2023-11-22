USE Ventas2

/*

ACTIVIDAD 1

Presente un ranking de los 10 vendedores no encargados que realizaron m�s cantidad de ventas (facturas) minoristas 
en los a�os 2004, 2005 y 2006. Muestre el n�mero de vendedor, el nombre y la cantidad de facturas.

Excluya las ventas anuladas, y presente el ranking ordenado de forma decreciente por la cantidad de facturas.

*/

SELECT TOP 10
	v.vendedor AS "Vendedor",
	v.nombre AS "Nombre",
	COUNT(*) AS "Cantidad Ventas"
FROM
	vencab AS vc
	INNER JOIN vendedores AS v ON vc.vendedor = v.vendedor
WHERE
	vc.anulada = 0
	AND YEAR(vc.fecha) IN (2004,2005,2006)
	AND v.encargado = 'N'
GROUP BY
	v.vendedor,
	v.nombre
ORDER BY
	3 DESC, 1

/*

ACTIVIDAD 2

Determine en una sola consulta qu� art�culos (mostrando c�digo, nombre e importe) generaron m�s ventas MAYORISTAS
(en importe) en el a�o 2006 que el art�culo A205221022 en el 2005. 

Excluya las ventas anuladas, y utilice para el c�lculo de los totales CANTIDAD * PRECIOREAL.

*/

SELECT
	a.articulo AS "Art�culo",
	a.nombre AS "Nombre",
	SUM(md.cantidad * md.precioreal) AS "Total"
FROM 
	articulos as a
	INNER JOIN mayordet as md ON md.articulo = a.articulo
	INNER JOIN mayorcab as mc ON (md.letra = mc.letra AND md.factura = mc.factura)
WHERE 
	YEAR(mc.fecha) = 2006 
	AND mc.anulada = 0
GROUP BY
	a.articulo,
	a.nombre
HAVING
	SUM(md.cantidad * md.precioreal) > (SELECT 
											SUM(md.cantidad * md.precioreal)
										FROM 
											mayordet as md 
											INNER JOIN mayorcab as mc 
											ON (md.letra = mc.letra AND md.factura = mc.factura)
										WHERE 
											YEAR(mc.fecha) = 2005 
											AND md.articulo = 'A205221022' 
											AND mc.anulada = 0)

/*

ACTIVIDAD 3

Desarrolle una consulta que presente Art�culo, Nombre Art�culo, Nombre Marca y Total, que muestre 
aquellos art�culos pertenecientes a marcas activas (ACTIVO = 'S') que vendieron como m�nimo $50.000
durante el a�o 2006 de forma MINORISTA.

Excluya las ventas anuladas, y tome para el c�lculo de los totales CANTIDAD * PRECIO. 

Ordene por c�digo de art�culo.

*/

SELECT
	a.articulo as Articulo,
	a.nombre as Nombre,
	m.nombre as Marca,
	sum(vd.cantidad * vd.precio) as Total
from
	vencab as vc
	inner join vendet as vd
	on vc.letra = vd.letra and vc.factura = vd.factura
	inner join articulos as a
	on vd.articulo = a.articulo
	inner join marcas as m
	on a.marca = m.marca
where
	year(vc.fecha) = 2006
	and vc.anulada = 0
	and m.activo = 'S'
group by
	a.articulo,
	a.nombre,
	m.nombre
having
	sum(vd.cantidad * vd.precio) >= 50000
order by
	1