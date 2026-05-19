with base as (
    select distinct traccion
    from {{ ref('int_coches__base') }}
    where traccion is not null
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['traccion']) }} as traccion_id,
        traccion as nombre
    from base
)

select * from final