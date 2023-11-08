USE Ventas2;
--VISTAS
SELECT * FROM articulos
CREATE OR ALTER VIEW v_articulos AS
	SELECT 
		articulo,
		nombre,
		rubro
	FROM
		articulos


SELECT * FROM v_articulos
EXEC sp_helptext v_articulos

--FUNCIONES
