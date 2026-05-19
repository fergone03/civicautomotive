with base as (
    select distinct tamano
    from {{ ref('int_coches__base') }}
    where tamano is not null
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['tamano']) }} as tamano_id,
        tamano as nombre
    from base
)

select * from final