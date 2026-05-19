with source as (
    select distinct MARCA as nombre
    from {{ source('coches', 'COCHES_RAW') }}
    where MARCA is not null
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['nombre']) }} as marca_id,
        nombre
    from source
)

select * from final
