with source as (
    select
        VIN,
        ANIO          as anio,
        MODELO        as modelo,
        MARCA         as marca,
        MOTOR         as motor,
        COMBUSTIBLE   as combustible,
        TRANSMISION   as transmision,
        TRACCION      as traccion,
        COLOR         as color,
        TIPO_VEHICULO as tipo_vehiculo,
        TAMANO        as tamano,
        KILOMETRAJE   as kilometraje
    from {{ source('coches', 'COCHES_RAW') }}
    where VIN is not null
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['VIN']) }} as vehiculo_id,
        VIN                                              as vin,
        anio,
        case 
            when modelo is null or marca is null then null
            else {{ dbt_utils.generate_surrogate_key(['modelo', 'marca', 'tipo_vehiculo', 'tamano']) }}
        end as modelo_id,
        case 
            when motor is null or combustible is null then null
            else {{ dbt_utils.generate_surrogate_key(['motor', 'combustible']) }}
        end as motor_id,
        case when transmision is null then null else {{ dbt_utils.generate_surrogate_key(['transmision']) }} end as transmision_id,
        case when traccion    is null then null else {{ dbt_utils.generate_surrogate_key(['traccion']) }}    end as traccion_id,
        case when color       is null then null else {{ dbt_utils.generate_surrogate_key(['color']) }}       end as color_id,
        kilometraje
    from source
)

select * from final