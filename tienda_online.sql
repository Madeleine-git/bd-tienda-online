-- =====================================================
-- Proyecto: Base de datos relacional para una tienda online
-- Motor:    MySQL / MariaDB (probado en MariaDB con XAMPP)
-- Entidades: categorias, productos, clientes, pedidos, detalles_pedido
-- =====================================================

DROP DATABASE IF EXISTS tienda_online;
CREATE DATABASE tienda_online
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_spanish_ci;
USE tienda_online;

-- -----------------------------------------------------
-- Tabla: categorias
-- -----------------------------------------------------
CREATE TABLE categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(80)  NOT NULL UNIQUE,
    descripcion  VARCHAR(255)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Tabla: productos
-- -----------------------------------------------------
CREATE TABLE productos (
    id_producto  INT AUTO_INCREMENT PRIMARY KEY,
    id_categoria INT           NOT NULL,
    nombre       VARCHAR(120)  NOT NULL,
    descripcion  TEXT,
    precio       DECIMAL(10,2) NOT NULL,
    stock        INT           NOT NULL DEFAULT 0,
    CONSTRAINT chk_producto_precio CHECK (precio >= 0),
    CONSTRAINT chk_producto_stock  CHECK (stock >= 0),
    CONSTRAINT fk_producto_categoria
        FOREIGN KEY (id_categoria) REFERENCES categorias (id_categoria)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Tabla: clientes
-- -----------------------------------------------------
CREATE TABLE clientes (
    id_cliente     INT AUTO_INCREMENT PRIMARY KEY,
    nombre         VARCHAR(60)  NOT NULL,
    apellidos      VARCHAR(100) NOT NULL,
    email          VARCHAR(120) NOT NULL UNIQUE,
    telefono       VARCHAR(20),
    direccion      VARCHAR(150) NOT NULL,
    ciudad         VARCHAR(80)  NOT NULL,
    codigo_postal  VARCHAR(10)  NOT NULL,
    pais           VARCHAR(60)  NOT NULL DEFAULT 'España',
    fecha_registro DATE         NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT chk_cliente_email CHECK (email LIKE '%_@_%._%')
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Tabla: pedidos
-- -----------------------------------------------------
CREATE TABLE pedidos (
    id_pedido    INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente   INT           NOT NULL,
    fecha_pedido DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado       VARCHAR(20)   NOT NULL DEFAULT 'pendiente',
    total        DECIMAL(12,2) NOT NULL DEFAULT 0,
    CONSTRAINT chk_pedido_estado
        CHECK (estado IN ('pendiente','pagado','enviado','entregado','cancelado')),
    CONSTRAINT chk_pedido_total CHECK (total >= 0),
    CONSTRAINT fk_pedido_cliente
        FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Tabla: detalles_pedido
-- (precio_unitario guarda el precio en el momento de la compra)
-- -----------------------------------------------------
CREATE TABLE detalles_pedido (
    id_detalle      INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido       INT           NOT NULL,
    id_producto     INT           NOT NULL,
    cantidad        INT           NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio   CHECK (precio_unitario >= 0),
    CONSTRAINT uq_pedido_producto UNIQUE (id_pedido, id_producto),
    CONSTRAINT fk_detalle_pedido
        FOREIGN KEY (id_pedido) REFERENCES pedidos (id_pedido)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_detalle_producto
        FOREIGN KEY (id_producto) REFERENCES productos (id_producto)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Índices para acelerar consultas habituales
-- -----------------------------------------------------
CREATE INDEX idx_productos_categoria ON productos (id_categoria);
CREATE INDEX idx_pedidos_cliente     ON pedidos (id_cliente);
CREATE INDEX idx_detalles_producto   ON detalles_pedido (id_producto);

-- -----------------------------------------------------
-- Datos de prueba
-- -----------------------------------------------------
INSERT INTO categorias (nombre, descripcion) VALUES
    ('Informática', 'Equipos y accesorios'),
    ('Hogar', 'Artículos para el hogar');

INSERT INTO productos (id_categoria, nombre, descripcion, precio, stock) VALUES
    (1, 'Teclado mecánico', 'Teclado USB retroiluminado', 59.90, 25),
    (1, 'Ratón inalámbrico', 'Ratón ergonómico', 24.50, 40),
    (2, 'Lámpara LED', 'Lámpara de escritorio', 19.99, 15);

INSERT INTO clientes (nombre, apellidos, email, telefono, direccion, ciudad, codigo_postal)
VALUES ('Ana', 'García López', 'ana@example.com', '600123456', 'Calle Mayor 1', 'Madrid', '28001');

INSERT INTO pedidos (id_cliente, estado, total) VALUES (1, 'pagado', 84.40);

INSERT INTO detalles_pedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES
    (1, 1, 1, 59.90),
    (1, 2, 1, 24.50);

-- -----------------------------------------------------
-- Consulta de comprobación
-- -----------------------------------------------------
SELECT p.id_pedido, c.nombre, pr.nombre AS producto, d.cantidad, d.precio_unitario
FROM pedidos p
JOIN clientes c         ON c.id_cliente = p.id_cliente
JOIN detalles_pedido d  ON d.id_pedido  = p.id_pedido
JOIN productos pr       ON pr.id_producto = d.id_producto;
