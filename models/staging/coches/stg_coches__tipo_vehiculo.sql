with base as (
    select distinct tipo_vehiculo
    from {{ ref('int_coches__base') }}
    where tipo_vehiculo is not null
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['tipo_vehiculo']) }} as tipo_vehiculo_id,
        tipo_vehiculo as nombre
    from base
)

select * from final