USE Ventas2

/*

ACTIVIDAD 1

Determine mediante una consulta que retorne una sola fila cuál fue el AÑO y MES en el cual se generaron 
mas cantidad de facturas por venta MAYORISTA.

Excluya las ventas anuladas, y presente solamente el mes correspondiente, mostrando año, mes y cantidad de facturas.

*/

SELECT TOP 1
	YEAR(mc.fecha) AS "Año",
	MONTH(mc.fecha) AS "Mes",
	COUNT(*) AS "Ventas"
FROM
	mayorcab AS mc
WHERE
	mc.anulada = 0
GROUP BY
	YEAR(mc.fecha),
	MONTH(mc.fecha)
ORDER BY
	3 DESC

/*

ACTIVIDAD 2

Desarrolle una consulta que presente Artículo, Nombre Artículo, Nombre Marca, Total, que muestre 
aquellos artículos pertenecientes a marcas activas (ACTIVO = 'S') que vendieron como mínimo $50.000
durante año 2006 de forma MINORISTA.

Excluya siempre las ventas anuladas, y tome para el cálculo de los totales CANTIDAD * PRECIO.

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


/*

ACTIVIDAD 3

La empresa decidió pagar un premio equivalente al 3% de las ventas generadas en el año 2008 por los vendedores que
no son encargados (ENCARGADO = 'N'), están activos (ACTIVO = 'S'), y superaron los $100.000 en ventas en el año.
Además, debe cumplir la condición de haber tenido una antigüedad en el año 2008 de al menos 3 años para recibir 
el premio. Para calcular la antigüedad deberá tomar el año de la fecha de ingreso.

Liste el nombre del vendedor, su antigüedad, el total vendido en el 2008, y el valor del premio a pagar. Ordene por
vendedor y excluya ventas anuladas.

*/

SELECT
	v.nombre AS "Vendedor",
	2008 - YEAR(v.ingreso) AS "Antigüedad",
	SUM(vc.total) AS "Total Vendido",
	SUM(vc.total * 0.03) AS "Premio"
FROM
	vencab AS vc
	INNER JOIN vendedores AS v
	ON v.vendedor = vc.vendedor
WHERE
	vc.anulada = 0
	AND YEAR(vc.fecha) = 2008
	AND 2008 - YEAR(v.ingreso) >= 3
	AND v.activo = 'S'
	AND v.encargado = 'N'
GROUP BY
	v.nombre,
	2008 - YEAR(v.ingreso)
HAVING
	SUM(vc.total) > 100000
ORDER BY
	1