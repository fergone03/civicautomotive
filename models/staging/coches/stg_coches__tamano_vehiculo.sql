with source as (
    select distinct TAMANO as nombre
    from {{ source('coches', 'COCHES_RAW') }}
    where TAMANO is not null
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['nombre']) }} as tamano_id,
        nombre
    from source
)

select * from final
