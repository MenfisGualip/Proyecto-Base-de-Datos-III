-- Reportes --

-- Inventario General --

-- set @min_precio = 100;  -- Define el precio mínimo -- Esta instrccion se puede habilitar
-- set @max_precio = 500;  -- Define el precio máximo -- Esta instrccion se puede habilitar
select 
    P.codigo as Codigo,
    P.nombre as Nombre_Producto,
    P.stock as Stock_Actual,
    P.precio as Precio_Unitario,
    (P.stock * P.precio) as Valor_Total
from Producto P
where P.precio between 000 and 000; -- Cambia los valores según el rango deseado --
-- where precio between @min_precio and @max_precio; -- habilitar solo si el min y el max estan definidos previamente 

-- -------------------------------------------------------------------------------------------------------------------------------------------

-- Productos por Ubicación --

select 
    A.nombre as Nombre_Almacen,
    A.ubicacion as Ubicacion,
    P.codigo as Codigo_Producto,
    P.nombre as Nombre_Producto,
    P.stock as Stock
from Producto P
join Almacen A on P.id_almacen = A.id_almacen
order by A.nombre, P.nombre;

-- -------------------------------------------------------------------------------------------------------------------------------------------

-- Ventas Simuladas (Transacciones)--
select 
    T.id_transaccion as ID_Transaccion,
    P.codigo as Codigo_Producto,
    P.nombre as Nombre_Producto,
    T.cantidad as Cantidad_Vendida,
    T.fecha as Fecha_Transaccion,
    T.total as Valor_Total
from Transacciones T
join Producto P on T.id_producto = P.id_producto
order by T.fecha desc;

-- -------------------------------------------------------------------------------------------------------------------------------------------

-- Buscar productos en ubicaciones especificas --

set @ubicacion = 'Centro';  -- Define la ubicación del almacén a consultar

select 
    A.nombre as Nombre_Almacen,
    A.ubicacion as Ubicacion,
    P.codigo as Codigo_Producto,
    P.nombre as Nombre_Producto,
    P.stock as Stock
from Producto P
join Almacen A on P.id_almacen = A.id_almacen
where A.ubicacion = @ubicacion;

-- -------------------------------------------------------------------------------------------------------------------------------------------

-- -------------------------------------------------------------------------------------------------------------------------------------------
-- Segunda Fase --
-- -------------------------------------------------------------------------------------------------------------------------------------------

-- Vista de Productos por Almacén --
create view Vista_Productos_Almacen as
select 
    A.nombre as Nombre_Almacen,
    A.ubicacion as Ubicacion,
    P.codigo as Codigo_Producto,
    P.nombre as Nombre_Producto,
    P.stock as Stock
from Producto P
join Almacen A on P.id_almacen = A.id_almacen;

select * from Vista_Productos_Almacen;

-- Filtrar productos de un almacén específico
select * from Vista_Productos_Almacen
where Nombre_Almacen = 'Almacen Central';
-- -------------------------------------------------------------------------

-- Vista de Ventas por Producto --
create view Vista_Ventas_Producto as
select 
    P.codigo as Codigo_Producto,
    P.nombre as Nombre_Producto,
    sum(T.cantidad) as Total_Vendido,
    sum(T.total) as Total_Ventas
from Transacciones T
join Producto P on T.id_producto = P.id_producto
group by P.codigo, P.nombre;

select * from Vista_Ventas_Producto;

-- Filtrar productos con ventas mayores a 500
select * from Vista_Ventas_Producto
where Total_Ventas > 500;

-- -------------------------------------------------------------------------

-- Consulta para revisar que rol tiene asignado cada empleado

select u.nombre, u.email, r.nombre as rol
from Usuarios u
join Roles r on u.id_rol = r.id_rol;

