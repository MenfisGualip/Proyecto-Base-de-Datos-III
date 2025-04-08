create database GestionInventario;
use GestionInventario;

create table Almacen(
id_almacen int auto_increment not null primary key,
nombre varchar(100) not null,
 ubicacion varchar(55) not null);
 
 select * from Almacen;

create table Producto(
id_producto int auto_increment not null primary key,
codigo varchar(50) unique not null,
nombre varchar(255) not null,
descripcion text,
precio decimal (10,2) not null,
stock int not null,
id_almacen int not null,
foreign key(id_almacen) references Almacen(id_almacen) on delete restrict);

create table Roles (
    id_rol int auto_increment not null primary key,
    nombre VARCHAR(50) unique not null);

insert into  roles (nombre) values ('administrador');
insert into roles (nombre) values ('operador');    
    
create table Usuarios(
id_usuario int auto_increment not null primary key,
nombre varchar(100) not null,
email varchar(100) unique not null,
psswrd varchar(100) not null,
id_rol int not null,
foreign key (id_rol) references Roles(id_rol));

-- Tabla para la simulacion de ventas--
create table Transacciones(
id_transaccion int auto_increment not null primary key,
cantidad int not null,
fecha datetime default current_timestamp,
total decimal (10,2) not null,
id_producto int not null,
foreign key (id_producto) references Producto(id_producto));

-- Trigger para la simulacion de la venta --
delimiter $$
create trigger calcular_total_venta before insert on Transacciones
for each row
begin
    declare precio_unitario decimal(10,2);

    -- Obtiene el precio del producto --
    select precio into precio_unitario
    from Producto
    where id_producto = NEW.id_producto;

    -- Calcula el total de la venta --
    set NEW.total = NEW.cantidad * precio_unitario;
end;
$$

-- Tabla para manejar detalles de las transacciones --
create table Detalle_Transaccion (
    id_detalle int auto_increment not null primary key,
    id_transaccion int not null,
    id_producto int not null,
    cantidad int not null,
    precio_unitario decimal(10,2) not null,
    subtotal DECIMAL(10,2) not null,
    foreign key (id_transaccion) references Transacciones(id_transaccion) on delete cascade,
    foreign key (id_producto) references Producto(id_producto) on delete restrict);

-- Trigger para evitar stock negativo --
delimiter $$
create trigger verificar_stock before insert on Detalle_Transaccion
for each row
begin
    declare stock_actual int;

    -- Obtiene el stock disponible del producto --
    select stock into stock_actual
    from Producto
    where id_producto = NEW.id_producto;

    -- Verifica si hay suficiente stock --
    if stock_actual < NEW.cantidad then
        signal sqlstate '45000'
        set message_text = 'Error: Stock insuficiente para realizar la venta';
    end if;
end;
$$

-- Trigger para actualizar el stock después de una transaccion --
delimiter $$
create trigger actualizar_stock after insert on Detalle_Transaccion
for each row
begin
    update Producto 
    set stock = stock - NEW.cantidad
    where id_producto = NEW.id_producto;
end;
$$

-- -------------------------------------------------------------------------------------------------------------------------------------------
-- Datos de las tablas --
-- -------------------------------------------------------------------------------------------------------------------------------------------    
 -- Almacen --

insert into Almacen (nombre, ubicacion) values 
('Almacen Central', 'Calle Ficticia 123'),
('Almacen Norte', 'Avenida Norte 456'),
('Almacen Sur', 'Calle del Sol 789'),
('Almacen Oeste', 'Calle Oscura 101'),
('Almacen Este', 'Avenida Este 202');


-- Producto --
insert into Producto (codigo, nombre, descripcion, precio, stock, id_almacen) values 
('P001', 'Laptop HP', 'Laptop con procesador i7, 16GB RAM, 512GB SSD', 899.99, 50, 1),
('P002', 'Mouse Logitech', 'Mouse inalámbrico de alta precisión', 25.99, 200, 1),
('P003', 'Teclado Mecánico', 'Teclado mecánico RGB con switches Cherry MX', 79.99, 150, 2),
('P004', 'Monitor 24" Dell', 'Monitor LED 24" Full HD con soporte ajustable', 199.99, 75, 2),
('P005', 'Disco Duro Externo', 'Disco duro externo 1TB USB 3.0', 49.99, 120, 3),
('P006', 'Auriculares Bose', 'Auriculares inalámbricos con cancelación de ruido', 249.99, 80, 4),
('P007', 'Webcam Logitech', 'Cámara web 1080p, ideal para videoconferencias', 69.99, 110, 5),
('P008', 'Mouse Razer', 'Mouse para juegos con iluminación RGB', 59.99, 200, 5),
('P009', 'Teclado Corsair', 'Teclado mecánico para juegos con retroiluminación RGB', 129.99, 60, 4),
('P010', 'Monitor Asus 27"', 'Monitor curvo 27" 4K', 399.99, 90, 3);

insert into Producto (codigo, nombre, descripcion, precio, stock, id_almacen) values 
('P011', 'Laptop HP', 'Laptop con procesador i7 + iRISx, 1T RAM, 512GB SSD', 6000.00, 20, 1),
('P012', 'Mouse Logitech + Headsets', 'Mouse inalámbrico de alta precisión + Audifonos gamer', 1625.99, 200, 5),
('P013', 'Teclado Mecánico', 'Teclado mecánico RGB con switches Cherry MX edicion delux', 1079.99, 150, 2),
('P014', 'Monitor 32" Dell', 'Monitor LED 32" Full HD con soporte ajustable', 2199.99, 1275.58, 4),
('P015', 'Disco Duro Externo', 'Disco duro externo 1TB USB 5.0', 3049.99, 120, 3);




-- Usuarios --
insert into Usuarios (nombre, email, psswrd, id_rol) values 
('Juan Pérez', 'juan.perez@empresa.com', 'password123', 1),
('Ana Gómez', 'ana.gomez@empresa.com', 'password456', 2),
('Carlos Rodríguez', 'carlos.rodriguez@empresa.com', 'password789', 2),
('Lucía Martínez', 'lucia.martinez@empresa.com', 'lucia123', 1),
('Pedro García', 'pedro.garcia@empresa.com', 'pedro456', 2),
('Laura Sánchez', 'laura.sanchez@empresa.com', 'laura789', 1),
('José Ruiz', 'jose.ruiz@empresa.com', 'jose123', 2),
('Marta Fernández', 'marta.fernandez@empresa.com', 'marta456', 2),
('Raúl López', 'raul.lopez@empresa.com', 'raul789', 2),
('Elena Díaz', 'elena.diaz@empresa.com', 'elena123', 1);

-- Transacciones -- 
insert into Transacciones (cantidad, total, id_producto) values 
(2, 1799.98, 1),
(5, 129.95, 2),
(1, 79.99, 3),
(3, 599.97, 4),
(1, 49.99, 5),
(4, 999.96, 6),
(2, 139.98, 7),
(1, 59.99, 8),
(3, 389.97, 9),
(2, 799.98, 10);

-- Detalle Transaccion --

insert into Detalle_Transaccion (id_transaccion, id_producto, cantidad, precio_unitario, subtotal) values
(1, 1, 2, 899.99, 1799.98),
(2, 2, 5, 25.99, 129.95),
(3, 3, 1, 79.99, 79.99),
(4, 4, 3, 199.99, 599.97),
(5, 5, 1, 49.99, 49.99),
(6, 6, 4, 249.99, 999.96),
(7, 7, 2, 69.99, 139.98),
(8, 8, 1, 59.99, 59.99),
(9, 9, 3, 129.99, 389.97),
(10, 10, 2, 399.99, 799.98);


-- -------------------------------------------------------------------------------------------------------------------------------------------
-- Segunda Fase --
-- -------------------------------------------------------------------------------------------------------------------------------------------

-- Particiones --

-- Horizontal
-- 1. Crea tabla basica de productos para id_producto menor a 1000
create table Producto_Pmenor (
    id_producto int auto_increment not null primary key,
    codigo varchar(50) unique not null,
    nombre varchar(255) not null,
    descripcion text,
    precio decimal(10,2) not null,
    stock int not null,
    id_almacen int not null,
    foreign key(id_almacen) references Almacen(id_almacen) on delete restrict
);

-- 2. Crea tabla basica de productos para id_producto mayor o igual a 1000
create table Producto_Pmayor (
    id_producto int auto_increment not null primary key,
    codigo varchar(50) unique not null,
    nombre varchar(255) not null,
    descripcion text,
    precio decimal(10,2) not null,
    stock int not null,
    id_almacen int not null,
    foreign key(id_almacen) references Almacen(id_almacen) on delete restrict
);

-- Insertar datos
insert into Producto_Pmenor select * from Producto where id_producto < 1000;
select * from Producto_Pmenor;

insert into Producto_Pmayor select * from Producto where id_producto >= 1000;
select * from Producto_Pmayor;


-- 3. Crea una tabla avanzada de partición por rango (en función de la fecha de la transacción)
create table Transacciones_Rango (
    id_transaccion int not null,
    cantidad int not null,
    fecha datetime default current_timestamp,
    total decimal(10,2) not null,
    id_producto int not null,
    primary key (id_transaccion, fecha)
)
partition by range (year(fecha)) (
    partition p_2023 values less than (2024),
    partition p_2024 values less than (2025),
    partition p_2025 values less than (2026)
);

-- Insertar datos
insert into Transacciones_Rango (id_transaccion, cantidad, fecha, total, id_producto)
select id_transaccion, cantidad, fecha, total, id_producto
from Transacciones;
select * from Transacciones_Rango;


-- 4. Crea una tabla de partición por lista (según la ubicación del almacén)
create table Producto_Lista (
    id_producto int not null,
    codigo varchar(50) not null,
    nombre varchar(255) not null,
    descripcion text,
    precio decimal(10,2) not null,
    stock int not null,
    id_almacen int not null,
    primary key (id_producto, id_almacen),
    unique (codigo, id_almacen)
)
partition by list (id_almacen) (
    partition p_almacen_central values in (1),
    partition p_almacen_norte values in (2),
    partition p_almacen_sur values in (3),
    partition p_almacen_oeste values in (4),
    partition p_almacen_este values in (5)
);

-- Insertar datos
insert into Producto_Lista (id_producto, codigo, nombre, descripcion, precio, stock, id_almacen)
select id_producto, codigo, nombre, descripcion, precio, stock, id_almacen
from Producto;

select * from Producto_Lista;

-- select distinct id_almacen from Producto_Lista where id_almacen not in (1, 2, 3, 4); -- para identificar alamacenes nuevos

-- --------------------------------------------------------------------------------------------------
-- Vertical

-- 1. Tabla para almacenar solo el nombre y el precio de los productos
create table Producto_Nombre_Precio (
    id_producto int not null primary key,
    nombre varchar(255) not null,
    precio decimal(10,2) not null
);

-- Insertar datos
insert into Producto_Nombre_Precio select id_producto, nombre, precio from Producto;
select * from Producto_Nombre_Precio;

-- 2. Tabla para almacenar el resto de las columnas
create table Detalle_Producto (
    id_producto int not null primary key,
    descripcion text,
    stock int not null,
    id_almacen int not null,
    foreign key(id_almacen) references Almacen(id_almacen)
);

-- Insertar datos
insert into Detalle_Producto select id_producto, descripcion, stock, id_almacen from Producto;
select * from Detalle_Producto;

-- 3. Tabla para almacenar solo la información básica de la transacción
create table Transacciones_total (
    id_transaccion int not null primary key,
    cantidad int not null,
    total decimal(10,2) not null
);

insert into Transacciones_total (id_transaccion, cantidad, total) select id_transaccion, cantidad, total from Transacciones;
select * from Transacciones_total;

-- 4. Tabla para almacenar la fecha y el id_producto de la transacción
create table Transacciones_fecha (
    id_transaccion int not null primary key,
    fecha datetime default current_timestamp,
    id_producto int not null,
    foreign key(id_producto) references Producto(id_producto)
);

insert into Transacciones_fecha (id_transaccion, fecha, id_producto) select id_transaccion, fecha, id_producto from Transacciones;
select * from Transacciones_fecha;

-- 5. Tabla para almacenar los detalles del precio unitario y subtotal
create table Factura (
    id_detalle int not null primary key,
    precio_unitario decimal(10,2) not null,
    subtotal decimal(10,2) not null
);

insert into Factura (id_detalle, precio_unitario, subtotal) select id_detalle, precio_unitario, subtotal from Detalle_Transaccion;
select * from Factura;

-- 6. Tabla para almacenar la información básica de la transacción
create table Detalle_Factura (
    id_detalle int not null primary key,
    id_transaccion int not null,
    id_producto int not null,
    cantidad int not null
);

insert into Detalle_Factura (id_detalle, id_transaccion, id_producto, cantidad) select id_detalle, id_transaccion, id_producto, cantidad from Detalle_Transaccion;
select * from Detalle_Factura;

-- 7. Tabla para almacenar los datos sensibles y de contacto (email, password)
create table Usuarios_Data (
    id_usuario int not null primary key,
    email varchar(100) unique not null,
    psswrd varchar(100) not null
);
insert into Usuarios_Data (id_usuario, email, psswrd) select id_usuario, email, psswrd from Usuarios;
select * from Usuarios_Data;
-- -------------------------------------------------------------------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------------------------------------

-- Creacion de Usuarios --

-- Crear rol administrador
create role administrador;

-- Crear rol operador
create role operador;

-- Otorgar permisos al rol administrador
grant all privileges on GestionInventario.* to administrador;

-- Otorgar permisos al rol operador
grant select, insert, update on GestionInventario.* to operador;

select u.nombre, u.email, r.nombre as rol
from Usuarios u
join Roles r on u.id_rol = r.id_rol;

-- Asignacion de Roles a nuevos trabajadores --
-- Asignar rol para nuevos trabajadores
-- create user 'nombre.apellido@empresa.com'@'%' identified by 'contrasena';
-- grant administrador to 'nombre.apellido@empresa.com';