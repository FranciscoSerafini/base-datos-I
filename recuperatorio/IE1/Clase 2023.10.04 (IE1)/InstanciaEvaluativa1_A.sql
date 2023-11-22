USE Ventas2

/*

ACTIVIDAD 1

Presente un ranking de los 10 vendedores no encargados que realizaron más cantidad de ventas (facturas) minoristas 
en los años 2004, 2005 y 2006. Muestre el número de vendedor, el nombre y la cantidad de facturas.

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

Determine en una sola consulta qué artículos (mostrando código, nombre e importe) generaron más ventas MAYORISTAS
(en importe) en el año 2006 que el artículo A205221022 en el 2005. 

Excluya las ventas anuladas, y utilice para el cálculo de los totales CANTIDAD * PRECIOREAL.

*/

SELECT
	a.articulo AS "Artículo",
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

Desarrolle una consulta que presente Artículo, Nombre Artículo, Nombre Marca y Total, que muestre 
aquellos artículos pertenecientes a marcas activas (ACTIVO = 'S') que vendieron como mínimo $50.000
durante el año 2006 de forma MINORISTA.

Excluya las ventas anuladas, y tome para el cálculo de los totales CANTIDAD * PRECIO. 

Ordene por código de artículo.

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