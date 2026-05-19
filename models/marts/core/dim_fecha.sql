with fechas as (
    select fecha_compra as fecha
    from {{ ref('int_fechas__ventas') }}
    where fecha_compra is not null

    union

    select fecha_venta as fecha
    from {{ ref('int_fechas__ventas') }}
    where fecha_venta is not null
),

final as (
    select
        cast(to_char(fecha, 'YYYYMMDD') as integer)  as fecha_sk,
        fecha,
        year(fecha)                                    as anio,
        month(fecha)                                   as mes,
        day(fecha)                                     as dia,
        quarter(fecha)                                 as trimestre,
        case month(fecha)
            when 1 then 'Enero' when 2 then 'Febrero' when 3 then 'Marzo'
            when 4 then 'Abril' when 5 then 'Mayo' when 6 then 'Junio'
            when 7 then 'Julio' when 8 then 'Agosto' when 9 then 'Septiembre'
            when 10 then 'Octubre' when 11 then 'Noviembre' when 12 then 'Diciembre'
        end                                            as nombre_mes,
        dayname(fecha)                                 as nombre_dia
    from fechas
)

select * from final