-- Etapa STG. Limpieza de datos

--#######################################################################################

-- Creacion de tablas de clientes
DROP TABLE IF EXISTS stg.clientes;

CREATE TABLE stg.clientes AS 
  SELECT DISTINCT ON (documento)
  INITCAP(LOWER(REGEXP_REPLACE(TRIM(nombre), '\s', ' ', 'g'))) AS nombre,
  INITCAP(LOWER(REGEXP_REPLACE(TRIM(apellido), '\s', ' ', 'g'))) AS apellido,
  documento AS documento,
  LOWER(REGEXP_REPLACE(TRIM(correo), '\s', '', 'g')) AS correo,
  telefono AS telefono,
  INITCAP(LOWER(REGEXP_REPLACE(TRIM(ciudad), '\s', ' ', 'g'))) AS ciudad,
  to_date(TRIM(fecha_registro), 'YYYY-MM-DD') AS fecha_registro
FROM raw.clientes_leales
WHERE documento IS NOT NULL;

--#######################################################################################

-- Creacion de tablas de ciudades
DROP TABLE IF EXISTS stg.ciudades;

CREATE TABLE stg.ciudades AS 
  SELECT DISTINCT
  INITCAP(LOWER(REGEXP_REPLACE(TRIM(ciudad), '\s', ' ', 'g'))) AS ciudad
FROM raw.clientes_leales;

--#######################################################################################

-- Creacion de tablas a partir de inventario

-- Tabla productos
DROP TABLE IF EXISTS stg.productos;

CREATE TABLE stg.productos AS
SELECT DISTINCT
  INITCAP(LOWER(REGEXP_REPLACE(TRIM(producto), '\s+', ' ', 'g'))) AS producto,
  INITCAP(LOWER(REGEXP_REPLACE(TRIM(categoria), '\s+', ' ', 'g'))) AS categoria,
  precio AS precio,
  costo AS costo
FROM raw.inventario
WHERE producto IS NOT NULL;

--#######################################################################################

-- Tabla proveedores
DROP TABLE IF EXISTS stg.proveedor;

CREATE TABLE stg.proveedor AS
SELECT DISTINCT
  INITCAP(LOWER(REGEXP_REPLACE(TRIM(proveedor), '\s+', ' ', 'g'))) AS proveedor
FROM raw.inventario
WHERE proveedor IS NOT NULL;

--#######################################################################################

-- Tabla Inventario Limpio
DROP TABLE IF EXISTS stg.Inventario_limpio;

CREATE TABLE stg.Inventario_limpio AS
SELECT DISTINCT
  INITCAP(LOWER(REGEXP_REPLACE(TRIM(producto), '\s+', ' ', 'g'))) AS producto,
  INITCAP(LOWER(REGEXP_REPLACE(TRIM(proveedor), '\s+', ' ', 'g'))) AS proveedor,
  precio AS precio,
  costo AS costo,
  stock AS stock
FROM raw.inventario
WHERE proveedor IS NOT NULL AND producto IS NOT NULL;

--#######################################################################################

--Tabla marketing

DROP TABLE IF EXISTS stg.marketing;

CREATE TABLE stg.marketing AS
  SELECT DISTINCT
  INITCAP(LOWER(REGEXP_REPLACE(TRIM(campania), '\s', ' ', 'g'))) AS campania,
  INITCAP(LOWER(REGEXP_REPLACE(TRIM(producto), '\s', ' ', 'g'))) AS producto,
  INITCAP(LOWER(REGEXP_REPLACE(TRIM(canal), '\s', ' ', 'g'))) AS canal,
  descuento AS descuento,
  presupuesto_usd AS presupuesto_usd,
  to_date(TRIM(fecha_inicio), 'YYYY-MM-DD') AS fecha_inicio,
  to_date(TRIM(fecha_fin), 'YYYY-MM-DD') AS fecha_fin
FROM raw.marketing
WHERE campania IS NOT NULL;

--#######################################################################################

--Tabla ventas

DROP TABLE IF EXISTS stg.ventas;

CREATE TABLE stg.ventas AS
  SELECT
  INITCAP(LOWER(REGEXP_REPLACE(TRIM(nombre), '\s', ' ', 'g'))) AS nombre,
  INITCAP(LOWER(REGEXP_REPLACE(TRIM(apellido), '\s', ' ', 'g'))) AS apellido,
  INITCAP(LOWER(REGEXP_REPLACE(TRIM(producto), '\s', ' ', 'g'))) AS producto,
  cantidad AS cantidad,
  INITCAP(LOWER(REGEXP_REPLACE(TRIM(canal_venta), '\s', ' ', 'g'))) AS canal_venta
FROM raw.ventas;
