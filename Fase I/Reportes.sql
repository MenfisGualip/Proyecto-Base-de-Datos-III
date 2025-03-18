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
