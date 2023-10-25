/*

CALCULAR LAS COMISIONES A PAGAR A LOS VENDEDORES QUE SUPERARON EN EL AÑO 2008 LA FACTURA DE 
MAYOR IMPORTE REALIZADA EN EL AÑO 2007.

LA COMISIÓN A PAGAR ES DE 5% POR FACTURA.
TABLA VENCAB

*/
--PRIMERO REALIZAMOS UNA SUBCONSULTA
USE Ventas2
SELECT 
	MAX(total)
FROM
	vencab
WHERE
	YEAR(fecha) = 2007

SELECT
	total,
	total * 0,5 AS 'COMISIONES'
FROM
	vencab
WHERE
	YEAR(fecha) = 2008 AND
	anulada = 0 AND
	total > (SELECT MAX(total)FROM vencab WHERE YEAR(fecha) = 2007)

/* 

EJERCICIO 1: LISTAR LOS CÓDIGOS DE LAS SUCURSALES EN LAS QUE SE HICIERON VENTAS MAYORES A $1000 EN EL MES DE MAYO DE 2007.
NO TENGA EN CUENTA VENTAS ANULADAS.

*/
USE Ventas2
SELECT DISTINCT
	sucursal
FROM
	vencab
WHERE
	total > 1000 AND
	anulada = 0 AND
	fecha BETWEEN '01/05/2007' AND '31/05/2007' 

	
/*

EJERCICIO 2: PRESENTE EL CÓDIGO, EL NOMBRE Y LA SUCURSAL DE LOS VENDEDORES QUE SEAN ENCARGADOS, QUE ESTÉN ACTIVOS
Y QUE ALGUNA VEZ RECIBIERON UNIFORME (tabla uniformes). UTILICE SUBCONSULTA.

*/
SELECT DISTINCT vendedor FROM uniformes
SELECT
	vendedor,
	nombre,
	sucursal,
	encargado
FROM
	vendedores
WHERE
	activo = 'S' AND
	encargado = 'S' AND
	vendedor IN (SELECT DISTINCT vendedor FROM uniformes)
/*

EJERCICIO 3: LISTAR LAS FACTURAS POR VENTA MAYORISTA QUE SUPERARON LOS $3000 EN EL AÑO 2008. NO CONSIDERAR
VENTAS ANULADAS Y MOSTRAR: LETRA, FACTURA, FECHA, TOTAL.

*/
SELECT * FROM mayorcab
SELECT 
	letra,
	factura,
	fecha,
	total
FROM
	mayorcab
WHERE
	total > 3000 AND
	YEAR(fecha) = 2008 AND
	anulada = 0
/*

EJERCICIO 4: DETERMINAR QUE FACTURAS MINORISTAS SUPERARON EN EL AÑO 2007 AL VALOR DE FACTURA PROMEDIO DEL
AÑO 2006. LISTAR: LETRA, FACTURA, TOTAL.

*/
--subconsulta
SELECT * FROM vencab
SELECT AVG(total) FROM vencab WHERE YEAR(fecha) = 2006
SELECT
	letra,
	factura,
	total
FROM
	vencab
WHERE
	YEAR(fecha) = 2007 AND
	anulada = 0 AND
	total > (SELECT AVG(total) FROM vencab WHERE YEAR(fecha) = 2006)
ORDER BY
	total ASC
/*

EJERCICIO 5: CALCULAR EL IMPORTE TOTAL COMPRADO POR CLIENTES DE CORDOBA CAPITAL (cp=5000) EN EL PRIMER
SEMESTRE DEL AÑO 2008. NO TENGA EN CUENTA VENTAS ANULADAS.

*/
--SUBCONSULTA
SELECT cliente FROM clientes WHERE cp = '5000'
SELECT
	SUM(total)
FROM
	mayorcab
WHERE
	anulada = 0 AND
	fecha BETWEEN '01/01/2008' AND '30/06/2008' AND
	cliente IN (SELECT cliente FROM clientes WHERE cp = '5000')


/*
Listar las facturas de ventas MAYORISTAS, generadas en el año 2007 por clientes de la provincia de Córdoba.

Los clientes de la provincia de Córdoba son aquellos cuyo código postal (columna CP de la tabla CLIENTES) 
está entre '5000' y '5999'. TENGA EN CUENTA QUE ESTA COLUMNA ES DE TIPO CHAR.

Mostrar en el resultado las columnas NOMBRE (cliente), CP, LETRA, FACTURA, FECHA y TOTAL.

Ordene por el nombre del cliente, y luego por el número de factura. Excluya ventas anuladas.

TABLAS: clientes, mayorcab (EL RESULTADO DEBE RETORNAR 5327 FILAS)

*/

SELECT 
	a.nombre,
	a.cp,
	mc.factura,
	mc.fecha,
	mc.total
FROM
	clientes AS a
	INNER JOIN mayorcab AS mc ON a.cliente = mc.cliente
WHERE
	a.cp BETWEEN '5000' AND '5999' AND
	MC.anulada = 0 AND
	YEAR(mc.fecha) = 2007
ORDER BY
	nombre ASC,
	factura ASC
/*

RECUPERACIÓN DE DATOS DE VARIAS TABLAS CON AGRUPAMIENTO

Partiendo de la base de la consulta anterior (con las mismas condiciones), muestre ahora las siguientes columnas: 

NOMBRE (cliente), CP, CANTIDAD DE FACTURAS (count), IMPORTE TOTAL (sum)

Ordene en forma DESCENDENTE por el IMPORTE TOTAL.

TABLAS: clientes, mayorcab (EL RESULTADO DEBE RETORNAR 142 FILAS)

*/

SELECT 
	a.nombre,
	a.cp,
	COUNT(mc.factura),
	SUM(mc.total) AS 'importe total'
FROM
	clientes AS a
	INNER JOIN mayorcab AS mc ON a.cliente = mc.cliente
WHERE
	YEAR(mc.fecha) = 2007 AND
	mc.anulada = 0 AND
	a.cp BETWEEN '5000' AND '5999' 
GROUP BY
	a.nombre,
	a.cp
ORDER BY
	4 DESC
/*

7. RECUPERACIÓN DE DATOS DE VARIAS TABLAS CON SUBCONSULTA Y AGRUPAMIENTO

El vendedor SIKORA ARIEL (144) fue quien mas ventas logró en el año 2005 (en importe total). 

Se le solicita determinar qué vendedores lo superaron (en importe total) en el año 2006. Debe excluir ventas anuladas en todas las consultas.

Mostrar VENDEDOR, NOMBRE, ENCARGADO (S o N), IMPORTE TOTAL. Ordene el resultado por importe total en forma decreciente.

TABLAS: vencab y vendedores (consulta principal), vencab (subconsulta). EL RESULTADO DEBE RETORNAR 4 FILAS.

*/
--SubconsultA
SELECT DISTINCT SUM(total) FROM vencab WHERE vendedor = 144 AND anulada = 0 AND YEAR(fecha) = 2005

SELECT 
	v.vendedor,
	v.nombre,
	v.encargado,
	SUM(vc.total)
FROM
	vencab AS vc
	INNER JOIN vendedores AS v ON vc.vendedor = v.vendedor
WHERE
	YEAR(vc.fecha) = 2006 AND
	vc.anulada = 0
GROUP BY
	v.nombre,
	v.encargado,
	v.vendedor
HAVING
	SUM(vc.total) > (SELECT SUM(total) FROM vencab WHERE vendedor = 144 AND anulada = 0 AND YEAR(fecha) = 2005)
ORDER BY
	4 DESC

-- LISTAR LOS RUBROS QUE EN EL AÑO 2007 VENDIERON MAS DE 1000 PRENDAS

SELECT 
	r.rubro,
	r.nombre,
	SUM(vt.cantidad) AS 'Cantidad prendas'
FROM
	rubros AS r
	INNER JOIN articulos AS a ON r.rubro = a.rubro
	INNER JOIN vendet AS vt ON vt.articulo = a.articulo
	INNER JOIN vencab AS vc ON vc.letra = vt.letra AND vc.factura = vt.factura
WHERE
	YEAR(vc.fecha) = 2007 AND
	vc.anulada = 0
GROUP BY
	r.nombre,
	r.rubro
HAVING
	SUM(vt.cantidad) > 1000 AND
	SUM(vt.cantidad) < 2000
/*

DETERMINAR QUE VENDEDORES NO CUMPLIERON CON EL OBJETIVO DE VENTAS EN EL AÑO 2005. EL OBJETIVO DE VENTAS ERA SUPERAR LOS $100.000.

*/

SELECT
	v.vendedor,
	SUM(vc.total) AS 'Total ventas',
	v.nombre
FROM
	vendedores AS v
	INNER JOIN vencab AS vc ON v.vendedor = vc.vendedor
WHERE
	vc.anulada = 0 AND
	YEAR(vc.fecha) = 2005
GROUP BY
	v.vendedor,
	v.nombre
HAVING
	SUM(vc.total) < 100000
ORDER BY
	2 DESC
/*

IDENTIFICAR LOS ARTICULOS DE LA MARCA 'B52' Y DEL RUBRO 'REMERAS' QUE TUVIERON VENTAS SUPERIORES A $1500 DURANTE
EL PRIMER SEMESTRE DEL AÑO 2008.

MOSTRAR: articulo, nombre, importe total. ORDENAR DE FORMA DECRECIENTE POR importe total

EXCLUIR VENTAS ANULADAS
tablas = marcas, articulos, vendet, vencab,rubro

*/
SELECT
	a.articulo AS 'ARTICULO',
	a.nombre AS 'NOMBRE ARTICULO',
	SUM(vt.cantidad * vt.precio) AS 'IMPORTE TOTAL'
FROM
	marcas AS m
	INNER JOIN articulos AS a ON m.marca = a.marca
	INNER JOIN rubros AS r ON r.rubro = a.rubro
	INNER JOIN vendet AS vt ON vt.articulo = a.articulo
	INNER JOIN vencab AS vc ON vt.letra = vc.letra AND vc.factura = vt.factura
WHERE
	m.nombre LIKE '%B52%' AND
	r.nombre LIKE '%REMERAS%' AND
	vc.fecha BETWEEN '2008-01-01' AND '2008-06-30' AND
	vc.anulada = 0
GROUP BY
	a.articulo,
	a.nombre
HAVING
	SUM(vt.cantidad * vt.precio) > 1500
ORDER BY
	3 DESC

	-- CALCULAR EL IMPORTE TOTAL VENDIDO HISTÓRICO POR SUCURSAL PARA VENTAS MINORISTAS
	
SELECT
	s.sucursal,
	s.denominacion,
	SUM(vc.total)
FROM
	sucursales AS s
	INNER JOIN vencab AS vc ON s.sucursal = vc.sucursal
WHERE
	vc.anulada = 0
GROUP BY
	s.sucursal,
	s.denominacion

UNION

SELECT
	s.sucursal,
	s.denominacion,
	SUM(my.total)
FROM
	sucursales AS s
	INNER JOIN mayorcab AS my ON s.sucursal = my.sucursal
WHERE
	my.anulada = 0
GROUP BY
	s.sucursal,
	s.denominacion

/*

OBTENER LA CANTIDAD DE PRENDAS VENDIDAS POR CÓDIGO DE ARTÍCULO, PARA LOS ARTÍCULOS PERTENECIENTES AL RUBRO SWEATERS
REALIZADAS EN LA TEMPORADA DE INVIERNO DEL AÑO 2007.

PRESENTAR: artículo, nombre, preciomenor, preciomayor, cantidad, tipo de venta (x mayor o x menor)

ORDENAR POR CÓDIGO DE ARTICULO.
TABLA VENDET VENCAB Y ARTICULOS

*/
SELECT DISTINCT temporada,aa FROM articulos
SELECT
	a.articulo,
	a.nombre,
	a.preciomayor,
	a.preciomenor,
	SUM(vd.cantidad)
FROM
	articulos AS a
	INNER JOIN vendet AS vd ON vd.articulo = a.articulo
	INNER JOIN vencab AS vc ON vc.letra = vd.letra AND vd.factura = vc.factura
	INNER JOIN rubros AS r ON r.rubro = a.rubro
WHERE
	vc.fecha BETWEEN '2007-06-01' AND '2007-08-31' AND
	--r.nombre LIKE '%SWEATERS%' AND
	vc.anulada = 0 AND
	r.rubro = 40
GROUP BY
	a.articulo,
	a.nombre,
	a.preciomayor,
	a.preciomenor

UNION

SELECT
	a.articulo,
	a.nombre,
	a.preciomayor,
	a.preciomenor,
	SUM(mt.cantidad)
FROM
	articulos AS a
	INNER JOIN mayordet AS mt ON mt.articulo = a.articulo
	INNER JOIN mayorcab AS mc ON mc.letra = mt.letra AND mc.factura = mt.factura
	INNER JOIN rubros AS r ON r.rubro = a.rubro
WHERE
	mc.fecha BETWEEN '2007-06-01' AND '2007-08-31' AND
	--r.nombre LIKE '%SWEATERS%' AND
	mc.anulada = 0 AND
	r.rubro = 40
GROUP BY
	a.articulo,
	a.nombre,
	a.preciomayor,
	a.preciomenor
/*
	EJERCICIO 1

Mostrar el nombre del vendedor y su fecha de ingreso, de todos los vendedores
que vendieron prendas de la marca 'B52' en el local de 'PATIO OLMOS' 

TABLAS: vencab, vendet, vendedores, articulos, marcas, sucursales

*/
select denominacion FROM sucursales
SELECT DISTINCT
	v.nombre,
	v.ingreso,
	m.nombre,
	s.denominacion
FROM
	marcas AS m
	INNER JOIN articulos AS a ON a.marca = m.marca
	INNER JOIN vendet AS vt ON vt.articulo = a.articulo
	INNER JOIN vencab AS vc ON vt.letra = vc.letra AND vt.factura = vc.factura
	INNER JOIN vendedores AS v ON v.vendedor = vc.vendedor
	INNER JOIN sucursales AS s ON s.sucursal = vc.sucursal AND s.sucursal = v.sucursal
WHERE
	m.nombre LIKE '%B52%' AND
	s.denominacion LIKE '%PATIO OLMOS%' AND
	vc.anulada  = 0 
	

	



