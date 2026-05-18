with seed as (
    select distinct
        region,
        pais
    from {{ ref('concesionarios') }}
    where region is not null
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['region']) }}  as region_id,
        region                                               as nombre,
        {{ dbt_utils.generate_surrogate_key(['pais']) }}    as pais_id
    from seed
)

select * from final