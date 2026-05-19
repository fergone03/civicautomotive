with source as (
    select distinct COLOR as nombre
    from {{ source('coches', 'COCHES_RAW') }}
    where COLOR is not null
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['nombre']) }} as color_id,
        nombre
    from source
)

select * from final
