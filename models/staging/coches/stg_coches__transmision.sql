with source as (
    select distinct TRANSMISION as nombre
    from {{ source('coches', 'COCHES_RAW') }}
    where TRANSMISION is not null
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['nombre']) }} as transmision_id,
        nombre
    from source
)

select * from final
