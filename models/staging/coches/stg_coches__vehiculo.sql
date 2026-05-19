with base as (
    select
        vin,
        anio,
        modelo,
        marca,
        motor,
        combustible,
        transmision,
        traccion,
        color,
        kilometraje
    from {{ ref('int_coches__base') }}
    where vin is not null
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['vin']) }}             as vehiculo_id,
        vin,
        anio,
        {{ dbt_utils.generate_surrogate_key(['modelo', 'marca']) }} as modelo_id,
        {{ dbt_utils.generate_surrogate_key(['motor']) }}           as motor_id,
        {{ dbt_utils.generate_surrogate_key(['transmision']) }}     as transmision_id,
        {{ dbt_utils.generate_surrogate_key(['traccion']) }}        as traccion_id,
        {{ dbt_utils.generate_surrogate_key(['color']) }}           as color_id,
        kilometraje
    from base
)

select * from final