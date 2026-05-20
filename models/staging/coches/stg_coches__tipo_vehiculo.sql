with source as (
    select distinct TIPO_VEHICULO as nombre
    from {{ source('coches', 'COCHES_RAW') }}
    where TIPO_VEHICULO is not null
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['nombre']) }} as tipo_vehiculo_id,
        nombre
    from source
)

select * from final
