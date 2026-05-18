with base as (
    select distinct marca
    from {{ ref('stg_coches__base') }}
    where marca is not null
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['marca']) }} as marca_id,
        marca as nombre
    from base
)

select * from final