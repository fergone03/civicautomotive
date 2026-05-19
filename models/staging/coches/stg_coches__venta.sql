with base as (
    select
        id_raw,
        vin,
        concesionario,
        fecha_compra,
        fecha_venta,
        precio_compra,
        precio_venta
    from {{ ref('int_coches__base') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['ID_RAW']) }} as venta_id,
        {{ dbt_utils.generate_surrogate_key(['vin']) }}                 as vehiculo_id,
        {{ dbt_utils.generate_surrogate_key(['concesionario']) }}       as concesionario_id,
        fecha_compra,
        fecha_venta,
        precio_compra,
        precio_venta
    from base
)

select * from final