with source as (
    select distinct
        MOTOR        as motor,
        COMBUSTIBLE  as combustible
    from {{ source('coches', 'COCHES_RAW') }}
    where MOTOR is not null and COMBUSTIBLE is not null
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['motor', 'combustible']) }}  as motor_id,
        motor                                                              as descripcion,
        {{ dbt_utils.generate_surrogate_key(['combustible']) }}            as combustible_id
    from source
)

select * from final