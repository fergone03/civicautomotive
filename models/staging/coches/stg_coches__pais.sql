with seed as (
    select distinct pais
    from {{ ref('concesionarios') }}
    where pais is not null
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['pais']) }} as pais_id,
        pais as nombre
    from seed
)

select * from final