with venta as (
    select * from {{ ref('stg_coches__venta') }}
    where fecha_compra is not null and fecha_venta is not null
),

dim_vehiculo as (
    select * from {{ ref('dim_vehiculo') }}
),

dim_concesionario as (
    select * from {{ ref('dim_concesionario') }}
),

final as (
    select
        venta.venta_id                                              as id_venta,
        dim_vehiculo.vehiculo_sk,
        dim_concesionario.concesionario_sk,
        cast(to_char(venta.fecha_compra, 'YYYYMMDD') as integer)   as fecha_compra_sk,
        cast(to_char(venta.fecha_venta,  'YYYYMMDD') as integer)   as fecha_venta_sk,
        datediff('day', venta.fecha_compra, venta.fecha_venta)     as dias_stock,
        case 
            when datediff('day', venta.fecha_compra, venta.fecha_venta) <= 30  then 'Rápida (<= 30d)'
            when datediff('day', venta.fecha_compra, venta.fecha_venta) <= 90  then 'Normal (31-90d)'
            when datediff('day', venta.fecha_compra, venta.fecha_venta) <= 180 then 'Lenta (91-180d)'
            else 'Muy lenta (>180d)'
        end                                                          as categoria_rotacion,
        venta.precio_compra,
        venta.precio_venta,
        round(venta.precio_venta - venta.precio_compra, 2)         as margen
    from venta
    left join dim_vehiculo
        on venta.vehiculo_id = dim_vehiculo.id_vehiculo
    left join dim_concesionario
        on venta.concesionario_id = dim_concesionario.id_concesionario
)

select * from final