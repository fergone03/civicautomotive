with base as (
    select distinct combustible
    from {{ ref('int_coches__base') }}
    where combustible is not null
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['combustible']) }} as combustible_id,
        combustible as nombre
    from base
)

select * from final