with seed as (
    select distinct
        ciudad,
        region
    from {{ ref('concesionarios') }}
    where ciudad is not null
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['ciudad']) }}  as ciudad_id,
        ciudad                                               as nombre,
        {{ dbt_utils.generate_surrogate_key(['region']) }}  as region_id
    from seed
)

select * from final