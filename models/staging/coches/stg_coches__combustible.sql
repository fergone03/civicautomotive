with source as (
    select distinct COMBUSTIBLE as nombre
    from {{ source('coches', 'COCHES_RAW') }}
    where COMBUSTIBLE is not null
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['nombre']) }} as combustible_id,
        nombre
    from source
)

select * from final
