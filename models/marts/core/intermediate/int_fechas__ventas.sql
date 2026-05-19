with venta as (
    select * from {{ ref('stg_coches__venta') }}
),

final as (
    select distinct
        fecha_compra,
        fecha_venta
    from venta
)

select * from final
