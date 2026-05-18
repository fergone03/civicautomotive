with base as (
    select distinct transmision
    from {{ ref('stg_coches__base') }}
    where transmision is not null
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['transmision']) }} as transmision_id,
        transmision as nombre
    from base
)

select * from final