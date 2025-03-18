-- Configuración de Replicación en MySQL

-- En el servidor maestro
-- Edita el archivo my.cnf y agrega:
-- [mysqld]
-- log-bin=mysql-bin
-- server-id=1

-- Luego reinicia MySQL
-- systemctl restart mysql

-- Crear usuario para la replicación\CREATE USER 'repl'@'%' IDENTIFIED WITH mysql_native_password BY 'password_repl';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
FLUSH PRIVILEGES;

-- Ver el estado del maestro
SHOW MASTER STATUS;

-- En el servidor esclavo
-- Edita el archivo my.cnf y agrega:
-- [mysqld]
-- server-id=2

-- Luego reinicia MySQL
-- systemctl restart mysql

-- Configurar el esclavo
CHANGE MASTER TO MASTER_HOST='IP_DEL_MAESTRO',
MASTER_USER='repl',
MASTER_PASSWORD='password_repl',
MASTER_LOG_FILE='nombre_del_archivo_binlog',
MASTER_LOG_POS=posición_binlog;
START SLAVE;

-- Verificar replicación
SHOW SLAVE STATUS\G;

-- Partición Horizontal (Separar datos de inventarios según almacenes)
ALTER TABLE Inventario PARTITION BY RANGE (id_almacen) (
    PARTITION p1 VALUES LESS THAN (10),
    PARTITION p2 VALUES LESS THAN (20),
    PARTITION p3 VALUES LESS THAN MAXVALUE
);

-- Partición Vertical (Separar datos según frecuencia de acceso)

-- Tabla con datos de acceso frecuente
CREATE TABLE ProductoInfo (
    id_producto INT PRIMARY KEY,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL
);

-- Tabla con datos menos consultados
CREATE TABLE ProductoDetalle (
    id_producto INT PRIMARY KEY,
    descripcion TEXT,
    ubicacion VARCHAR(100) NOT NULL,
    FOREIGN KEY (id_producto) REFERENCES ProductoInfo(id_producto)
);
