with base as (
    select distinct color
    from {{ ref('stg_coches__base') }}
    where color is not null
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['color']) }} as color_id,
        color as nombre
    from base
)

select * from final