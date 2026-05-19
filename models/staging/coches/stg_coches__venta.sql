with source as (
    select
        ID,
        VIN,
        CONCESIONARIO,
        FECHA_COMPRA,
        FECHA_VENTA,
        PRECIO_COMPRA,
        PRECIO_VENTA
    from {{ source('coches', 'COCHES_RAW') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['ID']) }}              as venta_id,
        {{ dbt_utils.generate_surrogate_key(['VIN']) }}             as vehiculo_id,
        {{ dbt_utils.generate_surrogate_key(['CONCESIONARIO']) }}   as concesionario_id,
        FECHA_COMPRA                                                  as fecha_compra,
        FECHA_VENTA                                                   as fecha_venta,
        {{ limpiar_precio('PRECIO_COMPRA') }}                        as precio_compra,
        {{ limpiar_precio('PRECIO_VENTA') }}                         as precio_venta
    from source
)

select * from final
