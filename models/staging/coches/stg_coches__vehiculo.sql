with source as (
    select
        VIN,
        ANIO          as anio,
        MODELO        as modelo,
        MARCA         as marca,
        MOTOR         as motor,
        TRANSMISION   as transmision,
        TRACCION      as traccion,
        COLOR         as color,
        KILOMETRAJE   as kilometraje
    from {{ source('coches', 'COCHES_RAW') }}
    where VIN is not null
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['VIN']) }}              as vehiculo_id,
        VIN                                                            as vin,
        anio,
        {{ dbt_utils.generate_surrogate_key(['modelo', 'marca']) }}  as modelo_id,
        {{ dbt_utils.generate_surrogate_key(['motor']) }}            as motor_id,
        {{ dbt_utils.generate_surrogate_key(['transmision']) }}      as transmision_id,
        {{ dbt_utils.generate_surrogate_key(['traccion']) }}         as traccion_id,
        {{ dbt_utils.generate_surrogate_key(['color']) }}            as color_id,
        kilometraje
    from source
)

select * from final
