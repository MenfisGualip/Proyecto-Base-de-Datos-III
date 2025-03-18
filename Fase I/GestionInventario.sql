create database GestionInventario;
use GestionInventario;

create table Almacen(
id_almacen int auto_increment not null primary key,
nombre varchar(100) not null,
 ubicacion varchar(55) not null);

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
('Almacen Este', 'Avenida Este 202'),
('Almacen Norte 2', 'Avenida Norte 789'),
('Almacen Sur 2', 'Calle del Sol 456'),
('Almacen Regional', 'Calle Principal 345'),
('Almacen A', 'Sector A 678'),
('Almacen B', 'Sector B 234');

-- Producto --
insert into Producto (codigo, nombre, descripcion, precio, stock, id_almacen) values 
('P001', 'Laptop HP', 'Laptop con procesador i7, 16GB RAM, 512GB SSD', 899.99, 50, 1),
('P002', 'Mouse Logitech', 'Mouse inalámbrico de alta precisión', 25.99, 200, 1),
('P003', 'Teclado Mecánico', 'Teclado mecánico RGB con switches Cherry MX', 79.99, 150, 2),
('P004', 'Monitor 24" Dell', 'Monitor LED 24" Full HD con soporte ajustable', 199.99, 75, 2),
('P005', 'Disco Duro Externo', 'Disco duro externo 1TB USB 3.0', 49.99, 120, 3),
('P006', 'Auriculares Bose', 'Auriculares inalámbricos con cancelación de ruido', 249.99, 80, 4),
('P007', 'Webcam Logitech', 'Cámara web 1080p, ideal para videoconferencias', 69.99, 110, 5),
('P008', 'Mouse Razer', 'Mouse para juegos con iluminación RGB', 59.99, 200, 6),
('P009', 'Teclado Corsair', 'Teclado mecánico para juegos con retroiluminación RGB', 129.99, 60, 7),
('P010', 'Monitor Asus 27"', 'Monitor curvo 27" 4K', 399.99, 90, 8);

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
