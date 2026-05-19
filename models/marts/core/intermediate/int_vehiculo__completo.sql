with base as (
    select * from {{ ref('int_vehiculo__atributos') }}
),

motor as (
    select * from {{ ref('stg_coches__motor') }}
),

combustible as (
    select * from {{ ref('stg_coches__combustible') }}
),

transmision as (
    select * from {{ ref('stg_coches__transmision') }}
),

traccion as (
    select * from {{ ref('stg_coches__traccion') }}
),

color as (
    select * from {{ ref('stg_coches__color') }}
),

final as (
    select
        base.vehiculo_id,
        base.vin,
        base.anio,
        base.kilometraje,
        base.marca,
        base.modelo,
        base.tipo_vehiculo,
        base.tamano,
        motor.descripcion  as motor,
        combustible.nombre as combustible,
        transmision.nombre as transmision,
        traccion.nombre    as traccion,
        color.nombre       as color
    from base
    left join motor
        on base.motor_id = motor.motor_id
    left join combustible
        on motor.combustible_id = combustible.combustible_id
    left join transmision
        on base.transmision_id = transmision.transmision_id
    left join traccion
        on base.traccion_id = traccion.traccion_id
    left join color
        on base.color_id = color.color_id
)

select * from final
