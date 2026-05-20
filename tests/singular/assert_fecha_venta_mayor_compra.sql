-- Valida que la fecha_venta sea posterior a la fecha_compra.
-- Lee desde stg_coches__venta porque fct_ventas solo tiene SKs.
select
    venta_id,
    fecha_compra,
    fecha_venta
from {{ ref('stg_coches__venta') }}
where fecha_compra is not null
  and fecha_venta is not null
  and fecha_venta < fecha_compra