with source as (
    select distinct TRACCION as nombre
    from {{ source('coches', 'COCHES_RAW') }}
    where TRACCION is not null
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['nombre']) }} as traccion_id,
        nombre
    from source
)

select * from final
