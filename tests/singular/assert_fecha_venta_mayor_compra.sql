-- Este test valida que la fecha de venta al cliente siempre sea
-- posterior a la fecha de adquisición del vehículo por el concesionario.
-- Una fecha_venta anterior a fecha_compra indica un error en los datos.

select
    id_venta,
    fecha_compra,
    fecha_venta,
    dias_stock
from {{ ref('fct_ventas') }}
where fecha_compra is not null
  and fecha_venta is not null
  and fecha_venta < fecha_compra