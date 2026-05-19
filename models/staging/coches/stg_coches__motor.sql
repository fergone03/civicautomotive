with base as (
    select distinct
        motor,
        combustible
    from {{ ref('int_coches__base') }}
    where motor is not null
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['motor']) }}         as motor_id,
        motor                                                      as descripcion,
        {{ dbt_utils.generate_surrogate_key(['combustible']) }}   as combustible_id
    from base
)

select * from final