# Base de datos de una tienda online

Esquema de base de datos relacional para una tienda online, diseñado en MySQL/MariaDB y normalizado hasta la tercera forma normal (3FN).

## Contenido del repositorio

| Archivo | Descripción |
|---|---|
| `tienda_online.sql` | Script que crea la base de datos, las tablas, las relaciones, los índices y unos datos de prueba |
| `diagrama-er.png` | Diagrama Entidad-Relación del esquema |

## Entidades

| Tabla | Atributos principales |
|---|---|
| `categorias` | id_categoria, nombre, descripcion |
| `productos` | id_producto, id_categoria, nombre, descripcion, precio, stock |
| `clientes` | id_cliente, nombre, apellidos, email, telefono, direccion, ciudad, codigo_postal, pais, fecha_registro |
| `pedidos` | id_pedido, id_cliente, fecha_pedido, estado, total |
| `detalles_pedido` | id_detalle, id_pedido, id_producto, cantidad, precio_unitario |

## Relaciones

- `categorias` 1 — N `productos`: una categoría tiene muchos productos; un producto pertenece a una sola categoría.
- `clientes` 1 — N `pedidos`: un cliente puede hacer varios pedidos; un pedido pertenece a un solo cliente.
- `pedidos` 1 — N `detalles_pedido`: un pedido se compone de varias líneas.
- `productos` 1 — N `detalles_pedido`: un producto puede aparecer en muchas líneas de pedido.
- `pedidos` N — M `productos`: relación resuelta mediante la tabla intermedia `detalles_pedido`.

## Decisiones de diseño

- **Normalización (3FN):** los datos del cliente y del producto no se repiten en los pedidos; solo se guardan sus identificadores.
- **`precio_unitario` en `detalles_pedido`:** guarda el precio en el momento de la compra, de modo que los cambios posteriores de precio no alteran los pedidos antiguos. Es un dato histórico, no una redundancia.
- **`ON DELETE RESTRICT`** en clientes y productos: no se puede borrar un cliente o un producto con pedidos asociados, para conservar el historial.
- **`ON DELETE CASCADE`** en las líneas de pedido: al borrar un pedido se borran sus líneas.
- **Restricciones de integridad:**
  - `PRIMARY KEY` en todas las tablas.
  - `FOREIGN KEY` para todas las relaciones.
  - `UNIQUE` en `categorias.nombre`, `clientes.email` y en la pareja (`id_pedido`, `id_producto`).
  - `CHECK` para impedir precios y stock negativos, cantidades menores o iguales a 0, estados de pedido no válidos y emails con formato incorrecto.

## Cómo ejecutarlo

### Con DBeaver, MySQL Workbench o la consola de MySQL

1. Conéctate a un servidor MySQL o MariaDB.
2. Abre `tienda_online.sql` y ejecútalo completo.

### Con phpMyAdmin (XAMPP)

phpMyAdmin no mantiene la selección de base de datos entre instrucciones, por lo que conviene hacerlo así:

1. Inicia **Apache** y **MySQL** desde el panel de XAMPP.
2. Abre `http://localhost/phpmyadmin` y crea una base de datos llamada `tienda_online`.
3. Selecciónala, ve a la pestaña **SQL** y pega el contenido del script **sin** las tres primeras instrucciones (`DROP DATABASE`, `CREATE DATABASE` y `USE`).
4. Pulsa **Continuar**.

Al final del script hay una consulta de comprobación que muestra las líneas del pedido de prueba.

## Probado en

- MariaDB (XAMPP 3.0) con phpMyAdmin.
