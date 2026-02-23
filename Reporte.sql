-- ¿Cuántos clientes únicos hay y en qué ciudades se concentran?
SELECT
  c.ciudad,
  COUNT(*) AS Cantidad
FROM core.clientes cl
JOIN core.ciudades c ON c.id_ciudad = cl.id_ciudad
GROUP BY c.ciudad;

-- ¿Cuáles son los 5 productos más vendidos por cantidad y por ingresos?
--TOP 5 CANTIDAD
SELECT
  p.producto,
  SUM(v.cantidad) AS Cantidad
FROM core.ventas v
JOIN core.detalle_inventario di ON di.id_detalle = v.id_detalle
JOIN core.productos p ON p.id_producto = di.id_producto
GROUP BY p.producto
ORDER BY SUM(v.cantidad) DESC
LIMIT 5;

--TOP 5 INGRESO
SELECT
  p.producto,
  SUM(v.cantidad) * MIN(di.precio) AS Ingreso
FROM core.ventas v
JOIN core.detalle_inventario di ON di.id_detalle = v.id_detalle
JOIN core.productos p ON p.id_producto = di.id_producto
GROUP BY p.producto
ORDER BY SUM(v.cantidad) * MIN(di.precio) DESC
LIMIT 5;

-- ¿Qué productos se están vendiendo con pérdida (costo > precio)?
SELECT
  p.producto,
  di.costo,
  di.precio
FROM core.detalle_inventario di
JOIN core.productos p
  ON p.id_producto = di.id_producto
WHERE di.costo > di.precio;
