-- Este test documenta un problema de calidad encontrado en los datos:
-- existen ventas donde el precio de venta es menor o igual al precio
-- de compra, lo que indica un error en el dato o una venta a pérdida.
-- Se esperaba que todas las ventas tuvieran margen positivo.

select
    id_venta,
    precio_compra,
    precio_venta,
    margen
from {{ ref('fct_ventas') }}
where precio_compra is not null
  and precio_venta is not null
  and precio_venta <= precio_compra