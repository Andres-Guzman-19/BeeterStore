# 🏗 Pipeline de Datos en SQL – Arquitectura RAW → STG → CORE (Supabase / PostgreSQL)

## 📌 Descripción del Proyecto

Este proyecto implementa un pipeline de datos completamente en SQL utilizando **Supabase (PostgreSQL)** como motor de base de datos.

Se basa en una arquitectura por capas común en entornos de Data Engineering:

RAW → STG → CORE → ANALÍTICA

El objetivo es transformar datos operativos sin procesar en un modelo relacional estructurado y listo para análisis de negocio.

---

# 🚀 Tecnologías Utilizadas

- PostgreSQL (Supabase)
- SQL (DDL + DML)
- Modelado relacional
- Arquitectura de datos por capas
- Integridad referencial

---

# 🏛 Arquitectura del Proyecto

## 1️⃣ Capa RAW – Datos Fuente

La capa RAW contiene los datos tal como se cargan directamente en Supabase.

Características:

- Sin transformaciones
- Sin validaciones
- Inconsistencias en formato
- Posibles valores nulos
- Fechas almacenadas como texto
- Sin claves foráneas

Tablas fuente:

- raw.clientes_leales
- raw.inventario
- raw.marketing
- raw.ventas

Esta capa simula un escenario real donde los datos operacionales llegan con problemas de calidad.

---

## 2️⃣ Capa STG – Limpieza y Estandarización

La capa STG (Staging) aplica reglas de transformación para mejorar la calidad y consistencia de los datos.

### Transformaciones aplicadas

- Eliminación de espacios innecesarios (TRIM)
- Normalización de texto (LOWER + INITCAP)
- Limpieza con expresiones regulares
- Eliminación de duplicados (DISTINCT)
- Conversión de fechas (TO_DATE)
- Filtrado de valores nulos críticos

### Tablas generadas en STG

- stg.clientes
- stg.ciudades
- stg.productos
- stg.proveedor
- stg.inventario_limpio
- stg.marketing
- stg.ventas

Objetivo de esta capa:

- Garantizar consistencia
- Separar lógica de limpieza del modelo final
- Preparar datos para modelado relacional
- Reducir errores en la capa CORE

---

## 3️⃣ Capa CORE – Modelo Relacional

La capa CORE implementa un modelo normalizado con:

- Claves primarias
- Claves foráneas
- Integridad referencial
- Separación entre dimensiones y hechos

---

## 📍 Tablas Dimensión

### Ciudades
- id_ciudad (PK)
- ciudad

### Clientes
- documento (PK)
- nombre
- apellido
- correo
- telefono
- id_ciudad (FK)
- fecha_registro

Se incluye un registro especial:

documento = 0 → Cliente "Desconocido"

Esto garantiza consistencia cuando no es posible identificar un cliente único.

---

### Productos
- id_producto (PK)
- producto
- categoria

### Proveedores
- id_proveedor (PK)
- proveedor

---

## 📦 Tabla Puente – Detalle Inventario

Resuelve la relación muchos-a-muchos entre productos y proveedores.

- id_detalle (PK)
- id_producto (FK)
- id_proveedor (FK)
- costo
- precio
- stock

El modelo está preparado para soportar variaciones de precio por proveedor.

---

## 💰 Tabla de Hechos – Ventas

Representa eventos transaccionales.

- id_ventas (PK)
- documento (FK → clientes)
- id_detalle (FK → detalle_inventario)
- cantidad
- canal_venta

### Decisiones de modelado

- La fuente RAW no contiene documento del cliente.
- Se identifica cliente único por nombre y apellido cuando no hay ambigüedad.
- En caso contrario, se asigna al cliente "Desconocido".
- Cuando existen múltiples proveedores para un producto, se selecciona el de mayor stock.

Estas decisiones mantienen la integridad referencial sin perder información.

---

## 📢 Tabla Marketing

- id_campania (PK)
- campania
- id_producto (FK)
- canal
- descuento
- presupuesto_usd
- fecha_inicio
- fecha_fin

Permite analizar campañas asociadas a productos específicos.

---

# 📊 Consultas Analíticas Implementadas

## 1️⃣ Clientes por Ciudad
Permite analizar concentración geográfica de clientes.

## 2️⃣ Top 5 Productos Más Vendidos
- Por cantidad
- Por ingresos (cantidad × precio)

## 3️⃣ Productos Vendidos con Pérdida
Identifica casos donde:

costo > precio

Útil para análisis de rentabilidad.

---

# 🧠 Habilidades Demostradas

✔ Diseño de arquitectura por capas  
✔ Limpieza y transformación de datos en SQL  
✔ Modelado relacional normalizado  
✔ Implementación de claves foráneas  
✔ Manejo de datos inconsistentes  
✔ Enfoque orientado a negocio  
✔ Preparación para escalabilidad  

---

# 📈 Posibles Mejoras Futuras

- Implementar cargas incrementales
- Crear índices para optimización
- Incorporar vistas materializadas
- Agregar validaciones de calidad de datos
- Migrar a esquema estrella para analítica OLAP
- Automatizar ejecución con jobs programados

---

# 🎯 Objetivo del Proyecto

Este proyecto demuestra la capacidad de:

- Diseñar pipelines de datos estructurados
- Aplicar buenas prácticas de Data Engineering
- Transformar datos crudos en información accionable
- Construir modelos listos para análisis de negocio

---
