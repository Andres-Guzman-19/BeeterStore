-- Etapa core. Modelado de datos
DROP TABLE IF EXISTS core.ventas;
DROP TABLE IF EXISTS core.clientes;
DROP TABLE IF EXISTS core.detalle_inventario;
DROP TABLE IF EXISTS core.marketing;
DROP TABLE IF EXISTS core.productos;
DROP TABLE IF EXISTS core.proveedores;
DROP TABLE IF EXISTS core.ciudades;

--#######################################################################################

-- Creacion de tablas de clientes

CREATE TABLE core.ciudades (
  id_ciudad SERIAL PRIMARY KEY,
  ciudad TEXT
);

INSERT INTO core.ciudades (ciudad)
SELECT
  ciudad
FROM stg.ciudades;

--#######################################################################################

-- Creacion de tablas de clientes

CREATE TABLE core.clientes (
  documento INT8 PRIMARY KEY,
  nombre TEXT,
  apellido TEXT,
  correo TEXT,
  telefono INT8,
  id_ciudad INT,
  fecha_registro DATE,

  FOREIGN KEY (id_ciudad) REFERENCES core.ciudades(id_ciudad)
);

INSERT INTO core.clientes
SELECT
  c.documento,
  c.nombre,
  c.apellido,
  c.correo,
  c.telefono,
  ci.id_ciudad,
  c.fecha_registro
FROM stg.clientes c
JOIN core.ciudades ci ON ci.ciudad = c.ciudad;

INSERT INTO core.clientes (documento, nombre, apellido)
VALUES(0, 'Desconocido', 'Desconocido');

--#######################################################################################

-- Creacion de tablas de productos

CREATE TABLE core.productos (
  id_producto SERIAL PRIMARY KEY,
  producto TEXT,
  categoria TEXT
);

INSERT INTO core.productos (producto, categoria)
SELECT
  producto,
  categoria
FROM stg.productos;

--#######################################################################################

-- Creacion de tablas de proveedores

CREATE TABLE core.proveedores (
  id_proveedor SERIAL PRIMARY KEY,
  proveedor TEXT
);

INSERT INTO core.proveedores (proveedor)
SELECT
  proveedor
FROM stg.proveedor;

--#######################################################################################

-- Creacion de tablas de Detalle

CREATE TABLE core.detalle_inventario (
  id_detalle SERIAL PRIMARY KEY,
  id_producto INT,
  id_proveedor INT,
  costo NUMERIC(10,2),
  precio NUMERIC(10,2),
  stock INT,

  FOREIGN KEY (id_producto) REFERENCES core.productos(id_producto),

  FOREIGN KEY (id_proveedor) REFERENCES core.proveedores(id_proveedor)
);

INSERT INTO core.detalle_inventario (id_producto, id_proveedor, costo, precio, stock)
SELECT
  p.id_producto,
  pr.id_proveedor,
  il.costo,
  il.precio,
  il.stock
FROM stg.inventario_limpio il
JOIN core.productos p ON p.producto = il.producto 
JOIN core.proveedores pr ON pr.proveedor = il.proveedor;

--#######################################################################################

-- Creacion de tablas de Ventas

CREATE TABLE core.ventas (
  id_ventas SERIAL PRIMARY KEY,
  documento INT8,
  id_detalle INT,
  cantidad INT,
  canal_venta TEXT,

  FOREIGN KEY (documento) REFERENCES core.clientes(documento),
  FOREIGN KEY (id_detalle) REFERENCES core.detalle_inventario(id_detalle)
);

-- Dado que la tabla ventas de raw tiene el nombre del cliente y no el numero del documento no es posible identificar con precision
-- a que cliente pertenece la venta, por lo que se registrara un cliente generico. Deberia registrarse siempre un forma de identificar
-- un cliente unico
WITH clientes_unicos AS (
  SELECT
    nombre,
    apellido,
    MIN(documento) AS documento
  FROM core.clientes
  GROUP BY nombre, apellido
  HAVING COUNT(*) = 1
),

-- En la tabla ventas solo se registra el nombre del producto dado que en este momento el precio y costo de un producto no difiere por el proveedor.
-- Sin embargo, la base de datos se diseño pensando en que estos valores podrian diferir de acuerdo al proveedor, por lo que se deberia registrar
-- una llave que identifique tanto producto como proveedor. Por el momento se resgitar el proveedor con mayor stock ya que el precio y la cantidad
-- no impactan.
productos_unicos AS (
  SELECT DISTINCT ON (id_producto) 
       id_producto,
       id_detalle
  FROM core.detalle_inventario
  ORDER BY id_producto, stock DESC
)
  
INSERT INTO core.ventas (documento, id_detalle, cantidad, canal_venta)
SELECT
  COALESCE(cu.documento,0) AS documento,
  pu.id_detalle,
  v.cantidad,
  v.canal_venta
FROM stg.ventas v
LEFT JOIN clientes_unicos cu ON cu.nombre = v.nombre AND cu.apellido = v.apellido
JOIN core.productos p ON p.producto = v.producto
JOIN productos_unicos pu ON pu.id_producto = p.id_producto;

--#######################################################################################

-- Creacion de tablas de Marketing

CREATE TABLE core.marketing (
  id_cmpania SERIAL PRIMARY KEY,
  campania TEXT,
  id_producto INT,
  canal TEXT,
  descuento REAL,
  presupuesto_usd NUMERIC(10,2),
  fecha_inicio DATE,
  fecha_fin DATE,

  FOREIGN KEY (id_producto) REFERENCES core.productos(id_producto)
);

INSERT INTO core.marketing (
  campania,
  id_producto,
  canal,
  descuento,
  presupuesto_usd,
  fecha_inicio,
  fecha_fin
)
SELECT
  m.campania,
  p.id_producto,
  m.canal,
  m.descuento,
  m.presupuesto_usd,
  m.fecha_inicio,
  m.fecha_fin
FROM stg.marketing m
JOIN core.productos p ON p.producto = m.producto;
