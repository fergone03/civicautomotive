with fechas as (
    select distinct fecha_venta as fecha
    from {{ ref('int_fechas__ventas') }}
    where fecha_venta is not null
),

final as (
    select
        cast(to_char(fecha, 'YYYYMMDD') as integer) as fecha_sk,
        fecha,
        year(fecha)  as anio,
        month(fecha) as mes,
        day(fecha)   as dia
    from fechas
)

select * from final
